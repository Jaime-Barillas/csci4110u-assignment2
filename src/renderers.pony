use "collections"
use "spng"
use "random"
use "debug"

type RayTracer is (PathTracer | DistributedTracer)

actor ImageBuilder
  let image_size: USize
  let _image: Array[U8]
  var _done_count: U32 = 0

  new create(image_size': USize) =>
    image_size = image_size'
    _image = Array[U8].init(0, image_size * image_size * 3)

  be add_pixels(pixels: Array[U8] iso, row: USize) =>
    let dest_idx = row * image_size * 3
    let size = pixels.size()
    _image.copy_from(consume pixels, 0, dest_idx, size)
    _done_count = _done_count + 1

    if _done_count >= image_size.u32() then
      save_image()
    end

  be save_image() =>
    Spng.save_image("out/render.png", _image, image_size.u32(), image_size.u32())

actor PathTracer
  var pixels: Array[U8] iso
  let rand: Rand
  let minimum_contribution: F32 = 0.001 //0.01 Roughly ~7 iterations for 0.5

  let scene: Scene
  let row: USize
  let spp: USize
  let image_size: USize
  let image: ImageBuilder
  let env: Env

  new create(scene': Scene,
             row': USize,
             spp': USize,
             image_size': USize,
             image': ImageBuilder,
             env': Env) =>
    rand = Rand(row'.u64())
    scene = scene'
    row = row'
    spp = spp'
    image_size = image_size'
    image = image'
    env = env'
    pixels = Array[U8].init(0, image_size * 3)

  fun ref trace_ray(ray: Ray, colour: Colour, contribution: F32 = 0.5): Colour =>
    if contribution < minimum_contribution then
      return colour
    end

    var closest_hit: Hit = Hit.none()
    for shape in scene.shapes.values() do
      let hit = Hit.none()
      if shape.intersect(ray, hit) and hit.is_closer(closest_hit) then
        closest_hit = hit
      end
    end

    // Hit nothing...
    let first_iteration = (0.5 - contribution) < F32.epsilon()
    if closest_hit.is_none() then
      if first_iteration then
        // ...on the first ray, return the ambient colour as the background.
        return scene.ambient_colour
      else
        // ...on reflected rays, add a small ambient amount.
        return colour + (scene.ambient_colour * contribution * 0.2)
      end
    end

    // We hit something!
    if closest_hit.is_light then
      // It was a light source.
      if first_iteration then
        return closest_hit.colour // BRIGHT light source.
      else
        return colour + closest_hit.colour // light highlights.
      end
    end

    let colour' = colour + (closest_hit.colour * contribution)

    // Bounce shadow ray?
    if rand.real() < 0.5 then
      let shadow_ray = scene.light.random_ray(rand, closest_hit.point)
      if scene.in_light(shadow_ray) then
        return colour'
      else
        return (scene.ambient_colour * contribution * 0.2)
      end
    end

    // Otherwise, reflect.
    let dir = closest_hit.normal + closest_hit.random_on_hemisphere(rand)
    let ray' = Ray(closest_hit.point, dir)
    trace_ray(ray', colour', 0.5 * contribution)

  be render_pixel(x: USize) =>
    let idx = x * 3

    var colour = Colour(0, 0, 0)
    for sample in Range(0, spp) do
      let ray = scene.camera.random_pixel_ray(rand, x.f32(), row.f32())
      colour = colour + trace_ray(ray, Colour(0, 0, 0))
    end
    colour = colour / spp.f32()

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

  be render() =>
    for x in Range(0, image_size) do
      render_pixel(x)
    end
    submit_row()

actor DistributedTracer
  new create() => None
