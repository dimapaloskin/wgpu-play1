const std = @import("std");
const c = @import("../bindings.zig").c;

const Self = @This();

instance: c.WGPUInstance,

pub fn init(desc: *const c.WGPUInstanceDescriptor) !Self {
    return Self{
        .instance = c.wgpuCreateInstance(desc) orelse {
            return error.InstanceCreateFailed;
        },
    };
}

pub inline fn deinit(self: Self) void {
    std.log.debug("Instance deinit", .{});
    c.wgpuInstanceRelease(self.instance);
}
