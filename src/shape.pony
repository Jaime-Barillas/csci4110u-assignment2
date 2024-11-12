use "random"

class Hit
  var dist: F32
  var point: Vec3
  var normal: Vec3
  var colour: Vec3

  new none() =>
    dist = -1
    point = Vec3.zero()
    normal = Vec3.zero()
    colour = Vec3.zero()

  fun is_none(): Bool => dist < Math.epsilon()

  fun is_closer(other: Hit box): Bool =>
    if is_none() then
      return false
    elseif other.is_none() then
      return true
    end

    dist <= other.dist

  fun random_on_hemisphere(rand: Rand): Vec3 =>
    let dir = normal.random_unit(rand)
    if dir.dot(normal) > 0 then
      return dir
    else
      return -dir
    end

interface val Shape

  fun intersect(ray: Ray, hit: Hit): Bool
    """
    Perform a ray intersection test. Storing the result in `hit`.
    """

