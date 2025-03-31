const std = @import("std");
const c = @import("bindings.zig").c;
const bind = @import("bindings.zig");

const wg = @import("wg/wg.zig");
const FileShader = @import("shaders/FileShader.zig");
const parser = @import("parser.zig");

fn wgpuErrorCallback(err_type: c.WGPUErrorType, err_msg: [*c]const u8, _: ?*anyopaque) callconv(.c) void {
    std.log.err("{d}: {s}", .{ err_type, err_msg });
}

fn wgpuDeviceLostCallback(reason: c.WGPUDeviceLostReason, err_msg: [*c]const u8, _: ?*anyopaque) callconv(.c) void {
    std.log.err("{d}: {s}", .{ reason, err_msg });
}

fn resize() void {
    std.log.info("Resize catched from zig!!!", .{});
}

const window_config = wg.Window.WindowConfig{
    .width = 800 * 2,
    .height = 600 * 2,
    .title = "WebGPU",
};

pub fn main() !void {
    const instance = try wg.Instance.init(&.{
        .nextInChain = null,
    });
    defer instance.deinit();

    const surface = try wg.Surface.init(&instance);
    defer surface.deinit();

    const adapter_opts = c.WGPURequestAdapterOptions{
        .powerPreference = c.WGPUPowerPreference_HighPerformance,
        .compatibleSurface = surface.surface,
    };

    const adapter = try wg.Adapter.init(&instance, &adapter_opts);
    defer adapter.deinit();
    adapter.printInfo();

    const device = try adapter.requestDevice(&.{
        .nextInChain = null,
        .uncapturedErrorCallbackInfo = .{
            .callback = wgpuErrorCallback,
            .userdata = null,
            .nextInChain = null,
        },
    });

    defer device.deinit();
    device.printLimits();
    const queue = device.createQueue();

    const surface_capabilities = surface.getCapabilities(adapter);
    surface.configure(&.{
        .nextInChain = null,
        .width = window_config.width,
        .height = window_config.height,
        .format = surface_capabilities.formats[0],
        .viewFormatCount = 0,
        .viewFormats = null,
        .usage = c.WGPUTextureUsage_RenderAttachment,
        .device = device.device,
        .presentMode = c.WGPUPresentMode_Fifo,
        .alphaMode = c.WGPUCompositeAlphaMode_Auto,
    });
    defer surface.unconfigure();

    const format = surface.getPreferredFormat(adapter);
    const buf_shader = try FileShader.init(device, queue, format);
    defer buf_shader.deinit();

    bind.setResizeCallback(resize);
    while (true) {
        bind.poll_events();

        const currentTexture = try surface.getCurrentTexture();
        defer currentTexture.deinit();

        const targetView = currentTexture.createView(&.{
            .nextInChain = null,
            .label = "Surface Texture View",
            .format = currentTexture.getFormat(),
            .dimension = c.WGPUTextureViewDimension_2D,
            .baseMipLevel = 0,
            .mipLevelCount = 1,
            .baseArrayLayer = 0,
            .arrayLayerCount = 1,
            .aspect = c.WGPUTextureAspect_All,
        });
        // NOTE: https://github.com/eliemichel/LearnWebGPU-Code/blob/cf02768034430bee53c854813a03b39db8964ff9/main.cpp#L273
        defer targetView.deinit();

        const encoder = wg.Encoder.init(device, &.{
            .nextInChain = null,
            .label = "Command Encoder",
        });
        defer encoder.deinit();

        const color_attachment = c.WGPURenderPassColorAttachment{
            .view = targetView.view,
            .resolveTarget = null,
            .loadOp = c.WGPULoadOp_Clear,
            .storeOp = c.WGPUStoreOp_Store,
            .clearValue = c.WGPUColor{
                .r = 0.1,
                .g = 0.2,
                .b = 0.3,
                .a = 1.0,
            },
            .depthSlice = c.WGPU_DEPTH_SLICE_UNDEFINED,
        };

        const render_pass = encoder.beginRenderPass(&.{
            .nextInChain = null,
            .colorAttachmentCount = 1,
            .colorAttachments = &color_attachment,
            .depthStencilAttachment = null,
            .timestampWrites = null,
        });

        render_pass.setRenderPipeline(&buf_shader.pipeline);
        render_pass.setVertexBuffer(0, &buf_shader.position_buffer, buf_shader.positionBufferSize());
        // render_pass.setVertexBuffer(1, &buf_shader.color_buffer, buf_shader.colorBufferSize());
        render_pass.setIndexBUffer(&buf_shader.index_buffer, c.WGPUIndexFormat_Uint16, 0, buf_shader.indexBufferSize());
        // render_pass.draw(6, 1, 0, 0);
        render_pass.drawIndexed(buf_shader.indices_count, 1, 0, 0, 0);

        render_pass.end();
        render_pass.release();

        const cmd = encoder.finish(&.{
            .nextInChain = null,
            .label = "Command Buffer",
        });
        defer cmd.deinit();

        queue.submit(1, cmd);

        surface.present();
    }
}
