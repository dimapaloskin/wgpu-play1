pub const c = @cImport({
    // @cInclude("GLFW/glfw3.h");
    @cInclude("webgpu/webgpu.h");
});

pub extern fn glfwCreateWindowWGPUSurface(instance: c.WGPUInstance, window: ?*c.GLFWwindow) c.WGPUSurface;
pub extern fn create_window(c.WGPUInstance) c.WGPUSurface;
pub extern fn poll_events() void;

pub const ResizeCallback = ?*const fn () void;
pub extern fn setResizeCallback(ResizeCallback) callconv(.c) void;
