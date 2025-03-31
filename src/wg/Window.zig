// const std = @import("std");
// const c = @import("../bindings.zig").c;

// const Self = @This();

// window: *c.GLFWwindow,

pub const WindowConfig = struct {
    width: u32,
    height: u32,
    title: []const u8,
};

// pub inline fn init(config: *const WindowConfig) !Self {
//     if (c.glfwInit() != c.GLFW_TRUE) {
//         return error.GLFWInitFailed;
//     }

//     defer c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
//     c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_FALSE);

//     const window = c.glfwCreateWindow(
//         @intCast(config.*.width),
//         @intCast(config.*.height),
//         config.*.title.ptr,
//         null,
//         null,
//     ) orelse {
//         return error.WindowCreateFailed;
//     };

//     c.glfwSwapInterval(1);

//     return Self{
//         .window = window,
//     };
// }

// pub inline fn deinit(self: Self) void {
//     std.log.debug("Window deinit", .{});
//     // _ = self;
//     c.glfwDestroyWindow(self.window);
//     c.glfwTerminate();
// }

// pub inline fn shouldClose(self: Self) bool {
//     return c.glfwWindowShouldClose(self.window) == c.GLFW_TRUE;
// }

// pub inline fn swapBuffers(self: Self) void {
//     c.glfwSwapBuffers(self.window);
// }
