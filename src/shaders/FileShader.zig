const std = @import("std");
const c = @import("../bindings.zig").c;

const wg = @import("../wg/wg.zig");
const parser = @import("../parser.zig");

const Self = @This();

pipeline: wg.RenderPipeline,
position_buffer: c.WGPUBuffer,
index_buffer: c.WGPUBuffer,
indices_count: u32,

pub inline fn init(device: wg.Device, queue: wg.Queue, format: c.WGPUTextureFormat) !Self {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const ally = gpa.allocator();

    const result = try parser.parse(ally, "data.txt");

    const shader_code = @embedFile("../shader.wgsl");

    std.log.info("ind count: {d}", .{result.indices.len});

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
    // const points_data = [_]f32{
    //     -0.5,  -0.5, 1.0, 0.0, 0.0,
    //     0.5,   -0.5, 0.0, 1.0, 0.0,
    //     0.5, 0.5, 0.0, 0.0, 1.0,
    //     -0.5, 0.5, 1.0, 1.0, 0.0,
    // };


    // const index_data = [_]u16{
    //     0, 1, 2,
    //     0, 2, 3,
    // };
    // zig fmt: on

    const position_buffer_desc: c.WGPUBufferDescriptor = .{
        .label = "Position Buffer",
        .nextInChain = null,
        .size = result.points.len * @sizeOf(f32),
        .usage = c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_Vertex,
        .mappedAtCreation = 0,
    };

    std.log.info("Points len: {d}", .{result.points.len});
    const position_buffer = c.wgpuDeviceCreateBuffer(device.device, &position_buffer_desc);
    c.wgpuQueueWriteBuffer(queue.queue, position_buffer, 0, @as(*const anyopaque, @ptrCast(result.points.ptr)), position_buffer_desc.size);

    const index_buffer_desc: c.WGPUBufferDescriptor = .{
        .label = "Index Buffer",
        .nextInChain = null,
        .size = result.indices.len * @sizeOf(f32),
        .mappedAtCreation = 0,
        .usage = c.WGPUBufferUsage_CopyDst | c.WGPUBufferUsage_Index,
    };

    const index_buffer = c.wgpuDeviceCreateBuffer(device.device, &index_buffer_desc);
    c.wgpuQueueWriteBuffer(queue.queue, index_buffer, 0, @as(*const anyopaque, @ptrCast(result.indices.ptr)), index_buffer_desc.size);

    const position_attrib: c.WGPUVertexAttribute = .{
        .shaderLocation = 0,
        .format = c.WGPUVertexFormat_Float32x2,
        .offset = 0,
    };

    const color_attrib: c.WGPUVertexAttribute = .{
        .shaderLocation = 1,
        .format = c.WGPUVertexFormat_Float32x3,
        .offset = 2 * @sizeOf(f32),
    };

    const attributes = [_]c.WGPUVertexAttribute{ position_attrib, color_attrib };
    const vertex_buffer_layout: c.WGPUVertexBufferLayout = .{
        .attributes = &attributes,
        .attributeCount = 2,
        .arrayStride = 5 * @sizeOf(f32),
        .stepMode = c.WGPUVertexStepMode_Vertex,
    };

    const layouts = [_]c.WGPUVertexBufferLayout{vertex_buffer_layout};

    const vertex_state: c.WGPUVertexState = .{
        .nextInChain = null,

        .module = shader_module.module,
        .entryPoint = "vs_file",

        .bufferCount = 1,
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
        .entryPoint = "fs_file",

        .constantCount = 0,
        .constants = null,
        .targetCount = 1,
        .targets = &target_state,
    };

    const pipeline_desc: c.WGPURenderPipelineDescriptor = .{
        .label = "File Pipeline",
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
        .index_buffer = index_buffer,
        .indices_count = @intCast(result.indices.len),
    };
}

pub inline fn positionBufferSize(self: Self) u64 {
    return c.wgpuBufferGetSize(self.position_buffer);
}

pub inline fn colorBufferSize(self: Self) u64 {
    return c.wgpuBufferGetSize(self.color_buffer);
}

pub inline fn indexBufferSize(self: Self) u64 {
    return c.wgpuBufferGetSize(self.index_buffer);
}

pub inline fn deinit(self: Self) void {
    c.wgpuBufferRelease(self.position_buffer);
    c.wgpuBufferRelease(self.index_buffer);
    self.pipeline.deinit();
}
