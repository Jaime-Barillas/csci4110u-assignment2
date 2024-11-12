use "random"

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

  fun val random_unit(rand: Rand): Vec3 =>
    var new_x: F64 = 1
    var new_y: F64 = 1
    var new_z: F64 = 1
    var len_squared: F64 = 2

    repeat
      new_x = rand.real()
      new_y = rand.real()
      new_z = rand.real()
      len_squared = (new_x * new_x) + (new_y * new_y) + (new_z * new_z)
    until (len_squared <= 1) /*and (len_squared > F32.epsilon().f64())*/ end

    let len = len_squared.sqrt()
    Vec3(
      (new_x / len).f32(),
      (new_y / len).f32(),
      (new_z / len).f32()
    )

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

  // Should be x.sqrt() for proper gamma, but this look "better".
  fun r(): U8 => (255.999 * x.pow(0.666)).u8()
  fun g(): U8 => (255.999 * y.pow(0.666)).u8()
  fun b(): U8 => (255.999 * z.pow(0.666)).u8()

  fun string(): String iso^ =>
    recover "(" + x.string() + ", " + y.string() + ", " + z.string() + ")" end

type Colour is Vec3

