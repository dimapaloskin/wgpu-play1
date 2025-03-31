const std = @import("std");
const c = @import("../bindings.zig").c;

const Device = @import("Device.zig");
const CommandBuffer = @import("CommandBuffer.zig");

const Self = @This();

queue: c.WGPUQueue,

pub inline fn init(device: Device) Self {
    return Self{
        .queue = c.wgpuDeviceGetQueue(device.device),
    };
}

pub inline fn deinit(self: Self) void {
    std.log.debug("Queue deinit", .{});
    c.wgpuQueueRelease(self.queue);
}

pub inline fn submit(self: Self, command_count: usize, commands: CommandBuffer) void {
    c.wgpuQueueSubmit(self.queue, command_count, &commands.command_buffer);
}
