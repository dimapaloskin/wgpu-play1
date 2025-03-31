const c = @import("../bindings.zig").c;

const Device = @import("Device.zig");
const RenderPass = @import("RenderPass.zig");
const CommandBuffer = @import("CommandBuffer.zig");
const Self = @This();

encoder: c.WGPUCommandEncoder,
device: Device,

pub inline fn init(device: Device, desc: *const c.WGPUCommandEncoderDescriptor) Self {
    return Self{
        .encoder = c.wgpuDeviceCreateCommandEncoder(device.device, desc),
        .device = device,
    };
}

pub inline fn deinit(self: Self) void {
    c.wgpuCommandEncoderRelease(self.encoder);
}

pub inline fn beginRenderPass(self: Self, desc: *const c.WGPURenderPassDescriptor) RenderPass {
    return RenderPass.init(self, desc);
}

pub inline fn finish(self: Self, desc: *const c.WGPUCommandBufferDescriptor) CommandBuffer {
    return CommandBuffer.init(self, desc);
}
