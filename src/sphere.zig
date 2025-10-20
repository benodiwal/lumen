const std = @import("std");
const object = @import("objects.zig").Object;
const HitRecord = @import("objects.zig").HitRecord;
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Ray = @import("ray.zig").Ray;

pub const Sphere = struct {
    center: Point3,
    radius: f64,

    pub fn init(center: Point3, radius: f64) Sphere {
        return Sphere{
            .center = center,
            .radius = radius,
        };
    }

    pub fn hit(self: *Sphere, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
        const oc = r.origin().sub(self.center);
        const a = Vec3.dot(r.direction(), r.direction());
        const half_b = Vec3.dot(oc, r.direction());
        const c = Vec3.dot(oc, oc) - self.radius * self.radius;
        
        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return null;
        
        const sqrtd = @sqrt(discriminant);
        
        var root = (-half_b - sqrtd) / a;
        if (root <= t_min or root >= t_max) {
            root = (-half_b + sqrtd) / a;
            if (root <= t_min or root >= t_max) {
                return null;
            }
        }
        
        var rec: HitRecord = undefined;
        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).div(self.radius);
        rec.setFaceNormal(r, outward_normal);
        
        return rec;
    }
};