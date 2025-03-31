const c = @import("../bindings.zig").c;

const Self = @This();

module: c.WGPUShaderModule,

pub inline fn from(module: c.WGPUShaderModule) Self {
    return Self{
        .module = module,
    };
}

pub inline fn deinit(self: Self) void {
    c.wgpuShaderModuleRelease(self.module);
}
