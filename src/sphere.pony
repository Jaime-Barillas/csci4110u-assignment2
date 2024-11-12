class val Sphere is Shape
  let position: Vec3
  let radius: F32
  let colour: Vec3

  new val create(position': Vec3, radius': F32, colour': Vec3) =>
    position = position'
    radius = radius'
    colour = colour'

  fun intersect(ray: Ray, hit: Hit): Bool =>
    // Ray-sphere intersection.
    // Simplification from: https://raytracing.github.io/books/RayTracingInOneWeekend.html#surfacenormalsandmultipleobjects/simplifyingtheray-sphereintersectioncode
    // b = -2h, h = dot(ray-dir, (sphere-center - ray-origin))
    // h = b/(-2)
    // Quadratic formula after replacing b with -2h:
    // h +/- sqrt(h*h - ac)
    // --------------------
    //         a
    let ray_to_sphere = position - ray.origin
    let a = ray.direction.dot(ray.direction)
    let h = ray.direction.dot(ray_to_sphere)
    let c = ray_to_sphere.dot(ray_to_sphere) - (radius * radius)
    let discriminant = (h * h) - (a * c)

    // No real square roots => no intersection.
    if (discriminant < 0) then
      return false
    end

    // The idea:
    // 1. Start with the closest (smallest) root candidate (the numerator
    //    subtracts the square root.)
    // 2. If the root candidate (numerator) is negative, return the other root
    //    regardless of whether it is negative.
    //    This is fine because:
    //    + By convention, negative numbers mean no intersection occurred.
    //    + If there is only one root (square root is negative), both candidate
    //      roots will have the same value. (The sqrt() could be skipped in this case.)
    let sqrt = discriminant.sqrt()
    let smallest_root = h - sqrt
    if (smallest_root < Math.epsilon()) then
      // smallest_root was negative.
      hit.dist = (h + sqrt) / a
    else
      // smallest_root was positive.
      hit.dist = smallest_root / a
    end

    hit.point = ray.at(hit.dist)
    hit.normal = (hit.point - position) / radius
    hit.colour = colour
    true

