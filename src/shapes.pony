/*
interface Shape
  fun ref get_colour(): Vec3

  fun ray_intersection(pos: Vec3, dir: Vec3): F32
    """
    Return the number of steps the ray must travel along its direction to
    intersect with this shape.
    Returns a negative number if there is no intersection.
    """

class val Sphere
  let position: Vec3
  let radius: F32
  let colour: Vec3 ref

  new create(position': Vec3, radius': F32, colour': Vec3) =>
    position = position'.copy()
    radius = radius'
    colour = colour'

  fun ref get_colour(): Vec3 => colour

  fun ray_intersection(pos: Vec3, dir: Vec3): F32 =>
    // Ray-sphere intersection, quadratic formula coefficients:
    let a = dir.dot(dir)
    let ray_to_sphere = pos.copy() - position
    let b = 2 * ray_to_sphere.dot(dir)
    let c = ray_to_sphere.dot(ray_to_sphere) - (radius * radius)

    // Quadratic formula.
    let discriminant = (b * b) - (4 * a * c)
    // No real square roots => no intersection.
    if (discriminant < 0) then
      return -1
    end

    let sqrt = discriminant.sqrt()
    let root_add = -b + sqrt
    let root_sub = -b - sqrt

    // No positive roots => intersections occurred _behind_ the ray.
    // 0 == intersection at start of ray, bad for reflection/light rays and not
    // something to worry about for the primary ray.
    if (root_add <= 0) and (root_sub <= 0) then
      return -1
    // One root is negative, return the positive one.
    elseif (root_add <= 0) then
      return root_sub / (2 * a)
    elseif (root_sub <= 0) then
      return root_add / (2 * a)
    // Both are positive, return the closest one.
    else
      let ans_a = root_add / (2 * a)
      let ans_b = root_sub / (2 * a)
      return ans_a.min(ans_b)
    end


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
