interface Shape
  fun get_colour(): Vec3

  fun normal_at(point: Vec3): Vec3
    """
    Return the normal at `point`.
    """

  fun ray_intersection(ray: Ray): F32
    """
    Perform a ray intersection test.
    Returns the distance along the ray (units are in ray.direction) to the
    intersection point such that: intersection = ray-origin + (ray-dir * dist).
    Returns a negative number if there was no intersection.
    """

class val Sphere
  let position: Vec3
  let radius: F32
  let colour: Vec3

  new val create(position': Vec3, radius': F32, colour': Vec3) =>
    position = position'
    radius = radius'
    colour = colour'

  fun get_colour(): Vec3 => colour

  fun normal_at(point: Vec3): Vec3 => (point - position) / radius

  fun ray_intersection(ray: Ray): F32 =>
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
      return -1
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
      return (h + sqrt) / a
    else
      // smallest_root was positive.
      return smallest_root / a
    end


/*
class val Plane
  let position: Vec3
  let normal: Vec3
  let colour: Vec3

  new create(position': Vec3, normal': Vec3, colour': Vec3) =>
    position = position'.copy()
    normal = normal'.copy()
    normal.normalize()
    colour = colour'

  fun ref get_colour(): Vec3 => colour

  fun ray_intersection(pos: Vec3, dir: Vec3): F32 =>
    // The situation where the ray is parallel to the plane is always assumed
    // to be non-intersection case. The only time this may be a problem is if
    // the ray lies on the plane.
    let cos = dir.dot(normal)

    // Ray is parallel, assume no intersection.
    if cos.abs() < 0.0001 then
      return -1
    end

    (position.copy() - pos).dot(normal) / cos


class val AreaLight
  let position: Vec3
  let normal: Vec3
  let width: F32
  let height: F32
  let colour: Vec3

  new create(position': Vec3, normal': Vec3, width': F32, height': F32, colour': Vec3) =>
    position = position'.copy()
    normal = normal'.copy()
    normal.normalize()
    width = width'
    height = height'
    colour = colour'

  fun ref get_colour(): Vec3 => colour

  fun ray_intersection(pos: Vec3, dir: Vec3): F32 =>
    // Plane intersection + check if point is in triangle.
    let cos = dir.dot(normal)
    if cos.abs() < 0.0001 then
      return -1
    end

    let t = (position.copy() - pos).dot(normal) / cos
    let intersection_point = pos.copy() + (dir.copy() * t)
    if (intersection_point.x > position.x) and (intersection_point.x < (position.x + width)) and
       (intersection_point.y > position.y) and (intersection_point.y < (position.y + height)) then
      t
    else
      -1
    end
*/
