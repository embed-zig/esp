pub const task = @import("task.zig");
pub const sync = @import("sync.zig");
pub const delay = task.delay;
pub const create = task.create;
pub const delete = task.delete;
pub const msToTicks = task.msToTicks;
pub const TickType = task.TickType;
pub const TaskHandle = task.TaskHandle;
pub const TaskEntryFn = task.TaskEntryFn;
pub const CoreId = task.CoreId;
pub const no_affinity = task.no_affinity;
pub const Stack = task.Stack;
pub const CreateConfig = task.CreateConfig;
pub const mallocCapSpiram = task.mallocCapSpiram;
pub const mallocCapInternal = task.mallocCapInternal;
pub const mallocCap8Bit = task.mallocCap8Bit;
pub const defaultPsramCaps = task.defaultPsramCaps;
pub const defaultInternalCaps = task.defaultInternalCaps;

pub const queue = @import("queue.zig");

pub const module_name = "freertos";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "freertos", "heap" };
pub const embedded_files = .{
    .{
        .path = @as([]const u8, "task_helper.c"),
        .content = @embedFile("task_helper.c"),
    },
    .{
        .path = @as([]const u8, "queue_helper.c"),
        .content = @embedFile("queue_helper.c"),
    },
    .{
        .path = @as([]const u8, "sync_helper.c"),
        .content = @embedFile("sync_helper.c"),
    },
    .{
        .path = @as([]const u8, "adf_freertos_patch_compat.c"),
        .content = @embedFile("adf_freertos_patch_compat.c"),
    },
};
