const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Ray = @import("ray.zig").Ray;
const std = @import("std");

pub const HitRecord = struct {
    // Hit Point
    p: Point3,
    // Surface Normal
    normal: Vec3,
    // Ray Parameter at hit
    t: f64,
    // Did ray hit from outside?
    front_face: bool,

    pub fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = Vec3.dot(r.direction(), outward_normal) < 0.0;
        self.normal = if (self.front_face) outward_normal else outward_normal.neg();
    }
};

// Objects are entities in the scene that can be intersected/hitted by rays.
pub const Object = struct {
    ptr: *anyopaque,
    hitFn: *const fn (ptr: *anyopaque, r: Ray, t_min: f64, t_max: f64) ?HitRecord,

    pub fn init(pointer: anytype) Object {
        const Ptr = @TypeOf(pointer);

        const gen = struct {
            fn hit(ptr: *anyopaque, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
                const self: Ptr = @ptrCast(@alignCast(ptr));
                return self.hit(r, t_min, t_max);
            }
        };

        return .{
            .ptr = @ptrCast(@alignCast(pointer)),
            .hitFn = &gen.hit,
        };
    }

    pub fn hit(self: Object, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
        return self.hitFn(self.ptr, r, t_min, t_max);
    }
};

// A collection of objects in the scene.
pub const World = struct {
    objects: std.ArrayList(Object),

    pub fn init(allocator: std.mem.Allocator) World {
        return World{
            .objects = std.ArrayList(Object).init(allocator),
        };
    }

    pub fn deinit(self: *World) void {
        self.objects.deinit();
    }

    pub fn add(self: *World, object: Object) !void {
        try self.objects.append(object);
    }

    pub fn clear(self: *World) void {
        self.objects.clearRetainingCapacity();
    }

    pub fn hit(self: *World, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
        var temp_rec: ?HitRecord = null;
        var closest_so_far = t_max;

        for (self.objects.items) |object| {
            if (object.hit(r, t_min, closest_so_far)) |rec| {
                closest_so_far = rec.t;
                temp_rec = rec;
            }
        }

        return temp_rec;
    }
};