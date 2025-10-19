const Point3 = @import("vec3.zig").Point3;
const Vec3 = @import("vec3.zig").Vec3;

pub const Ray = struct {
    orig: *const Point3,
    dir: *const Vec3,

    pub fn init(orig: *const Point3, dir: *const Vec3) Ray {
        return Ray{ .orig = orig, .dir = dir };
    }

    pub fn origin(self: Ray) *const Point3 {
        return self.orig;
    }

    pub fn direction(self: Ray) *const Vec3 {
        return self.dir;
    }

    pub fn at(self: Ray, t: f64) *const Point3 {
        // orig + t*dir
        return self.orig.add(self.direction().scale(t));
    }
};
