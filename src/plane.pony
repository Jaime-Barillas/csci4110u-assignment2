class val Plane is Shape
  let position: Vec3
  let normal: Vec3
  let colour: Vec3

  new val create(position': Vec3, normal': Vec3, colour': Vec3) =>
    position = position'
    normal = normal'.normalized()
    colour = colour'

  fun intersect(ray: Ray, hit: Hit): Bool =>
    // The situation where the ray is parallel to the plane is always assumed
    // to be non-intersection case. The only time this may be a problem is if
    // the ray lies on the plane.
    let cos = ray.direction.dot(normal)

    // Ray is parallel, assume no intersection.
    if cos.abs() < Math.epsilon() then
      return false
    end

    hit.dist = (position - ray.origin).dot(normal) / cos
    hit.point = ray.at(hit.dist)
    hit.normal = normal
    hit.colour = colour
    true

