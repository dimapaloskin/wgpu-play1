const std = @import("std");
const c = @import("../bindings.zig").c;

const Self = @This();

const Instance = @import("Instance.zig");
const Device = @import("Device.zig");

adapter: c.WGPUAdapter,

const RequestAdapterUserData = struct {
    adapter: c.WGPUAdapter,
    success: bool,
    err_msg: [*c]const u8,
};

fn requestAdapterCallback(status: c_uint, adapter: c.WGPUAdapter, err_msg: [*c]const u8, userdata: ?*anyopaque) callconv(.c) void {
    const user_data: *RequestAdapterUserData = @alignCast(@ptrCast(userdata));
    if (status == c.WGPURequestAdapterStatus_Success) {
        user_data.*.adapter = adapter;
        user_data.*.success = true;
    } else {
        user_data.*.success = false;
        user_data.*.err_msg = err_msg;
    }
}

pub inline fn init(instance: *const Instance, opts: *const c.WGPURequestAdapterOptions) !Self {
    var user_data = RequestAdapterUserData{
        .adapter = undefined,
        .success = false,
        .err_msg = undefined,
    };

    c.wgpuInstanceRequestAdapter(instance.*.instance, opts, requestAdapterCallback, &user_data);
    if (user_data.adapter) |adapter| {
        return Self{
            .adapter = adapter,
        };
    }

    std.log.err("{s}", .{user_data.err_msg});
    return error.AdapterRequestFailed;
}

pub inline fn deinit(self: Self) void {
    std.log.debug("Adapter deinit", .{});
    c.wgpuAdapterRelease(self.adapter);
}

pub inline fn requestDevice(self: Self, desc: *const c.WGPUDeviceDescriptor) !Device {
    return try Device.init(&self, desc);
}

pub inline fn printInfo(self: Self) void {
    var info: c.WGPUAdapterInfo = .{};
    c.wgpuAdapterGetInfo(self.adapter, &info);
    std.log.info("Vendor: {s}", .{info.vendor});
    std.log.info("Architecture: {s}", .{info.architecture});
    std.log.info("Device: {s}", .{info.device});
    std.log.info("Description: {s}", .{info.description});
    std.log.info("Description: {s}", .{info.description});
    std.log.info("Adapter Type: {d}", .{info.adapterType});
    std.log.info("Device ID: {d}", .{info.deviceID});
    std.log.info("Vendor ID: {d}", .{info.vendorID});
}
