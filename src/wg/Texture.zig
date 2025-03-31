const c = @import("../bindings.zig").c;

const TextureView = @import("TextureView.zig");

const Self = @This();

texture: c.WGPUTexture,

pub inline fn fromTexture(texture: c.WGPUTexture) Self {
    return Self{
        .texture = texture,
    };
}

pub inline fn deinit(self: Self) void {
    c.wgpuTextureRelease(self.texture);
}

pub inline fn getFormat(self: Self) c.WGPUTextureFormat {
    return c.wgpuTextureGetFormat(self.texture);
}

pub inline fn createView(self: Self, desc: *const c.WGPUTextureViewDescriptor) TextureView {
    return TextureView.fromTexture(self.texture, desc);
}
