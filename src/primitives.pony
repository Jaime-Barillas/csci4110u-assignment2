class val Vec3 is Stringable
  let x: F32
  let y: F32
  let z: F32

  new val zero() =>
    x = 0
    y = 0
    z = 0

  new val create(x': F32, y': F32, z': F32) =>
    x = x'
    y = y'
    z = z'

  fun neg(): Vec3 =>
    Vec3(-x, -y, -z)

  fun add(other: Vec3): Vec3 =>
    Vec3(x + other.x, y + other.y, z + other.z)

  fun sub(other: Vec3): Vec3 =>
    Vec3(x - other.x, y - other.y, z - other.z)

  fun mul(scalar: F32): Vec3 =>
    Vec3(x * scalar, y * scalar, z * scalar)

  fun div(scalar: F32): Vec3 =>
    Vec3(x / scalar, y / scalar, z / scalar)

  fun div_vec3(other: Vec3): Vec3 =>
    Vec3(x / other.x, y / other.y, z / other.z)

  fun length_squared(): F32 =>
    (x * x) + (y * y) + (z * z)

  fun length(): F32 =>
    length_squared().sqrt()

  fun dot(other: Vec3): F32 =>
    (x * other.x) + (y * other.y) + (z * other.z)

  fun cross(other: Vec3): Vec3 =>
    Vec3(
      (y * other.z) - (z * other.y),
      (z * other.x) - (x * other.z),
      (x * other.y) - (y * other.x)
    )

  fun normalized(): Vec3 =>
    let len = ((x * x) + (y * y) + (z * z)).sqrt()
    Vec3(x / len, y / len, z / len)

  fun r(): U8 => (255.999 * x).u8()
  fun g(): U8 => (255.999 * y).u8()
  fun b(): U8 => (255.999 * z).u8()

  fun string(): String iso^ =>
    recover "(" + x.string() + ", " + y.string() + ", " + z.string() + ")" end

type Colour is Vec3


class Ray
  var _origin: Vec3
  var _direction: Vec3

  new create(origin: Vec3, direction: Vec3) =>
    _origin = origin
    _direction = direction

  fun at(step: F32): Vec3 => _origin + (_direction * step)
