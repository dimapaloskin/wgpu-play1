const c = @import("../bindings.zig").c;

const wg = @import("../wg/wg.zig");

const Self = @This();

pipeline: wg.RenderPipeline,
position_buffer: c.WGPUBuffer,
color_buffer: c.WGPUBuffer,

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
    const position_data = [_]f32{
        -0.5,  -0.5,
        0.5,   -0.5,
        0.0,   0.5,

        -0.55, -0.5,
        -0.05, 0.5,
        -0.55, 0.5,
    };

    const color_data = [_]f32{
         0.0, 0.0, 1.0,
         0.0, 1.0, 0.0,
         1.0, 0.0, 0.0,

        0.1, 0.3, 0.5,
        0.2, 0.5, 0.6,
        0.5, 0.1, 0.5,
    };
    // zig fmt: on

    const position_buffer_desc: c.WGPUBufferDescriptor = .{
        .nextInChain = null,
        .size = position_data.len * @sizeOf(f32),
        .usage = c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_Vertex,
        .mappedAtCreation = 0,
    };

    const position_buffer = c.wgpuDeviceCreateBuffer(device.device, &position_buffer_desc);
    c.wgpuQueueWriteBuffer(queue.queue, position_buffer, 0, &position_data, position_buffer_desc.size);

    const color_buffer_desc: c.WGPUBufferDescriptor = .{
        .nextInChain = null,
        .size = color_data.len * @sizeOf(f32),
        .usage = c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_Vertex,
        .mappedAtCreation = 0,
    };

    const color_buffer = c.wgpuDeviceCreateBuffer(device.device, &color_buffer_desc);
    c.wgpuQueueWriteBuffer(queue.queue, color_buffer, 0, &color_data, color_buffer_desc.size);

    const position_attrib: c.WGPUVertexAttribute = .{
        .shaderLocation = 0,
        .format = c.WGPUVertexFormat_Float32x2,
        .offset = 0,
    };

    const color_attrib: c.WGPUVertexAttribute = .{
        .shaderLocation = 1,
        .format = c.WGPUVertexFormat_Float32x3,
        .offset = 0,
    };

    const position_buffer_layout: c.WGPUVertexBufferLayout = .{
        .attributes = &position_attrib,
        .attributeCount = 1,
        .arrayStride = 2 * @sizeOf(f32),
        .stepMode = c.WGPUVertexStepMode_Vertex,
    };

    const color_buffer_layout: c.WGPUVertexBufferLayout = .{
        .attributes = &color_attrib,
        .attributeCount = 1,
        .arrayStride = 3 * @sizeOf(f32),
        .stepMode = c.WGPUVertexStepMode_Vertex,
    };

    const layouts = [_]c.WGPUVertexBufferLayout{ position_buffer_layout, color_buffer_layout };

    const vertex_state: c.WGPUVertexState = .{
        .nextInChain = null,

        .module = shader_module.module,
        .entryPoint = "vs_inter_buf",

        .bufferCount = 2,
        .buffers = &layouts,
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
        .entryPoint = "fs_inter_buf",

        .constantCount = 0,
        .constants = null,
        .targetCount = 1,
        .targets = &target_state,
    };

    const pipeline_desc: c.WGPURenderPipelineDescriptor = .{
        .label = "MultBuffer Pipeline",
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
        .position_buffer = position_buffer,
        .color_buffer = color_buffer,
    };
}

pub inline fn positionBufferSize(self: Self) u64 {
    return c.wgpuBufferGetSize(self.position_buffer);
}

pub inline fn colorBufferSize(self: Self) u64 {
    return c.wgpuBufferGetSize(self.color_buffer);
}

pub inline fn deinit(self: Self) void {
    c.wgpuBufferRelease(self.position_buffer);
    c.wgpuBufferRelease(self.color_buffer);
    self.pipeline.deinit();
}
