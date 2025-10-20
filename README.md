# lumen
A ray tracer implementation in Zig, following the "Ray Tracing in One Weekend" series.

### About
Lumen is a physically-based ray tracer built from scratch in Zig. It demonstrates core ray tracing concepts including ray-sphere intersection, surface normals, and scene composition using an object-oriented design pattern adapted for Zig's capabilities.

### Building
```bash
zig build
```

### Running
```bash
zig build run >> output.ppm
```

View the output PPM file with any image viewer that supports the format (GIMP, ImageMagick, etc.).

### Progress Checklist
- PPM format writer with RGB color mapping
- Complete Vec3 implementation with arithmetic operations, dot/cross products, and normalization
- Configurable camera with aspect ratio control, viewport coordinate mapping, and pixel-to-ray generation
- Optimized hit detection using quadratic solver with discriminant testing and half-b formula
- Abstract hittable interface with runtime polymorphism, supporting multiple objects with closest-hit selection