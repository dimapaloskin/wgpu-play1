const c = @import("../bindings.zig").c;

const wg = @import("../wg/wg.zig");

const Self = @This();

pipeline: wg.RenderPipeline,

pub inline fn init(device: wg.Device, format: c.WGPUTextureFormat) !Self {
    const shader_code = @embedFile("../shader.wgsl");

    const shader_code_desc: c.WGPUShaderModuleWGSLDescriptor = .{
        .chain = .{
            .next = null,
            .sType = c.WGPUSType_ShaderModuleWGSLDescriptor,
        },
        .code = shader_code,
    };

    const shader_desc: c.WGPUShaderModuleDescriptor = .{
        .hintCount = 0,
        .hints = null,
        .label = "Shader",
        .nextInChain = &shader_code_desc.chain,
    };

    const shader_module = try device.createShaderModule(&shader_desc);
    defer c.wgpuShaderModuleRelease(shader_module.module);

    const vertex_state: c.WGPUVertexState = .{
        .nextInChain = null,

        .module = shader_module.module,
        .entryPoint = "vs_no_buffer",

        .bufferCount = 0,
        .buffers = null,
        .constantCount = 0,
        .constants = null,
    };

    const primitive_state: c.WGPUPrimitiveState = .{
        .nextInChain = null,
        .topology = c.WGPUPrimitiveTopology_TriangleList,
        .stripIndexFormat = c.WGPUIndexFormat_Undefined,
        .frontFace = c.WGPUFrontFace_CCW,
        .cullMode = c.WGPUCullMode_None,
    };

    const blend_state: c.WGPUBlendState = .{
        .color = .{
            .srcFactor = c.WGPUBlendFactor_SrcAlpha,
            .dstFactor = c.WGPUBlendFactor_OneMinusSrcAlpha,
            .operation = c.WGPUBlendOperation_Add,
        },
        .alpha = .{
            .srcFactor = c.WGPUBlendFactor_Zero,
            .dstFactor = c.WGPUBlendFactor_One,
            .operation = c.WGPUBlendOperation_Add,
        },
    };

    const target_state: c.WGPUColorTargetState = .{
        .nextInChain = null,
        .format = format,
        .blend = &blend_state,
        .writeMask = c.WGPUColorWriteMask_All,
    };

    const fragment_sate: c.WGPUFragmentState = .{
        .nextInChain = null,

        .module = shader_module.module,
        .entryPoint = "fs_hard_color",

        .constantCount = 0,
        .constants = null,
        .targetCount = 1,
        .targets = &target_state,
    };

    const pipeline_desc: c.WGPURenderPipelineDescriptor = .{
        .label = "NoBuffer Pipeline",
        .nextInChain = null,
        .vertex = vertex_state,
        .primitive = primitive_state,
        .fragment = &fragment_sate,
        .depthStencil = null,
        .multisample = .{
            .count = 1,
            .mask = 0xffffffff,
            .alphaToCoverageEnabled = 0,
        },
        .layout = null,
    };

    const pipeline = try device.createRenderPipeline(&pipeline_desc);

    return Self{
        .pipeline = pipeline,
    };
}

pub inline fn deinit(self: Self) void {
    self.pipeline.deinit();
}
