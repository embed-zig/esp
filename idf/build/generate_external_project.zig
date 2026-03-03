const std = @import("std");
const sources = @import("espz_runtime_sources");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 4) {
        std.debug.print(
            "usage: {s} <project_dir> <project_name> <zig_entry_library_name>\n",
            .{args[0]},
        );
        return error.InvalidArguments;
    }

    const project_dir = args[1];
    const project_name = args[2];
    const zig_entry_library_name = args[3];

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
}

fn writeEmbeddedFiles(allocator: std.mem.Allocator, main_dir: []const u8) !void {
    inline for (sources.modules) |entry| {
        const mod = entry.root;
        const mod_dir = try std.fs.path.join(allocator, &.{ main_dir, "espz_rt", mod.module_name });
        defer allocator.free(mod_dir);
        try std.fs.cwd().makePath(mod_dir);

        inline for (mod.embedded_files) |file| {
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
        try out.appendSlice(
            "target_link_libraries(${COMPONENT_LIB} PRIVATE\n" ++
                "    \"${ESPZ_ZIG_ENTRY_LIB}\" espz_runtime_shims)\n\n",
        );
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
        if (comptime entry.sdkconfig_guard == null and hasCSources(entry.root)) {
            try appendModuleCSources(out, entry.root);
        }
    }
    try out.appendSlice(")\n");

    try out.appendSlice("target_include_directories(espz_runtime_shims PRIVATE\n");
    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard == null and hasCSources(entry.root)) {
            try appendModuleIncludeDir(out, entry.root);
        }
    }
    try out.appendSlice(")\n");

    try out.appendSlice("target_link_libraries(espz_runtime_shims PRIVATE\n");
    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard == null and hasCSources(entry.root)) {
            try appendModuleLinkLibs(out, entry.root);
        }
    }
    try out.appendSlice(")\n\n");

    inline for (sources.modules) |entry| {
        if (comptime entry.sdkconfig_guard != null and hasCSources(entry.root)) {
            try out.appendSlice("if(");
            try out.appendSlice(entry.sdkconfig_guard.?);
            try out.appendSlice(")\n");
            try out.appendSlice("    target_sources(espz_runtime_shims PRIVATE\n");
            try appendModuleCSources(out, entry.root);
            try out.appendSlice("    )\n");
            try out.appendSlice("    target_include_directories(espz_runtime_shims PRIVATE\n");
            try appendModuleIncludeDir(out, entry.root);
            try out.appendSlice("    )\n");
            try out.appendSlice("    target_link_libraries(espz_runtime_shims PRIVATE\n");
            try appendModuleLinkLibs(out, entry.root);
            try out.appendSlice("    )\n");
            try out.appendSlice("endif()\n\n");
        }
    }
}

fn appendModuleCSources(out: *std.array_list.Managed(u8), comptime mod: anytype) !void {
    inline for (mod.embedded_files) |file| {
        if (comptime std.mem.endsWith(u8, file.path, ".c")) {
            try out.appendSlice("        \"${CMAKE_CURRENT_LIST_DIR}/espz_rt/");
            try out.appendSlice(mod.module_name);
            try out.appendSlice("/");
            try out.appendSlice(file.path);
            try out.appendSlice("\"\n");
        }
    }
}

fn appendModuleIncludeDir(out: *std.array_list.Managed(u8), comptime mod: anytype) !void {
    try out.appendSlice("        \"${CMAKE_CURRENT_LIST_DIR}/espz_rt/");
    try out.appendSlice(mod.module_name);
    try out.appendSlice("\"\n");
}

fn appendModuleLinkLibs(out: *std.array_list.Managed(u8), comptime mod: anytype) !void {
    inline for (mod.idf_requires) |req| {
        try out.appendSlice("        idf::");
        try out.appendSlice(req);
        try out.appendSlice("\n");
    }
}

fn hasCSources(comptime mod: anytype) bool {
    inline for (mod.embedded_files) |file| {
        if (comptime std.mem.endsWith(u8, file.path, ".c")) return true;
    }
    return false;
}
