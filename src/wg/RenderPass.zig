const std = @import("std");
const c = @import("../bindings.zig").c;

const Encoder = @import("Encoder.zig");
const RenderPipeline = @import("RenderPipeline.zig");

const Self = @This();

render_pass: c.WGPURenderPassEncoder,

pub inline fn init(encoder: Encoder, desc: *const c.WGPURenderPassDescriptor) Self {
    return Self{
        .render_pass = c.wgpuCommandEncoderBeginRenderPass(encoder.encoder, desc),
    };
}

pub inline fn deinit(self: Self) void {
    std.log.debug("RenderPass deinit", .{});
    c.wgpuRenderPassRelease(self.render_pass);
}

pub inline fn end(self: Self) void {
    c.wgpuRenderPassEncoderEnd(self.render_pass);
}

pub inline fn release(self: Self) void {
    c.wgpuRenderPassEncoderRelease(self.render_pass);
}

pub inline fn draw(
    self: Self,
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
) void {
    c.wgpuRenderPassEncoderDraw(self.render_pass, vertex_count, instance_count, first_vertex, first_instance);
}

pub inline fn drawIndexed(self: Self, index_count: u32, instance_count: u32, first_index: u32, base_index: i32, first_instance: u32) void {
    c.wgpuRenderPassEncoderDrawIndexed(self.render_pass, index_count, instance_count, first_index, base_index, first_instance);
}

pub inline fn setRenderPipeline(self: Self, render_pipeline: *const RenderPipeline) void {
    c.wgpuRenderPassEncoderSetPipeline(self.render_pass, render_pipeline.*.pipeline);
}

pub inline fn setVertexBuffer(self: Self, slot: u32, vertex_buffer: *const c.WGPUBuffer, size: u64) void {
    c.wgpuRenderPassEncoderSetVertexBuffer(self.render_pass, slot, vertex_buffer.*, 0, size);
}

pub inline fn setIndexBUffer(self: Self, index_buffer: *const c.WGPUBuffer, format: c.WGPUIndexFormat, offset: u64, size: u64) void {
    c.wgpuRenderPassEncoderSetIndexBuffer(self.render_pass, @constCast(index_buffer.*), format, offset, size);
}
