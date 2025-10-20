const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Ray = @import("ray.zig").Ray;

const HitRecord = struct {
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
        const ptr_info = @typeInfo(Ptr);

        const gen = struct {
            fn hit(ptr: *anyopaque, r: Ray, t_min: f64, t_max: f64) ?HitRecord {
                const self: Ptr = @ptrCast(@alignCast(ptr));
                return ptr_info.Pointer.child.hit(self, r, t_min, t_max);
            }
        };

        return .{
            .ptr = @ptrCast(@alignCast(&pointer)),
            .hitFn = &gen.hit,
        };
    }

    pub fn hit(self: Object, r: Ray, t_min: f64, t_max: f64) void {
        self.hitFn(self.ptr, r, t_min, t_max);
    }
};