const std = @import("std");
const c = @import("../bindings.zig").c;

const Self = @This();

pipeline: c.WGPURenderPipeline,

pub inline fn fromPipeline(pipeline: c.WGPURenderPipeline) Self {
    return Self{
        .pipeline = pipeline,
    };
}

pub inline fn deinit(self: Self) void {
    std.log.debug("RenderPipeline deinit", .{});
    c.wgpuRenderPipelineRelease(self.pipeline);
}
