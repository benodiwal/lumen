pub const Color = @import("vec3.zig").Point3;

pub fn writeColor(stdout: anytype, pixel_color: *const Color) !void {
    const r = pixel_color.x();
    const g = pixel_color.y();
    const b = pixel_color.z();

    const rbyte = @as(u8, @intFromFloat(r * 255.999));
    const gbyte = @as(u8, @intFromFloat(g * 255.999));
    const bbyte = @as(u8, @intFromFloat(b * 255.999));

    try stdout.print("{d} {d} {d}\n", .{rbyte, gbyte, bbyte});
}
