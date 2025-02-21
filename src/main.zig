const std = @import("std");
const color = @import("color.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

const gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allcator = gpa.allocator();
const math = std.math;
const Color = vec3.Point3;
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

fn colorRay(r: * const Ray) Color {
    const unit_direction = r.direction().unit_vector();
    const a = 0.5 * (unit_direction.y() + 1.0);
    return Color.init(1.0, 1.0, 1.0).scale(1.0-a).add(Color.init(0.5, 0.7, 1.0).scale(a));
}

fn createLogFile() !std.fs.File {
    return try std.fs.cwd().createFile("raytracer.log", .{ .read = true });
}

fn ppmFileHeader(stdout: anytype, image_width: u64, image_height: u64) !void {
    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});
}

pub fn main() !void {
    const log_file = try createLogFile();
    defer log_file.close();

    const log_writer = log_file.writer();

    // IMAGE
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;

    // Ensuring image height is aleast 1
    var image_height = @as(u64, @as(f64, @floatFromInt(image_width)) / aspect_ratio);
    image_height = if (image_height < 1) 1 else image_height;

    // CAMERA
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));
    const camera_center = Point3.init(0.0, 0.0, 0.0);

    const viewport_u = Vec3.init(viewport_width, 0.0, 0.0);
    const viewport_v = Vec3.init(0.0, -viewport_height, 0.0);

    const pixel_delta_u = viewport_u.div(@as(f64, @floatFromInt(image_width)));
    const pixel_delta_v = viewport_v.div(@as(f64, @floatFromInt(image_height)));

    const viewport_upper_left = camera_center.sub(Vec3.init(0, 0, focal_length).sub(viewport_u.div(2)).sub(viewport_v.div(2)));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).scale(0.5));

    try log_writer.writeAll("Starting ray tracer...\n");

    const stdout = std.io.getStdOut().writer();
    try ppmFileHeader(stdout, image_width, image_height);

    var pixels_written: usize = 0;
    const total_pixels = image_width * image_height;

    for (0..image_height) |j| {
        try log_writer.print("Processing row {d}/{d}\n", .{j+1, image_height});

        for (0..image_width) |i| {
            const pixel_center = pixel00_loc.add(pixel_delta_u.scale(@as(f64, @floatFromInt(i)))).add(pixel_delta_v.scale(@as(f64, @floatFromInt(j))));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray.init(&camera_center, &ray_direction);
            const pixel_color = colorRay(&r);

            // const r = @as(f64, @floatFromInt(i)) / (image_width-1);
            // const g = @as(f64, @floatFromInt(j)) / (image_height-1);
            // const b = 0.0;

            try color.writeColor(stdout, &pixel_color);
            pixels_written += 1;
        }

        if (j % 25 == 0) {
            const progress = @as(f32, @floatFromInt(pixels_written)) / @as(f32, @floatFromInt(total_pixels)) * 100;
            try log_writer.print("Progress: {d:.2}%\n", .{progress});
        }
    }

    try log_writer.writeAll("Done\n");
}
