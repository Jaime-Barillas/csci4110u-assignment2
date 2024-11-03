class Vec3
  var x: F32
  var y: F32
  var z: F32

  new create(x': F32, y': F32, z': F32) =>
    this.x = x'
    this.y = y'
    this.z = z'

  fun box copy(): Vec3 =>
    Vec3(x, y, z)

  fun ref add(other: Vec3 box): Vec3 =>
    x = x + other.x
    y = y + other.y
    z = z + other.z
    this

  fun ref sub(other: Vec3 box): Vec3 =>
    x = x - other.x
    y = y - other.y
    z = z - other.z
    this

  fun ref mul(scalar: F32): Vec3 =>
    x = x * scalar
    y = y * scalar
    z = z * scalar
    this

  fun ref div(scalar: F32): Vec3 =>
    x = x / scalar
    y = y / scalar
    z = z / scalar
    this

  fun box dot(other: Vec3 box): F32 =>
    (x * other.x) + (y * other.y) + (z * other.z)

  fun ref normalize() =>
    let len = ((x * x) + (y * y) + (z * z)).sqrt()
    x = x / len
    y = y / len
    z = z / len

