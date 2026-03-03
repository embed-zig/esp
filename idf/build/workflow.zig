const std = @import("std");

pub const RuntimeDefaults = struct {
    idf_py: []const u8 = "idf.py",
    chip: []const u8 = "esp32s3",
    port: ?[]const u8 = null,
    baud: u32 = 115200,
    timeout: ?u32 = null,
};

pub const RuntimeOptions = struct {
    idf_py: []const u8,
    chip: []const u8,
    port: ?[]const u8,
    baud: u32,
    timeout: ?u32 = null,
};

pub const ExternalRuntimeOptions = struct {
    esp_idf: ?[]const u8,
    port: ?[]const u8,
    zig_bin: ?[]const u8,
    timeout: ?u32 = null,
};

pub const SdkconfigOptions = struct {
    output_file: []const u8 = "sdkconfig.generated",
    partition_file: []const u8 = "partitions.generated.csv",
    partition_file_for_idf: ?[]const u8 = null,
    board_file: []const u8,
};

pub const AutoAppMainOptions = struct {
    output_file: []const u8 = "build/app_main.generated.c",
    delegate_symbol: []const u8,
};

pub fn runtimeOptionsFromBuild(b: *std.Build, defaults: RuntimeDefaults) RuntimeOptions {
    return .{
        .idf_py = b.option([]const u8, "idf_py", "Path to idf.py executable") orelse defaults.idf_py,
        .chip = b.option([]const u8, "chip", "ESP chip target passed to idf.py set-target") orelse defaults.chip,
        .port = b.option([]const u8, "port", "Serial port used by flash/monitor") orelse defaults.port,
        .baud = b.option(u32, "baud", "Serial baud rate used by flash/monitor") orelse defaults.baud,
        .timeout = b.option(u32, "timeout", "Auto-exit monitor after N seconds") orelse defaults.timeout,
    };
}

pub fn externalRuntimeOptionsFromBuild(b: *std.Build) ExternalRuntimeOptions {
    const opt = b.option([]const u8, "esp_idf", "ESP-IDF root directory; defaults to ESP_IDF env var");
    const esp_idf = opt orelse getEnvOrNull(b, "ESP_IDF");
    const port = b.option([]const u8, "port", "Serial port used by flash/monitor");
    const zig_bin = b.option([]const u8, "zig_bin", "Zig compiler path used for target static library generation") orelse getEnvOrNull(b, "ESPZ_ZIG_BIN");
    const timeout = b.option(u32, "timeout", "Auto-exit monitor after N seconds");

    return .{
        .esp_idf = esp_idf,
        .port = port,
        .zig_bin = zig_bin,
        .timeout = timeout,
    };
}

pub const RegisterOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    app_name: []const u8,
    app_dir: []const u8,
    app_entry: []const u8 = "src/main.zig",

    idf_module: ?*std.Build.Module = null,
    idf_root_source: ?[]const u8 = null,
    app_options_module: ?*std.Build.Module = null,
    espz_root: ?std.Build.LazyPath = null,

    sdkconfig: ?SdkconfigOptions = null,
    auto_app_main: ?AutoAppMainOptions = null,
    idf_build_dir: ?[]const u8 = null,
    extra_component_dirs: []const std.Build.LazyPath = &.{},

    link_libc: bool = true,
    install_artifact: bool = true,
    runtime: RuntimeOptions,
    board_profile_name: ?[]const u8 = null,

    /// 如果为 true，则额外暴露 configure/idf-build/flash/monitor/flash-monitor 短别名。
    /// 一个 build.zig 中仅建议对一个默认 app 打开此选项。
    expose_unprefixed_steps: bool = false,
};

pub const Registration = struct {
    executable: ?*std.Build.Step.Compile,
    build_step: *std.Build.Step,
    sdkconfig_step: ?*std.Build.Step,
    app_main_step: ?*std.Build.Step,
    configure_step: *std.Build.Step,
    idf_build_step: *std.Build.Step,
    flash_step: *std.Build.Step,
    monitor_step: *std.Build.Step,
    flash_monitor_step: *std.Build.Step,
};

pub const UnprefixedStepProfile = enum {
    full,
    runtime_only,
};

pub const RegisterExternalOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    app_name: []const u8,
    app_root: []const u8 = ".",
    app_entry: []const u8 = "src/main.zig",

    board_file: []const u8,
    build_dir: []const u8 = "build",
    entry_symbol: []const u8,

    espz_root: ?std.Build.LazyPath = null,

    extra_component_dirs: []const std.Build.LazyPath = &.{},

    link_zig_entry_library: bool = false,
    zig_target: []const u8 = "xtensa-freestanding-none",
    zig_cpu: ?[]const u8 = null,
    compile_check_with_idf_module: bool = true,

    install_artifact: bool = false,
    runtime: ExternalRuntimeOptions,

    expose_prefixed_steps: bool = true,
    expose_unprefixed_steps: bool = false,
    unprefixed_step_profile: UnprefixedStepProfile = .full,
};

pub fn registerAppWorkflow(b: *std.Build, options: RegisterOptions) Registration {
    const idf_module = resolveIdfModule(b, options);
    const entry_path = joinPath(b, options.app_dir, options.app_entry);
    const required_env_check_run = registerRequiredEnvCheckStepWithRoot(
        b,
        options.app_name,
        options.espz_root,
    );
    const app_imports = buildAppImports(b, idf_module, options.app_options_module);

    const app_root_module = b.createModule(.{
        .root_source_file = b.path(entry_path),
        .target = options.target,
        .optimize = options.optimize,
        .link_libc = options.link_libc,
        .imports = app_imports,
    });

    const executable = b.addExecutable(.{
        .name = options.app_name,
        .root_module = app_root_module,
    });

    if (options.install_artifact) {
        b.installArtifact(executable);
    }

    const build_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            options.app_name,
            b.fmt("Build {s} example", .{options.app_name}),
        );
        step.dependOn(&executable.step);
        break :blk step;
    } else &executable.step;

    const sdkconfig_step = if (options.sdkconfig) |sdkconfig_options|
        registerSdkconfigStep(b, options.app_name, options.app_dir, sdkconfig_options, options.espz_root, true)
    else
        null;
    const app_main_step = if (options.auto_app_main) |auto_options|
        registerAppMainGenerationStep(b, options.app_name, options.app_dir, auto_options, options.espz_root, true)
    else
        null;
    const sdkconfig_file = if (options.sdkconfig) |sdkconfig_options| sdkconfig_options.output_file else null;

    const set_target_cmd = addIdfPyBaseCommand(
        b,
        options.runtime,
        options.app_dir,
        null,
        options.board_profile_name,
        options.idf_build_dir,
        options.extra_component_dirs,
    );
    set_target_cmd.step.dependOn(&required_env_check_run.step);
    if (app_main_step) |step| {
        set_target_cmd.step.dependOn(step);
    }
    set_target_cmd.addArgs(&.{ "set-target", options.runtime.chip });

    const reconfigure_cmd = addIdfPyBaseCommand(
        b,
        options.runtime,
        options.app_dir,
        sdkconfig_file,
        options.board_profile_name,
        options.idf_build_dir,
        options.extra_component_dirs,
    );
    reconfigure_cmd.addArg("reconfigure");
    reconfigure_cmd.step.dependOn(&set_target_cmd.step);
    if (sdkconfig_step) |step| {
        reconfigure_cmd.step.dependOn(step);
    }
    if (app_main_step) |step| {
        reconfigure_cmd.step.dependOn(step);
    }

    const configure_step = b.step(
        b.fmt("{s}-configure", .{options.app_name}),
        b.fmt("Run idf.py reconfigure for {s}", .{options.app_name}),
    );
    configure_step.dependOn(&reconfigure_cmd.step);

    const idf_build_cmd = addIdfPyBaseCommand(
        b,
        options.runtime,
        options.app_dir,
        sdkconfig_file,
        options.board_profile_name,
        options.idf_build_dir,
        options.extra_component_dirs,
    );
    idf_build_cmd.addArg("build");
    idf_build_cmd.step.dependOn(&reconfigure_cmd.step);
    idf_build_cmd.step.dependOn(&executable.step);

    const idf_build_step = b.step(
        b.fmt("{s}-idf-build", .{options.app_name}),
        b.fmt("Run idf.py build for {s}", .{options.app_name}),
    );
    idf_build_step.dependOn(&idf_build_cmd.step);

    const flash_cmd = addIdfPyBaseCommand(
        b,
        options.runtime,
        options.app_dir,
        sdkconfig_file,
        options.board_profile_name,
        options.idf_build_dir,
        options.extra_component_dirs,
    );
    addSerialArgs(flash_cmd, options.runtime);
    flash_cmd.addArg("flash");
    flash_cmd.step.dependOn(&idf_build_cmd.step);

    const flash_step = b.step(
        b.fmt("{s}-flash", .{options.app_name}),
        b.fmt("Flash {s} with idf.py", .{options.app_name}),
    );
    flash_step.dependOn(&flash_cmd.step);

    const monitor_cmd = addIdfPyMonitorCommand(
        b,
        options.runtime,
        options.app_dir,
        sdkconfig_file,
        options.board_profile_name,
        options.idf_build_dir,
        options.extra_component_dirs,
        options.espz_root,
        false,
    );
    monitor_cmd.step.dependOn(&idf_build_cmd.step);

    const monitor_step = b.step(
        b.fmt("{s}-monitor", .{options.app_name}),
        b.fmt("Monitor {s} with idf.py", .{options.app_name}),
    );
    monitor_step.dependOn(&monitor_cmd.step);

    const flash_monitor_cmd = addIdfPyMonitorCommand(
        b,
        options.runtime,
        options.app_dir,
        sdkconfig_file,
        options.board_profile_name,
        options.idf_build_dir,
        options.extra_component_dirs,
        options.espz_root,
        true,
    );
    flash_monitor_cmd.step.dependOn(&idf_build_cmd.step);

    const flash_monitor_step = b.step(
        b.fmt("{s}-flash-monitor", .{options.app_name}),
        b.fmt("Flash and monitor {s} with idf.py", .{options.app_name}),
    );
    flash_monitor_step.dependOn(&flash_monitor_cmd.step);

    if (options.expose_unprefixed_steps) {
        if (sdkconfig_step) |step| {
            exposeAliasStep(b, "sdkconfig", "Generate default app sdkconfig", step);
        }
        exposeAliasStep(b, "configure", "Run default app configure", configure_step);
        exposeAliasStep(b, "idf-build", "Run default app idf.py build", idf_build_step);
        exposeAliasStep(b, "flash", "Flash default app", flash_step);
        exposeAliasStep(b, "monitor", "Monitor default app", monitor_step);
        exposeAliasStep(b, "flash-monitor", "Flash and monitor default app", flash_monitor_step);
    }

    return .{
        .executable = executable,
        .build_step = build_step,
        .sdkconfig_step = sdkconfig_step,
        .app_main_step = app_main_step,
        .configure_step = configure_step,
        .idf_build_step = idf_build_step,
        .flash_step = flash_step,
        .monitor_step = monitor_step,
        .flash_monitor_step = flash_monitor_step,
    };
}

pub fn registerExternalApp(b: *std.Build, options: RegisterExternalOptions) Registration {
    const extra_component_dirs = resolveExternalExtraComponentDirs(b, options);

    const board_profile_name = deriveBoardProfileName(options.board_file);
    const sdkconfig_output_file = joinPath(b, options.build_dir, "sdkconfig.generated");
    const partition_file_name = b.fmt(
        "partitions.generated.{x}.csv",
        .{std.hash.Wyhash.hash(0, board_profile_name)},
    );
    const generated_partition_file = joinPath(b, options.build_dir, partition_file_name);
    const project_rel_dir = joinPath(b, options.build_dir, "idf_project");
    const project_main_rel_dir = joinPath(b, project_rel_dir, "main");
    const zig_entry_library_rel_file = joinPath(b, project_main_rel_dir, "zig_entry.a");
    const zig_entry_library_name = if (options.link_zig_entry_library) "zig_entry.a" else "";

    const executable: ?*std.Build.Step.Compile = if (options.compile_check_with_idf_module) blk: {
        const idf_module = resolveIdfModule(b, .{
            .target = options.target,
            .optimize = options.optimize,
            .app_name = options.app_name,
            .app_dir = options.app_root,
            .app_entry = options.app_entry,
            .espz_root = options.espz_root,
            .runtime = .{
                .idf_py = "idf.py",
                .chip = "esp32s3",
                .port = null,
                .baud = 0,
            },
        });

        const entry_path = joinPath(b, options.app_root, options.app_entry);
        const app_imports = buildAppImports(b, idf_module, null);

        const app_root_module = b.createModule(.{
            .root_source_file = b.path(entry_path),
            .target = options.target,
            .optimize = options.optimize,
            .link_libc = true,
            .imports = app_imports,
        });

        const compile = b.addLibrary(.{
            .linkage = .static,
            .name = options.app_name,
            .root_module = app_root_module,
        });

        if (options.install_artifact) {
            b.installArtifact(compile);
        }
        break :blk compile;
    } else null;

    const sdkconfig_step = registerSdkconfigStep(
        b,
        options.app_name,
        options.app_root,
        .{
            .output_file = sdkconfig_output_file,
            .partition_file = generated_partition_file,
            .partition_file_for_idf = b.fmt("../{s}", .{partition_file_name}),
            .board_file = options.board_file,
        },
        options.espz_root,
        options.expose_prefixed_steps,
    );

    const project_step = registerExternalProjectScaffoldStep(
        b,
        options.app_name,
        options.app_root,
        project_rel_dir,
        zig_entry_library_name,
        options.espz_root,
        options.expose_prefixed_steps,
    );

    const zig_entry_library_step = if (options.link_zig_entry_library)
        registerExternalZigLibraryStep(
            b,
            options.app_name,
            options.app_root,
            options.app_entry,
            zig_entry_library_rel_file,
            options.runtime.zig_bin,
            options.zig_target,
            options.zig_cpu,
            options.optimize,
            options.espz_root,
            options.board_file,
            options.expose_prefixed_steps,
        )
    else
        null;
    if (zig_entry_library_step) |step| {
        step.dependOn(project_step);
    }

    const app_main_step = registerAppMainGenerationStep(
        b,
        options.app_name,
        options.app_root,
        .{
            .output_file = joinPath(b, project_main_rel_dir, "app_main.generated.c"),
            .delegate_symbol = options.entry_symbol,
        },
        options.espz_root,
        options.expose_prefixed_steps,
    );
    app_main_step.dependOn(project_step);

    const runtime = RuntimeOptions{
        .idf_py = if (options.runtime.esp_idf) |root| idfPyPath(b, root) else "idf.py",
        .chip = "",
        .port = options.runtime.port,
        .baud = 0,
        .timeout = options.runtime.timeout,
    };

    const required_env_check_run = registerRequiredEnvCheckStepWithRoot(
        b,
        options.app_name,
        options.espz_root,
    );
    if (options.runtime.esp_idf) |root| {
        required_env_check_run.setEnvironmentVariable("ESP_IDF", root);
    }

    const sdkconfig_arg = "../sdkconfig.generated";
    const idf_build_arg = "../idf";
    const idf_project_dir = joinPath(b, options.app_root, project_rel_dir);

    const reconfigure_cmd = addIdfPyBaseCommand(
        b,
        runtime,
        idf_project_dir,
        sdkconfig_arg,
        board_profile_name,
        idf_build_arg,
        extra_component_dirs,
    );
    if (options.runtime.esp_idf) |root| {
        reconfigure_cmd.setEnvironmentVariable("ESP_IDF", root);
    }
    reconfigure_cmd.addArg("reconfigure");
    reconfigure_cmd.step.dependOn(&required_env_check_run.step);
    reconfigure_cmd.step.dependOn(sdkconfig_step);
    reconfigure_cmd.step.dependOn(project_step);
    reconfigure_cmd.step.dependOn(app_main_step);

    const configure_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            b.fmt("{s}-configure", .{options.app_name}),
            b.fmt("Run idf.py reconfigure for {s}", .{options.app_name}),
        );
        step.dependOn(&reconfigure_cmd.step);
        break :blk step;
    } else &reconfigure_cmd.step;

    const idf_build_cmd = addIdfPyBaseCommand(
        b,
        runtime,
        idf_project_dir,
        sdkconfig_arg,
        board_profile_name,
        idf_build_arg,
        extra_component_dirs,
    );
    if (options.runtime.esp_idf) |root| {
        idf_build_cmd.setEnvironmentVariable("ESP_IDF", root);
    }
    idf_build_cmd.addArg("build");
    idf_build_cmd.step.dependOn(&reconfigure_cmd.step);
    if (executable) |compile| {
        idf_build_cmd.step.dependOn(&compile.step);
    }
    if (zig_entry_library_step) |step| {
        idf_build_cmd.step.dependOn(step);
    }

    const idf_build_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            b.fmt("{s}-idf-build", .{options.app_name}),
            b.fmt("Run idf.py build for {s}", .{options.app_name}),
        );
        step.dependOn(&idf_build_cmd.step);
        break :blk step;
    } else &idf_build_cmd.step;

    const build_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            options.app_name,
            b.fmt("Build {s} example", .{options.app_name}),
        );
        if (executable) |compile| {
            step.dependOn(&compile.step);
        } else {
            step.dependOn(&idf_build_cmd.step);
        }
        break :blk step;
    } else if (options.unprefixed_step_profile == .runtime_only)
        &idf_build_cmd.step
    else if (executable) |compile|
        &compile.step
    else
        &idf_build_cmd.step;

    const flash_cmd = addIdfPyBaseCommand(
        b,
        runtime,
        idf_project_dir,
        sdkconfig_arg,
        board_profile_name,
        idf_build_arg,
        extra_component_dirs,
    );
    if (options.runtime.esp_idf) |root| {
        flash_cmd.setEnvironmentVariable("ESP_IDF", root);
    }
    addExternalSerialArgs(flash_cmd, options.runtime.port);
    flash_cmd.addArg("flash");
    flash_cmd.step.dependOn(&idf_build_cmd.step);

    const flash_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            b.fmt("{s}-flash", .{options.app_name}),
            b.fmt("Flash {s} with idf.py", .{options.app_name}),
        );
        step.dependOn(&flash_cmd.step);
        break :blk step;
    } else &flash_cmd.step;

    const monitor_cmd = addIdfPyMonitorCommand(
        b,
        runtime,
        idf_project_dir,
        sdkconfig_arg,
        board_profile_name,
        idf_build_arg,
        extra_component_dirs,
        options.espz_root,
        false,
    );
    if (options.runtime.esp_idf) |root| {
        monitor_cmd.setEnvironmentVariable("ESP_IDF", root);
    }
    monitor_cmd.step.dependOn(&idf_build_cmd.step);

    const monitor_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            b.fmt("{s}-monitor", .{options.app_name}),
            b.fmt("Monitor {s} with idf.py", .{options.app_name}),
        );
        step.dependOn(&monitor_cmd.step);
        break :blk step;
    } else &monitor_cmd.step;

    const flash_monitor_cmd = addIdfPyMonitorCommand(
        b,
        runtime,
        idf_project_dir,
        sdkconfig_arg,
        board_profile_name,
        idf_build_arg,
        extra_component_dirs,
        options.espz_root,
        true,
    );
    if (options.runtime.esp_idf) |root| {
        flash_monitor_cmd.setEnvironmentVariable("ESP_IDF", root);
    }
    flash_monitor_cmd.step.dependOn(&idf_build_cmd.step);

    const flash_monitor_step: *std.Build.Step = if (options.expose_prefixed_steps) blk: {
        const step = b.step(
            b.fmt("{s}-flash-monitor", .{options.app_name}),
            b.fmt("Flash and monitor {s} with idf.py", .{options.app_name}),
        );
        step.dependOn(&flash_monitor_cmd.step);
        break :blk step;
    } else &flash_monitor_cmd.step;

    if (options.expose_unprefixed_steps) {
        exposeAliasStep(b, "build", "Build default app", build_step);
        switch (options.unprefixed_step_profile) {
            .full => {
                exposeAliasStep(b, "sdkconfig", "Generate default app sdkconfig", sdkconfig_step);
                exposeAliasStep(b, "gen-main-c", "Generate default app app_main C shim", app_main_step);
                exposeAliasStep(b, "configure", "Run default app configure", configure_step);
                exposeAliasStep(b, "idf-build", "Run default app idf.py build", idf_build_step);
                exposeAliasStep(b, "flash", "Flash default app", flash_step);
                exposeAliasStep(b, "monitor", "Monitor default app", monitor_step);
                exposeAliasStep(b, "flash-monitor", "Flash and monitor default app", flash_monitor_step);
            },
            .runtime_only => {
                exposeAliasStep(b, "flash", "Flash default app", flash_step);
                exposeAliasStep(b, "monitor", "Monitor default app", monitor_step);
                exposeAliasStep(b, "flash-monitor", "Flash and monitor default app", flash_monitor_step);
            },
        }
    }

    return .{
        .executable = executable,
        .build_step = build_step,
        .sdkconfig_step = sdkconfig_step,
        .app_main_step = app_main_step,
        .configure_step = configure_step,
        .idf_build_step = idf_build_step,
        .flash_step = flash_step,
        .monitor_step = monitor_step,
        .flash_monitor_step = flash_monitor_step,
    };
}

fn registerAppMainGenerationStep(
    b: *std.Build,
    app_name: []const u8,
    app_dir: []const u8,
    options: AutoAppMainOptions,
    espz_root: ?std.Build.LazyPath,
    expose_named_step: bool,
) *std.Build.Step {
    const generator_root_module = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "idf/build/generate_app_main.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const generator = b.addExecutable(.{
        .name = b.fmt("{s}_app_main_generator", .{app_name}),
        .root_module = generator_root_module,
    });

    const run_generator = b.addRunArtifact(generator);
    run_generator.setCwd(b.path(app_dir));
    run_generator.addArg(options.output_file);
    run_generator.addArg(options.delegate_symbol);

    if (expose_named_step) {
        const app_main_step = b.step(
            b.fmt("{s}-gen-main-c", .{app_name}),
            b.fmt("Generate app_main C shim for {s}", .{app_name}),
        );
        app_main_step.dependOn(&run_generator.step);
        return app_main_step;
    }
    return &run_generator.step;
}

fn registerSdkconfigStep(
    b: *std.Build,
    app_name: []const u8,
    app_dir: []const u8,
    options: SdkconfigOptions,
    espz_root: ?std.Build.LazyPath,
    expose_named_step: bool,
) *std.Build.Step {
    const idf_sdkconfig = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "idf/sdkconfig/root.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const sdkconfig_modules = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "src/sdkconfig.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
        .imports = &.{
            .{ .name = "idf_sdkconfig", .module = idf_sdkconfig },
        },
    });

    const idf_partition = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "idf/partition/root.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const board_root = joinPath(b, app_dir, options.board_file);
    const app_board_module = b.createModule(.{
        .root_source_file = b.path(board_root),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
        .imports = &.{
            .{ .name = "sdkconfig_modules", .module = sdkconfig_modules },
            .{ .name = "idf_partition", .module = idf_partition },
        },
    });

    const generator_root_module = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "idf/sdkconfig/generator.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
        .imports = &.{
            .{ .name = "app_sdkconfig_profile", .module = app_board_module },
            .{ .name = "sdkconfig_modules", .module = sdkconfig_modules },
            .{ .name = "idf_partition", .module = idf_partition },
        },
    });

    const generator = b.addExecutable(.{
        .name = b.fmt("{s}_sdkconfig_generator", .{app_name}),
        .root_module = generator_root_module,
    });

    const run_generator = b.addRunArtifact(generator);
    run_generator.setCwd(b.path(app_dir));
    run_generator.addArg(options.output_file);
    run_generator.addArg(options.partition_file);
    run_generator.addArg(options.partition_file_for_idf orelse options.partition_file);

    if (expose_named_step) {
        const sdkconfig_step = b.step(
            b.fmt("{s}-sdkconfig", .{app_name}),
            b.fmt("Generate final sdkconfig for {s}", .{app_name}),
        );
        sdkconfig_step.dependOn(&run_generator.step);
        return sdkconfig_step;
    }
    return &run_generator.step;
}

fn registerExternalProjectScaffoldStep(
    b: *std.Build,
    app_name: []const u8,
    app_root: []const u8,
    project_dir: []const u8,
    zig_entry_library_name: []const u8,
    espz_root: ?std.Build.LazyPath,
    expose_named_step: bool,
) *std.Build.Step {
    const runtime_sources_module = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "src/cmake.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const generator_root_module = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "idf/build/generate_external_project.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
        .imports = &.{
            .{ .name = "espz_runtime_sources", .module = runtime_sources_module },
        },
    });

    const generator = b.addExecutable(.{
        .name = b.fmt("{s}_idf_project_generator", .{app_name}),
        .root_module = generator_root_module,
    });

    const run_generator = b.addRunArtifact(generator);
    run_generator.setCwd(b.path(app_root));
    run_generator.addArg(project_dir);
    run_generator.addArg(app_name);
    run_generator.addArg(zig_entry_library_name);

    if (expose_named_step) {
        const project_step = b.step(
            b.fmt("{s}-gen-idf-project", .{app_name}),
            b.fmt("Generate temporary IDF project for {s}", .{app_name}),
        );
        project_step.dependOn(&run_generator.step);
        return project_step;
    }
    return &run_generator.step;
}

fn registerExternalZigLibraryStep(
    b: *std.Build,
    app_name: []const u8,
    app_root: []const u8,
    source_file: []const u8,
    output_file: []const u8,
    zig_bin: ?[]const u8,
    zig_target: []const u8,
    zig_cpu: ?[]const u8,
    optimize: std.builtin.OptimizeMode,
    espz_root_for_zig_deps: ?std.Build.LazyPath,
    board_file_for_zig_deps: ?[]const u8,
    expose_named_step: bool,
) *std.Build.Step {
    const cmd = b.addSystemCommand(&.{zig_bin orelse "zig"});
    cmd.setCwd(b.path(app_root));
    cmd.addArg("build-lib");
    cmd.addArgs(&.{ "-target", zig_target });
    if (zig_cpu) |cpu| {
        cmd.addArg(b.fmt("-mcpu={s}", .{cpu}));
    }
    cmd.addArg(zigOptimizeFlag(optimize));
    cmd.addArg(b.fmt("-femit-bin={s}", .{output_file}));

    if (espz_root_for_zig_deps != null or board_file_for_zig_deps != null) {
        if (board_file_for_zig_deps != null) {
            cmd.addArgs(&.{ "--dep", "board_pins" });
        }
        if (espz_root_for_zig_deps != null) {
            cmd.addArgs(&.{ "--dep", "esp_lcd" });
            cmd.addArgs(&.{ "--dep", "esp_wifi" });
            cmd.addArgs(&.{ "--dep", "bt" });
            cmd.addArgs(&.{ "--dep", "freertos" });
            cmd.addArgs(&.{ "--dep", "esp_rom" });
            cmd.addArgs(&.{ "--dep", "newlib" });
            cmd.addArgs(&.{ "--dep", "nvs_flash" });
            cmd.addArgs(&.{ "--dep", "heap" });
            cmd.addArgs(&.{ "--dep", "esp_driver_i2c" });
            cmd.addArgs(&.{ "--dep", "esp_driver_ledc" });
            cmd.addArgs(&.{ "--dep", "esp_adc" });
        }
        cmd.addArg(b.fmt("-Mroot={s}", .{source_file}));
        if (board_file_for_zig_deps) |bf| {
            cmd.addArg(b.fmt("-Mboard_pins={s}", .{bf}));
        }
        if (espz_root_for_zig_deps) |root| {
            cmd.addPrefixedFileArg("-Mesp_lcd=", root.path(b, "src/esp_lcd/root.zig"));
            cmd.addPrefixedFileArg("-Mesp_wifi=", root.path(b, "src/esp_wifi/root.zig"));
            cmd.addPrefixedFileArg("-Mbt=", root.path(b, "src/bt/root.zig"));
            cmd.addPrefixedFileArg("-Mfreertos=", root.path(b, "src/freertos/root.zig"));
            cmd.addPrefixedFileArg("-Mesp_rom=", root.path(b, "src/esp_rom/root.zig"));
            cmd.addPrefixedFileArg("-Mnewlib=", root.path(b, "src/newlib/root.zig"));
            cmd.addPrefixedFileArg("-Mnvs_flash=", root.path(b, "src/nvs_flash/root.zig"));
            cmd.addPrefixedFileArg("-Mheap=", root.path(b, "src/heap/root.zig"));
            cmd.addPrefixedFileArg("-Mesp_driver_i2c=", root.path(b, "src/esp_driver_i2c/root.zig"));
            cmd.addPrefixedFileArg("-Mesp_driver_ledc=", root.path(b, "src/esp_driver_ledc/root.zig"));
            cmd.addPrefixedFileArg("-Mesp_adc=", root.path(b, "src/esp_adc/root.zig"));
        }
    } else {
        cmd.addArg(source_file);
    }

    if (expose_named_step) {
        const step = b.step(
            b.fmt("{s}-zig-lib", .{app_name}),
            b.fmt("Build target Zig static library for {s}", .{app_name}),
        );
        step.dependOn(&cmd.step);
        return step;
    }
    return &cmd.step;
}

fn zigOptimizeFlag(optimize: std.builtin.OptimizeMode) []const u8 {
    return switch (optimize) {
        .Debug => "-ODebug",
        .ReleaseSafe => "-OReleaseSafe",
        .ReleaseFast => "-OReleaseFast",
        .ReleaseSmall => "-OReleaseSmall",
    };
}

fn resolveIdfModule(b: *std.Build, options: RegisterOptions) *std.Build.Module {
    if (options.idf_module) |module| {
        return module;
    }

    const root_source: ?[]const u8 = if (options.idf_root_source) |source|
        source
    else if (options.espz_root != null)
        @as([]const u8, "src/component.zig")
    else
        null;

    if (root_source) |source| {
        const idf_sdkconfig = b.createModule(.{
            .root_source_file = espzPath(b, options.espz_root, "idf/sdkconfig/root.zig"),
            .target = options.target,
            .optimize = options.optimize,
        });

        return b.createModule(.{
            .root_source_file = espzPath(b, options.espz_root, source),
            .target = options.target,
            .optimize = options.optimize,
            .link_libc = options.link_libc,
            .imports = &.{
                .{ .name = "idf_sdkconfig", .module = idf_sdkconfig },
            },
        });
    }

    @panic("registerAppWorkflow requires idf_module, idf_root_source, or espz_root");
}

fn resolveExternalExtraComponentDirs(
    _: *std.Build,
    options: RegisterExternalOptions,
) []const std.Build.LazyPath {
    return options.extra_component_dirs;
}

fn buildAppImports(
    b: *std.Build,
    idf_module: *std.Build.Module,
    app_options_module: ?*std.Build.Module,
) []const std.Build.Module.Import {
    if (app_options_module) |module| {
        const imports = b.allocator.alloc(std.Build.Module.Import, 2) catch @panic("OOM allocating app imports");
        imports[0] = .{ .name = "idf", .module = idf_module };
        imports[1] = .{ .name = "app_options", .module = module };
        return imports;
    }

    const imports = b.allocator.alloc(std.Build.Module.Import, 1) catch @panic("OOM allocating app imports");
    imports[0] = .{ .name = "idf", .module = idf_module };
    return imports;
}

fn addIdfPyBaseCommand(
    b: *std.Build,
    runtime: RuntimeOptions,
    app_dir: []const u8,
    sdkconfig_file: ?[]const u8,
    board_profile_name: ?[]const u8,
    idf_build_dir: ?[]const u8,
    extra_component_dirs: []const std.Build.LazyPath,
) *std.Build.Step.Run {
    const cmd = b.addSystemCommand(&.{"python3"});
    cmd.setCwd(b.path(app_dir));
    cmd.addArg(runtime.idf_py);
    if (idf_build_dir) |build_dir| {
        cmd.addArgs(&.{ "-B", build_dir });
    }
    if (sdkconfig_file) |file_name| {
        cmd.addArg(b.fmt("-DSDKCONFIG={s}", .{file_name}));
        cmd.setEnvironmentVariable("SDKCONFIG", file_name);
    }
    if (board_profile_name) |board_name| {
        cmd.setEnvironmentVariable("ESPZ_BOARD_PROFILE", board_name);
    }
    addExtraComponentDirsArg(cmd, extra_component_dirs);
    return cmd;
}

fn addIdfPyMonitorCommand(
    b: *std.Build,
    runtime: RuntimeOptions,
    app_dir: []const u8,
    sdkconfig_file: ?[]const u8,
    board_profile_name: ?[]const u8,
    idf_build_dir: ?[]const u8,
    extra_component_dirs: []const std.Build.LazyPath,
    espz_root: ?std.Build.LazyPath,
    include_flash: bool,
) *std.Build.Step.Run {
    const cmd = b.addSystemCommand(&.{"python3"});
    cmd.setCwd(b.path(app_dir));
    cmd.addFileArg(espzPath(b, espz_root, "idf/build/pty_monitor.py"));
    if (runtime.timeout) |t| {
        cmd.addArg(b.fmt("--timeout={d}", .{t}));
    }
    cmd.addArg("python3");
    cmd.addArg(runtime.idf_py);

    if (idf_build_dir) |build_dir| {
        cmd.addArgs(&.{ "-B", build_dir });
    }
    if (sdkconfig_file) |file_name| {
        cmd.addArg(b.fmt("-DSDKCONFIG={s}", .{file_name}));
        cmd.setEnvironmentVariable("SDKCONFIG", file_name);
    }
    if (board_profile_name) |board_name| {
        cmd.setEnvironmentVariable("ESPZ_BOARD_PROFILE", board_name);
    }
    addExtraComponentDirsArg(cmd, extra_component_dirs);

    addSerialArgs(cmd, runtime);
    if (include_flash) {
        cmd.addArg("flash");
    }
    cmd.addArg("monitor");
    return cmd;
}

fn registerRequiredEnvCheckStep(b: *std.Build, app_name: []const u8) *std.Build.Step.Run {
    const checker_root_module = b.createModule(.{
        .root_source_file = b.path("idf/build/check_required_env.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const checker = b.addExecutable(.{
        .name = b.fmt("{s}_check_required_env", .{app_name}),
        .root_module = checker_root_module,
    });

    return b.addRunArtifact(checker);
}

fn registerRequiredEnvCheckStepWithRoot(
    b: *std.Build,
    app_name: []const u8,
    espz_root: ?std.Build.LazyPath,
) *std.Build.Step.Run {
    const checker_root_module = b.createModule(.{
        .root_source_file = espzPath(b, espz_root, "idf/build/check_required_env.zig"),
        .target = b.graph.host,
        .optimize = .ReleaseSafe,
    });

    const checker = b.addExecutable(.{
        .name = b.fmt("{s}_check_required_env", .{app_name}),
        .root_module = checker_root_module,
    });

    return b.addRunArtifact(checker);
}

fn addSerialArgs(cmd: *std.Build.Step.Run, runtime: RuntimeOptions) void {
    if (runtime.port) |port| {
        cmd.addArgs(&.{ "-p", port });
    }
    if (runtime.baud != 0) {
        cmd.addArgs(&.{ "-b", cmd.step.owner.fmt("{d}", .{runtime.baud}) });
    }
}

fn addExternalSerialArgs(cmd: *std.Build.Step.Run, port: ?[]const u8) void {
    if (port) |value| {
        cmd.addArgs(&.{ "-p", value });
    }
}

fn exposeAliasStep(
    b: *std.Build,
    alias_name: []const u8,
    description: []const u8,
    dependency: *std.Build.Step,
) void {
    const alias_step = b.step(alias_name, description);
    alias_step.dependOn(dependency);
}

fn addExtraComponentDirsArg(cmd: *std.Build.Step.Run, extra_component_dirs: []const std.Build.LazyPath) void {
    if (extra_component_dirs.len == 0) {
        return;
    }

    const resolved = cmd.step.owner.allocator.alloc([]const u8, extra_component_dirs.len) catch @panic("OOM");
    for (extra_component_dirs, 0..) |lazy, idx| {
        resolved[idx] = lazy.getPath2(cmd.step.owner, &cmd.step);
    }
    const joined = std.mem.join(cmd.step.owner.allocator, ";", resolved) catch @panic("OOM");
    cmd.addArg(cmd.step.owner.fmt("-DEXTRA_COMPONENT_DIRS={s}", .{joined}));
}

fn idfPyPath(b: *std.Build, esp_idf: []const u8) []const u8 {
    return b.pathJoin(&.{ esp_idf, "tools", "idf.py" });
}

fn joinSemicolonList(b: *std.Build, values: []const []const u8) []const u8 {
    if (values.len == 0) {
        return "";
    }
    return std.mem.join(b.allocator, ";", values) catch @panic("OOM");
}

fn deriveBoardProfileName(board_file: []const u8) []const u8 {
    const base = std.fs.path.basename(board_file);
    if (std.mem.endsWith(u8, base, ".zig")) {
        return base[0 .. base.len - 4];
    }
    return base;
}

fn getEnvOrNull(b: *std.Build, name: []const u8) ?[]const u8 {
    const value = std.process.getEnvVarOwned(b.allocator, name) catch return null;
    const trimmed = std.mem.trim(u8, value, " \t\r\n");
    if (trimmed.len == 0) {
        return null;
    }
    return trimmed;
}

fn espzPath(b: *std.Build, root: ?std.Build.LazyPath, relative: []const u8) std.Build.LazyPath {
    if (root) |lazy| {
        return lazy.path(b, relative);
    }
    return b.path(relative);
}

fn joinPath(b: *std.Build, dir_path: []const u8, child_path: []const u8) []const u8 {
    if (dir_path.len == 0 or std.mem.eql(u8, dir_path, ".")) {
        return child_path;
    }
    return b.pathJoin(&.{ dir_path, child_path });
}
