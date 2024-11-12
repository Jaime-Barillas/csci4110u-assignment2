use "random"

class val AreaLight is Shape
  let position: Vec3 // NOTE: "Back-left" corner
  let normal: Vec3
  let width: F32
  let length: F32
  let colour: Vec3

  new val create(position': Vec3,
                 width': F32,
                 length': F32,
                 colour': Vec3) =>
    position = position'
    normal = Vec3(0, -1, 0)
    width = width'
    length = length'
    colour = colour'

  fun random_ray(rand: Rand, origin: Vec3): Ray =>
    """
    Create a ray originating at `origin` directed to a random point on this
    AreaLight.
    """
    // Note Area lights are always on the xz-plane.
    let offset_x = rand.real().f32() * width
    let offset_z = rand.real().f32() * length
    let random_point = Vec3(position.x + offset_x, position.y, position.z + offset_z)
    Ray(origin, (random_point - origin).normalized())

  fun intersect(ray: Ray, hit: Hit): Bool =>
    // Is the ray heading towards the arealight's plane at all?
    let cos = ray.direction.dot(normal)
    if cos.abs() < Math.epsilon() then
      return false
    end

    // 1. Intersect with the infinite plane the arealight lies on.
    // 2. Check if the intersection point is within the bounds of the arealight.
    // Note: Area lights are always on the (possibly offset) xz-plane, so we
    //       only need to check x,z bounds.
    let dist = (position - ray.origin).dot(normal) / cos
    let point = ray.at(dist)
    let test_point = point - position
    if (test_point.x > 0) and (test_point.x < width) and
       (test_point.z > 0) and (test_point.z < length) then
      hit.dist = dist
      hit.point = point
      hit.normal = normal
      hit.colour = colour
      hit.is_light = true
      return true
    else
      return false
    end

