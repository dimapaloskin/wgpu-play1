const std = @import("std");

const ParseMode = enum {
    Points,
    Indices,
    None,
};

const ParseResult = struct {
    points: []f32,
    indices: []u16,
};

pub fn parse(ally: std.mem.Allocator, path: []const u8) !ParseResult {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var pm = ParseMode.None;
    const data = try file.readToEndAlloc(ally, 1_000_000);
    defer ally.free(data);

    var points = std.ArrayList(f32).init(ally);
    var indices = std.ArrayList(u16).init(ally);

    var iter = std.mem.splitSequence(u8, data, "\n");
    while (iter.next()) |line| {
        if (std.mem.startsWith(u8, line, "#")) {
            continue;
        } else if (std.mem.eql(u8, line, "[points]")) {
            pm = ParseMode.Points;
            std.log.info("points", .{});
            continue;
        } else if (std.mem.eql(u8, line, "[indices]")) {
            pm = ParseMode.Indices;
            std.log.info("indicies", .{});
            continue;
        }

        if (pm == ParseMode.Points) {
            var parts = std.mem.splitSequence(u8, line, " ");
            var pos = [5]f32{ 1.0, 0.0, 0.0, 0.0, 0.0 };
            var i: usize = 0;
            if (line.len == 0 or std.mem.eql(u8, line, "\n")) {
                continue;
            }

            while (parts.next()) |part| {
                if (i >= 5) {
                    break;
                }

                pos[i] = try std.fmt.parseFloat(f32, part);
                i += 1;
            }

            for (pos) |p| {
                std.debug.print("{d} ", .{p});
            }

            std.debug.print("\n", .{});

            try points.appendSlice(&pos);
        }

        if (pm == ParseMode.Indices) {
            var parts = std.mem.splitSequence(u8, line, " ");
            var i: usize = 0;
            if (line.len == 0 or std.mem.eql(u8, line, "\n")) {
                continue;
            }

            var ind = [3]u16{ 0, 0, 0 };
            while (parts.next()) |part| {
                if (i >= 3) {
                    break;
                }

                ind[i] = try std.fmt.parseInt(u16, part, 10);
                i += 1;
            }

            for (ind) |idx| {
                std.debug.print("{d} ", .{idx});
            }

            std.debug.print("\n", .{});

            try indices.appendSlice(&ind);
        }
    }

    std.log.info("POINTS LEN: {d}", .{points.items.len});
    return ParseResult{
        .points = try points.toOwnedSlice(),
        .indices = try indices.toOwnedSlice(),
    };
}
