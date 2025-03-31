const c = @import("../bindings.zig").c;

const Encoder = @import("Encoder.zig");

const Self = @This();

command_buffer: c.WGPUCommandBuffer,

pub inline fn init(encoder: Encoder, desc: *const c.WGPUCommandBufferDescriptor) Self {
    return Self{
        .command_buffer = c.wgpuCommandEncoderFinish(encoder.encoder, desc),
    };
}

pub inline fn deinit(self: Self) void {
    c.wgpuCommandBufferRelease(self.command_buffer);
}
