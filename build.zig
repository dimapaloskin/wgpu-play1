const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "wgp",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (target.result.os.tag == .macos) {
        // exe.addIncludePath(.{
        //     .cwd_relative = "/opt/homebrew/opt/glfw/include",
        // });

        // exe.addObjectFile(.{
        //     .cwd_relative = "/opt/homebrew/opt/glfw/lib/libglfw3.a",
        // });
        // exe.linkSystemLibrary("glfw3");
        // exe.defineCMacro("GLFW_EXPOSE_NATIVE_COCOA", "1");
        // exe.defineCMacro("_GLFW_COCOA", "1");
        exe.linkFramework("Foundation");
        exe.linkFramework("Metal");
        exe.linkFramework("QuartzCore");
        exe.linkFramework("IOKit");
        exe.linkFramework("CoreVideo");
        exe.linkFramework("AppKit");

        // exe.addCSourceFiles(.{
        //     .files = &[_][]const u8{"deps/glfw3webgpu/glfw3webgpu.c"},
        //     .flags = &[_][]const u8{"-ObjC"},
        // });

        exe.addCSourceFiles(.{
            .files = &[_][]const u8{ "src/macos/window.m", "src/macos/App.m" },
            .flags = &[_][]const u8{
                "-ObjC",
                "-I./deps",
                "-I./deps/wgpu/include",
            },
            .root = .{ .cwd_relative = "." },
        });

        exe.addObjectFile(.{
            .cwd_relative = "deps/wgpu/lib/libwgpu_native.a",
        });
    }

    exe.addIncludePath(.{
        .cwd_relative = "deps",
    });

    exe.addIncludePath(.{
        .cwd_relative = "deps/wgpu/include",
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
