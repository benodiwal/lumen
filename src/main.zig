const std = @import("std");
const gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allcator = gpa.allocator();

fn createLogFile() !std.fs.File {
    return try std.fs.cwd().createFile("raytracer.log", .{ .read = true });
}

fn ppmFileHeader(stdout: anytype, image_width: u32, image_height: u32) !void {
    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});
}

pub fn main() !void {
    const log_file = try createLogFile();
    defer log_file.close();

    const log_writer = log_file.writer();

    const image_width = 256;
    const image_height = 256;

    try log_writer.writeAll("Starting ray tracer...\n");

    const stdout = std.io.getStdOut().writer();
    try ppmFileHeader(stdout, image_width, image_height);

    var pixels_written: usize = 0;
    const total_pixels = image_width * image_height;

    for (0..image_height) |j| {
        try log_writer.print("Processing row {d}/{d}\n", .{j+1, image_height});

        for (0..image_width) |i| {
            const r = @as(f32, @floatFromInt(i)) / (image_width-1);
            const g = @as(f32, @floatFromInt(j)) / (image_height-1);
            const b = 0.0;

            const ir = @as(u8, @intFromFloat(r * 255.999));
            const ig = @as(u8, @intFromFloat(g * 255.999));
            const ib = @as(u8, @intFromFloat(b * 255.999));

            try stdout.print("{d} {d} {d}\n", .{ir, ig, ib});

            pixels_written += 1;
        }

        if (j % 25 == 0) {
            const progress = @as(f32, @floatFromInt(pixels_written)) / @as(f32, @floatFromInt(total_pixels)) * 100;
            try log_writer.print("Progress: {d:.2}%\n", .{progress});
        }
    }

}
