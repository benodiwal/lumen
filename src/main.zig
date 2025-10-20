const std = @import("std");
const color = @import("color.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");
const Object = @import("objects.zig").Object;
const Sphere = @import("sphere.zig").Sphere;

const math = std.math;
const Color = color.Color;
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

fn hit_sphere(center: Point3, radius: f64, r: Ray) f64 {
    const oc = center.sub(r.origin());
    const a = Vec3.dot(r.direction(), r.direction());
    
    const half_b = Vec3.dot(oc, r.direction());
    const c = Vec3.dot(oc, oc) - radius * radius;
    const discriminant = half_b * half_b - a * c;
    
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (half_b - @sqrt(discriminant)) / a;
    }
}

fn colorRay(r: Ray, world: []const Sphere) Color {
    var closest_t: f64 = math.inf(f64);
    var hit_anything = false;
    var hit_normal: Vec3 = undefined;
    
    // Check all spheres in the world
    for (world) |sphere| {
        const t = hit_sphere(sphere.center, sphere.radius, r);
        
        if (t > 0.0 and t < closest_t) {
            closest_t = t;
            hit_anything = true;
            const hit_point = r.at(t);
            hit_normal = hit_point.sub(sphere.center).unit_vector();
        }
    }
    
    // If we hit something, return its color
    if (hit_anything) {
        return Color.init(
            hit_normal.x() + 1.0,
            hit_normal.y() + 1.0,
            hit_normal.z() + 1.0
        ).scale(0.5);
    }
    
    // Otherwise, return sky gradient
    const unit_direction = r.direction().unit_vector();
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).scale(1.0 - a)
        .add(Color.init(0.5, 0.7, 1.0).scale(a));
}

fn ppmFileHeader(stdout: anytype, image_width: u64, image_height: u64) !void {
    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var world = std.ArrayList(Sphere).init(allocator);
    defer world.deinit();

    const sphere1 = Sphere.init(Point3.init(0.0, 0.0, -1.0), 0.5);
    const sphere2 = Sphere.init(Point3.init(0.0, -100.5, -1.0), 100.0);

    try world.append(sphere1);
    try world.append(sphere2);

    // IMAGE
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;

    // Ensuring image height is aleast 1
    // Comptime block to save this calculation on compile time
    const image_height = blk: {
        const ih: comptime_int = @intFromFloat((image_width - 0.0)/aspect_ratio);
        if (ih < 1) break :blk 1;
        break :blk ih;
    };

    // CAMERA
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (image_width / image_height);
    const camera_center = Point3.init(0.0, 0.0, 0.0);

    const viewport_u = Vec3.init(viewport_width, 0.0, 0.0);
    const viewport_v = Vec3.init(0.0, -viewport_height, 0.0);

    const pixel_delta_u = viewport_u.div(image_width);
    const pixel_delta_v = viewport_v.div(image_height);

    // Camera Center - (viewport_u/2) - (viewport_v/2) - (focal_length in z)
    // Start from Camera center, move left, move up, move forward
    const viewport_upper_left = camera_center.sub(Vec3.init(0, 0, focal_length)).sub(viewport_u.div(2)).sub(viewport_v.div(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).scale(0.5));

    const stdout = std.io.getStdOut().writer();
    try ppmFileHeader(stdout, image_width, image_height);

    for (0..image_height) |j| {
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc.add(pixel_delta_u.scale(@floatFromInt(i))).add(pixel_delta_v.scale(@floatFromInt(j)));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray.init(camera_center, ray_direction);
            const pixel_color = colorRay(r, world.items);

            try color.writeColor(stdout, &pixel_color);
        }
    }
}
