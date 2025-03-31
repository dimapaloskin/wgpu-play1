const c = @import("../bindings.zig").c;

const Self = @This();

view: c.WGPUTextureView,

pub inline fn fromTexture(texture: c.WGPUTexture, desc: *const c.WGPUTextureViewDescriptor) Self {
    return Self{
        .view = c.wgpuTextureCreateView(texture, desc),
    };
}

pub inline fn deinit(self: Self) void {
    c.wgpuTextureViewRelease(self.view);
}
