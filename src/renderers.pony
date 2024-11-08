use "collections"
use "spng"
use "debug"

type RayTracer is (PathTracer | DistributedTracer)

actor ImageBuilder
  let image_size: USize
  let image: Array[U8]
  var done_count: U32 = 0

  new create(image_size': USize) =>
    image_size = image_size'
    image = Array[U8].init(0, image_size * image_size * 3)

  be add_pixels(pixels: Array[U8] iso, row: USize) =>
    let dest_idx = row * image_size * 3
    let size = pixels.size()
    image.copy_from(consume pixels, 0, dest_idx, size)
    done_count = done_count + 1

    if done_count >= image_size.u32() then
      save_image()
    end

  be save_image() =>
    Spng.save_image("out/render.png", image, image_size.u32(), image_size.u32())

actor PathTracer
  var pixels: Array[U8] iso

  let camera: Camera
  let scene: Array[Shape] val
  let image_size: USize
  let row: USize
  let image: ImageBuilder
  let env: Env

  new create(camera': Camera,
             scene': Array[Shape] val,
             image_size': USize,
             row': USize,
             image': ImageBuilder,
             env': Env) =>
    camera = camera'
    scene = scene'
    image_size = image_size'
    row = row'
    image = image'
    env = env'
    pixels = Array[U8].init(0, image_size * 3)

  be render() =>
    for x in Range(0, image_size) do
      render_pixel(x)
    end
    submit_row()

  be render_pixel(x: USize) =>
    let idx = x * 3
    let pixel = camera.pixel_0 + (camera.pixel_delta_u * x.f32()) + (camera.pixel_delta_v * row.f32())
    let ray_direction = pixel - camera.position
    let ray = Ray(camera.position, ray_direction)

    let mix = 0.5 * (ray_direction.normalized().y + 1)
    var colour = (Colour(1, 1, 1) * (1 - mix)) + (Colour(0.5, 0.7, 1.0) * mix)
    var closest_dist = F32.max_value()
    for shape in scene.values() do
      let dist = shape.ray_intersection(ray)
      if (dist >= Math.epsilon()) and (dist <= closest_dist) then
        colour = (shape.normal_at(ray.at(dist)) + Vec3(1, 1, 1)) * 0.5
        closest_dist = dist
      end
    end

    try
      pixels(idx + 0)? = colour.r()
      pixels(idx + 1)? = colour.g()
      pixels(idx + 2)? = colour.b()
    else
      env.out.print("Pixels array size: " + pixels.size().string())
    end

  be submit_row() =>
     // Note the destructive read.
    image.add_pixels(pixels = Array[U8], row)

actor DistributedTracer
  new create() => None
