const std = @import("std");
const math = std.math;
const testing = std.testing;

pub const Vec3 = struct {
    e: [3]f64,

    pub fn default() Vec3 {
        return Vec3 { .e = .{0.0, 0.0, 0.0} };
    }

    pub fn init(e_x: f64, e_y: f64, e_z: f64) Vec3 {
        return Vec3 { .e = .{e_x, e_y, e_z} };
    }

    pub fn x(self: Vec3) f64 {
        return self.e[0];
    }

    pub fn y(self: Vec3) f64 {
        return self.e[1];
    }

    pub fn z(self: Vec3) f64 {
        return self.e[2];
    }

    pub fn neg(self: Vec3) Vec3 {
        return Vec3 { .e = .{ -self.e[0], -self.e[1], -self.e[2] }};
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{ self.e[0] + other.e[0], self.e[1] + other.e[1], self.e[2] + other.e[2] }
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e =  .{ self.e[0] - other.e[0], self.e[1] - other.e[1], self.e[2] - other.e[2] }
        };
    }

    pub fn mul(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .e = .{ self.e[0] * other.e[0], self.e[1] * other.e[1], self.e[2] * other.e[2] }
        };
    }

    pub fn scale(self: Vec3, t: f64) Vec3 {
        return Vec3 {
            .e = .{ self.e[0] * t, self.e[1] * t, self.e[2] * t }
        };
    }

    pub fn div(self: Vec3, t: f64) Vec3 {
        return self.scale(1.0 / t);
    }

    pub fn length(self: Vec3) f64 {
        return math.sqrt(self.length_squared());
    }

    pub fn length_squared(self: Vec3) f64 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    // Dot Product Utility Function
    pub fn dot(a: Vec3, b: Vec3) f64 {
        return a.e[0]*b.e[0] + a.e[1]*b.e[1] + a.e[2]*b.e[2];
    }

    // Cross Product Utility Function
    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return Vec3 {
            .e = .{
                a.e[1]*b.e[2] - a.e[2]*b.e[1],
                a.e[2]*b.e[0] - a.e[0]*b.e[2],
                a.e[0]*b.e[1] - a.e[1]*b.e[0],
            }
        };
    }

    pub fn unit_vector(self: Vec3) Vec3 {
        return self.div(self.length());
    }

    pub fn format(self: Vec3, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("{d} {d} {d}", .{self.e[0], .self.e[1], .self.e[2]});
    }
};

pub const Point3 = Vec3;

test "vec3 basic operations" {
    const v1 = Vec3.init(1, 2, 3);
    const v2 = Vec3.init(4, 5, 6);

    try testing.expectEqual(v1.x(), 1);
    try testing.expectEqual(v1.y(), 2);
    try testing.expectEqual(v1.z(), 3);

    const sum = v1.add(v2);
    try testing.expectEqual(sum.e[0], 5);
    try testing.expectEqual(sum.e[1], 7);
    try testing.expectEqual(sum.e[2], 9);

    const scaled = v1.scale(2);
    try testing.expectEqual(scaled.e[0], 2);
    try testing.expectEqual(scaled.e[1], 4);
    try testing.expectEqual(scaled.e[2], 6);

    const len = v1.length();
    try testing.expectApproxEqAbs(len, math.sqrt(14), 0.0001);
}
