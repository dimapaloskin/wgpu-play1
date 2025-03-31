const std = @import("std");
const bindings = @import("../bindings.zig");
const c = @import("../bindings.zig").c;
const glfwCreateWindowWGPUSurface = @import("../bindings.zig").glfwCreateWindowWGPUSurface;

const Adapter = @import("Adapter.zig");
const Texture = @import("Texture.zig");
const Window = @import("Window.zig");
const Instance = @import("Instance.zig");

const Self = @This();

surface: c.WGPUSurface,

pub inline fn init(instance: *const Instance) !Self {
    return Self{
        // .surface = glfwCreateWindowWGPUSurface(instance.*.instance, window.*.window) orelse {
        //     return error.SurfaceCreateFailed;
        // },
        .surface = bindings.create_window(instance.*.instance),
    };
}

pub inline fn deinit(self: Self) void {
    std.log.debug("Surface deinit", .{});
    c.wgpuSurfaceRelease(self.surface);
}

pub inline fn present(self: Self) void {
    c.wgpuSurfacePresent(self.surface);
}

pub inline fn getCapabilities(self: Self, adapter: Adapter) c.WGPUSurfaceCapabilities {
    var capabilities: c.WGPUSurfaceCapabilities = undefined;
    c.wgpuSurfaceGetCapabilities(self.surface, adapter.adapter, &capabilities);

    return capabilities;
}

pub inline fn getPreferredFormat(self: Self, adapter: Adapter) c.WGPUTextureFormat {
    return self.getCapabilities(adapter).formats[0];
}

pub inline fn configure(self: Self, config: *const c.WGPUSurfaceConfiguration) void {
    c.wgpuSurfaceConfigure(self.surface, config);
}

pub inline fn unconfigure(self: Self) void {
    c.wgpuSurfaceUnconfigure(self.surface);
}

pub fn getCurrentTexture(self: Self) !Texture {
    var surfaceTexture: c.WGPUSurfaceTexture = undefined;
    c.wgpuSurfaceGetCurrentTexture(self.surface, &surfaceTexture);

    if (surfaceTexture.status != c.WGPUSurfaceGetCurrentTextureStatus_Success) {
        return error.SurfaceGetCurrentTextureFailed;
    }

    return Texture.fromTexture(surfaceTexture.texture);
}
