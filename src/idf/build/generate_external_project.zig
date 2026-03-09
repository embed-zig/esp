const std = @import("std");
const sources = @import("idf").cmake;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 4) {
        std.debug.print(
            "usage: {s} <project_dir> <project_name> <zig_entry_library_name> [extra_zig_library_name...]\n",
            .{args[0]},
        );
        return error.InvalidArguments;
    }

    const project_dir = args[1];
    const project_name = args[2];
    const zig_entry_library_name = args[3];
    const extra_zig_library_names = args[4..];

    try std.fs.cwd().makePath(project_dir);
    const main_dir = try std.fs.path.join(allocator, &.{ project_dir, "main" });
    defer allocator.free(main_dir);
    try std.fs.cwd().makePath(main_dir);

    try writeEmbeddedFiles(allocator, main_dir);

    const root_path = try std.fs.path.join(allocator, &.{ project_dir, "CMakeLists.txt" });
    defer allocator.free(root_path);
    const main_path = try std.fs.path.join(allocator, &.{ project_dir, "main", "CMakeLists.txt" });
    defer allocator.free(main_path);

    const root_content = try std.fmt.allocPrint(
        allocator,
        "cmake_minimum_required(VERSION 3.16)\n\n" ++
            "include($ENV{{IDF_PATH}}/tools/cmake/project.cmake)\n" ++
            "project({s})\n",
        .{project_name},
    );
    defer allocator.free(root_content);

    const main_content = try buildMainCmake(
        allocator,
        project_dir,
        zig_entry_library_name,
        extra_zig_library_names,
    );
    defer allocator.free(main_content);

    try std.fs.cwd().writeFile(.{
        .sub_path = root_path,
        .data = root_content,
    });

    try std.fs.cwd().writeFile(.{
        .sub_path = main_path,
        .data = main_content,
    });

    const component_yml = try buildComponentYml(allocator);
    if (component_yml) |yml_content| {
        defer allocator.free(yml_content);
        const yml_path = try std.fs.path.join(allocator, &.{ project_dir, "main", "idf_component.yml" });
        defer allocator.free(yml_path);
        try std.fs.cwd().writeFile(.{
            .sub_path = yml_path,
            .data = yml_content,
        });
    }
}

fn writeEmbeddedFiles(allocator: std.mem.Allocator, main_dir: []const u8) !void {
    inline for (sources.modules) |entry| {
        const mod_dir = try std.fs.path.join(allocator, &.{ main_dir, "espz_rt", entry.module_name });
        defer allocator.free(mod_dir);
        try std.fs.cwd().makePath(mod_dir);

        for (entry.embedded_files) |file| {
            const file_path = try std.fs.path.join(allocator, &.{ mod_dir, file.path });
            defer allocator.free(file_path);
            try std.fs.cwd().writeFile(.{
                .sub_path = file_path,
                .data = file.content,
            });
        }
    }
}

fn buildMainCmake(
    allocator: std.mem.Allocator,
    project_dir: []const u8,
    zig_entry_library_name: []const u8,
    extra_zig_library_names: []const []const u8,
) ![]u8 {
    _ = project_dir;

    var out = std.array_list.Managed(u8).init(allocator);
    defer out.deinit();

    try out.appendSlice(
        "set(ESPZ_GENERATED_APP_MAIN_SRC \"${CMAKE_CURRENT_LIST_DIR}/app_main.generated.c\")\n\n" ++
            "idf_component_register(\n" ++
            "    SRCS\n" ++
            "        \"${ESPZ_GENERATED_APP_MAIN_SRC}\"\n" ++
            "    INCLUDE_DIRS\n" ++
            "        \".\"\n" ++
            ")\n\n",
    );

    try appendEspzRuntimeShimsBlock(&out);

    const zig_entry_library = std.mem.trim(u8, zig_entry_library_name, " \t\r\n");
    if (zig_entry_library.len != 0) {
        try out.appendSlice("set(ESPZ_ZIG_ENTRY_LIB \"${CMAKE_CURRENT_LIST_DIR}/");
        try out.appendSlice(zig_entry_library);
        try out.appendSlice("\")\n");
    }
    if (extra_zig_library_names.len > 0) {
        try out.appendSlice("set(ESPZ_EXTRA_ZIG_LIBS\n");
        for (extra_zig_library_names) |name| {
            const trimmed = std.mem.trim(u8, name, " \t\r\n");
            if (trimmed.len == 0) continue;
            try out.appendSlice("    \"${CMAKE_CURRENT_LIST_DIR}/");
            try out.appendSlice(trimmed);
            try out.appendSlice("\"\n");
        }
        try out.appendSlice(")\n");
    }
    if (zig_entry_library.len != 0 or extra_zig_library_names.len > 0) {
        try out.appendSlice("target_link_libraries(${COMPONENT_LIB} PRIVATE\n");
        if (zig_entry_library.len != 0) {
            try out.appendSlice("    \"${ESPZ_ZIG_ENTRY_LIB}\"\n");
        }
        if (extra_zig_library_names.len > 0) {
            try out.appendSlice("    ${ESPZ_EXTRA_ZIG_LIBS}\n");
        }
        try out.appendSlice("    espz_runtime_shims)\n\n");
    }

    try out.appendSlice(
        "if(DEFINED ENV{ESPZ_BOARD_PROFILE})\n" ++
            "    target_compile_definitions(\n" ++
            "        ${COMPONENT_LIB}\n" ++
            "        PRIVATE ESPZ_BOARD_PROFILE=\"$ENV{ESPZ_BOARD_PROFILE}\"\n" ++
            "    )\n" ++
            "endif()\n",
    );

    return out.toOwnedSlice();
}

fn appendEspzRuntimeShimsBlock(out: *std.array_list.Managed(u8)) !void {
    try out.appendSlice("add_library(espz_runtime_shims STATIC\n");
    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard == null and hasCSources(entry)) {
            try appendModuleCSources(out, entry);
        }
    }
    try out.appendSlice(")\n");

    try out.appendSlice("target_include_directories(espz_runtime_shims PRIVATE\n");
    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard == null and hasCSources(entry)) {
            try appendModuleIncludeDir(out, entry);
        }
    }
    try out.appendSlice(")\n");

    try out.appendSlice("target_link_libraries(espz_runtime_shims PRIVATE\n");
    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard == null and hasCSources(entry)) {
            try appendModuleLinkLibs(out, entry);
        }
    }
    try out.appendSlice(")\n\n");

    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard != null and hasCSources(entry)) {
            try out.appendSlice("if(");
            try out.appendSlice(entry.sdkconfig_guard.?);
            try out.appendSlice(")\n");
            try out.appendSlice("    target_sources(espz_runtime_shims PRIVATE\n");
            try appendModuleCSources(out, entry);
            try out.appendSlice("    )\n");
            try out.appendSlice("    target_include_directories(espz_runtime_shims PRIVATE\n");
            try appendModuleIncludeDir(out, entry);
            try out.appendSlice("    )\n");
            try out.appendSlice("    target_link_libraries(espz_runtime_shims PRIVATE\n");
            try appendModuleLinkLibs(out, entry);
            try out.appendSlice("    )\n");
            try out.appendSlice("endif()\n\n");
        }
    }
}

fn appendModuleCSources(out: *std.array_list.Managed(u8), comptime entry: sources.Entry) !void {
    for (entry.embedded_files) |file| {
        if (std.mem.endsWith(u8, file.path, ".c")) {
            try out.appendSlice("        \"${CMAKE_CURRENT_LIST_DIR}/espz_rt/");
            try out.appendSlice(entry.module_name);
            try out.appendSlice("/");
            try out.appendSlice(file.path);
            try out.appendSlice("\"\n");
        }
    }
}

fn appendModuleIncludeDir(out: *std.array_list.Managed(u8), comptime entry: sources.Entry) !void {
    try out.appendSlice("        \"${CMAKE_CURRENT_LIST_DIR}/espz_rt/");
    try out.appendSlice(entry.module_name);
    try out.appendSlice("\"\n");
}

fn appendModuleLinkLibs(out: *std.array_list.Managed(u8), comptime entry: sources.Entry) !void {
    for (entry.idf_requires) |req| {
        try out.appendSlice("        idf::");
        try out.appendSlice(req);
        try out.appendSlice("\n");
    }
}

fn hasCSources(comptime entry: sources.Entry) bool {
    for (entry.embedded_files) |file| {
        if (std.mem.endsWith(u8, file.path, ".c")) return true;
    }
    return false;
}

fn buildComponentYml(allocator: std.mem.Allocator) !?[]u8 {
    comptime var has_any = false;
    inline for (sources.modules) |entry| {
        if (comptime entry.idf_external_components.len > 0) {
            has_any = true;
        }
    }
    if (!has_any) return null;

    var out = std.array_list.Managed(u8).init(allocator);
    defer out.deinit();

    try out.appendSlice("dependencies:\n");
    inline for (sources.modules) |entry| {
        if (comptime entry.idf_external_components.len > 0) {
            for (entry.idf_external_components) |dep| {
                try out.appendSlice("  ");
                try out.appendSlice(dep.name);
                try out.appendSlice(": \"");
                try out.appendSlice(dep.version);
                try out.appendSlice("\"\n");
            }
        }
    }

    const slice = try out.toOwnedSlice();
    return @as(?[]u8, slice);
}
