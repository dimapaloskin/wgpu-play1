const std = @import("std");
const c = @import("../bindings.zig").c;

const Adapter = @import("Adapter.zig");
const Queue = @import("Queue.zig");
const RenderPipeline = @import("RenderPipeline.zig");
const ShaderModule = @import("ShaderModule.zig");

const Self = @This();

device: c.WGPUDevice,
adapter: *const Adapter,

const RequestDeviceUserData = struct {
    device: c.WGPUDevice,
    success: bool,
    err_msg: [*c]const u8,
};

fn requestDeviceCallback(status: c.WGPURequestDeviceStatus, device: c.WGPUDevice, err_msg: [*c]const u8, userdata: ?*anyopaque) callconv(.c) void {
    const user_data: *RequestDeviceUserData = @alignCast(@ptrCast(userdata));
    if (status == c.WGPURequestDeviceStatus_Success) {
        user_data.*.device = device;
        user_data.*.success = true;
    } else {
        user_data.*.success = false;
        user_data.*.err_msg = err_msg;
    }
}

pub inline fn init(adapter: *const Adapter, desc: *const c.WGPUDeviceDescriptor) !Self {
    var user_data = RequestDeviceUserData{
        .device = undefined,
        .success = false,
        .err_msg = undefined,
    };

    c.wgpuAdapterRequestDevice(adapter.adapter, desc, requestDeviceCallback, &user_data);

    if (user_data.device) |device| {
        return Self{
            .device = device,
            .adapter = adapter,
        };
    }

    std.log.err("{s}", .{user_data.err_msg});
    return error.DeviceRequestFailed;
}

pub inline fn deinit(self: Self) void {
    std.log.debug("Device deinit", .{});
    c.wgpuDeviceRelease(self.device);
}

pub inline fn getQueue(self: Self) c.WGPUQueue {
    return self.queue;
}

pub inline fn createQueue(self: Self) Queue {
    return Queue.init(self);
}

pub inline fn createRenderPipeline(self: Self, desc: *const c.WGPURenderPipelineDescriptor) !RenderPipeline {
    const pipeline = c.wgpuDeviceCreateRenderPipeline(self.device, desc) orelse {
        return error.RenderPipelineCreateFailed;
    };

    return RenderPipeline.fromPipeline(pipeline);
}

pub inline fn createShaderModule(self: Self, desc: *const c.WGPUShaderModuleDescriptor) !ShaderModule {
    const module = c.wgpuDeviceCreateShaderModule(self.device, desc) orelse {
        return error.ShaderModuleCreateFailed;
    };

    return ShaderModule.from(module);
}

pub inline fn printLimits(self: Self) void {
    var supported_limits: c.WGPUSupportedLimits = .{
        .nextInChain = null,
    };

    _ = c.wgpuAdapterGetLimits(self.adapter.adapter, &supported_limits);
    std.log.debug("adapter.maxVertexAttributes: {d}", .{supported_limits.limits.maxVertexAttributes});
    _ = c.wgpuDeviceGetLimits(self.device, &supported_limits);
    std.log.debug("device.maxVertexAttributes: {d}", .{supported_limits.limits.maxVertexAttributes});
}
