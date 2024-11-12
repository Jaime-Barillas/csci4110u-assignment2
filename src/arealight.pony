class val AreaLight is Shape
  let position: Vec3
  let normal: Vec3
  let width: F32
  let length: F32
  let colour: Vec3

  new val create(position': Vec3,
                 width': F32,
                 length': F32,
                 colour': Vec3) =>
    position = position'
    normal = Vec3(0, 1, 0)
    width = width'
    length = length'
    colour = colour'

  fun intersect(ray: Ray, hit: Hit): Bool =>
    // Is the ray heading towards the arealight's plane at all?
    let cos = ray.direction.dot(normal)
    if cos < Math.epsilon() then
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
      return true
    else
      return false
    end

