class Ray
  var origin: Vec3
  var direction: Vec3

  new create(origin': Vec3, direction': Vec3) =>
    origin = origin'
    direction = direction'

  fun at(step: F32): Vec3 => origin + (direction * step)

  fun reflected(point: Vec3, normal: Vec3): Ray =>
    // reflected = dir - 2(dir.dot(normal)) * normal
    let dn = 2 * direction.dot(normal)
    let dir = direction - (normal * dn)
    Ray(point, dir)

