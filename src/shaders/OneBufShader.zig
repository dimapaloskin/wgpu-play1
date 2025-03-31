const c = @import("../bindings.zig").c;

const wg = @import("../wg/wg.zig");

const Self = @This();

pipeline: wg.RenderPipeline,
vertex_buffer: c.WGPUBuffer,

pub inline fn init(device: wg.Device, queue: wg.Queue, format: c.WGPUTextureFormat) !Self {
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

    // zig fmt: off
    const vertex_data = [_]f32{
        -0.5,  -0.5,
        0.5,   -0.5,
        0.0,   0.5,

        -0.55, -0.5,
        -0.05, 0.5,
        -0.55, 0.5,
    };
    // zig fmt: on

    const buffer_desc: c.WGPUBufferDescriptor = .{
        .nextInChain = null,
        .size = vertex_data.len * @sizeOf(f32),
        .usage = c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_Vertex,
        .mappedAtCreation = 0,
    };

    const vertex_buffer = c.wgpuDeviceCreateBuffer(device.device, &buffer_desc);
    c.wgpuQueueWriteBuffer(queue.queue, vertex_buffer, 0, &vertex_data, buffer_desc.size);

    const position_attrib: c.WGPUVertexAttribute = .{
        .shaderLocation = 0,
        .format = c.WGPUVertexFormat_Float32x2,
        .offset = 0,
    };

    const vertex_buffer_layout: c.WGPUVertexBufferLayout = .{
        .attributes = &position_attrib,
        .attributeCount = 1,
        .arrayStride = 2 * @sizeOf(f32),
        .stepMode = c.WGPUVertexStepMode_Vertex,
    };

    const vertex_state: c.WGPUVertexState = .{
        .nextInChain = null,

        .module = shader_module.module,
        .entryPoint = "vs_one_buf",

        .bufferCount = 1,
        .buffers = &vertex_buffer_layout,
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
        .vertex_buffer = vertex_buffer,
    };
}

pub inline fn bufferSize(self: Self) u64 {
    return c.wgpuBufferGetSize(self.vertex_buffer);
}

pub inline fn deinit(self: Self) void {
    c.wgpuBufferRelease(self.vertex_buffer);
    self.pipeline.deinit();
}
