use "collections"
use "spng"
use "random"
use "debug"

type RayTracer is (PathTracer | DistributedTracer)

actor ImageBuilder
  let image_name: String
  let image_size: USize
  let _image: Array[U8]
  var _done_count: U32 = 0
  var _ray_count: U32 = 0

  let env: Env

  new create(image_name': String, image_size': USize, env': Env) =>
    image_name = image_name'
    image_size = image_size'
    env = env'
    _image = Array[U8].init(0, image_size * image_size * 3)

  be add_ray_count(ray_count: U32) =>
    _ray_count = _ray_count + ray_count

  be add_pixels(pixels: Array[U8] iso, row: USize) =>
    let dest_idx = row * image_size * 3
    let size = pixels.size()
    _image.copy_from(consume pixels, 0, dest_idx, size)
    _done_count = _done_count + 1

    if _done_count >= image_size.u32() then
      save_image()
    end

  be save_image() =>
    Spng.save_image(image_name, _image, image_size.u32(), image_size.u32())
    env.out.print("Saved image " + image_name)
    let total_pixels = image_size * image_size
    env.out.print("Average rays per pixel: " + (_ray_count.f32() / total_pixels.f32()).string())

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

  var ray_count: U32 = 0

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
      ray_count = ray_count + 1
      let shadow_ray = scene.light.random_ray(rand, closest_hit.point)
      if scene.in_light(shadow_ray) then
        return colour'
      else
        return (scene.ambient_colour * contribution * 0.2)
      end
    end

    // Otherwise, reflect.
    let dir = closest_hit.normal + closest_hit.random_on_hemisphere(rand)
    ray_count = ray_count + 1
    let ray' = Ray(closest_hit.point, dir)
    trace_ray(ray', colour', 0.5 * contribution)

  be render_pixel(x: USize) =>
    let idx = x * 3

    var colour = Colour(0, 0, 0)
    for sample in Range(0, spp) do
      ray_count = ray_count + 1
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
    image.add_ray_count(ray_count)

  be render() =>
    for x in Range(0, image_size) do
      render_pixel(x)
    end
    submit_row()

actor DistributedTracer
  var pixels: Array[U8] iso
  let rand: Rand
  let minimum_contribution: F32 = 0.01

  let scene: Scene
  let row: USize
  let grid_size: USize
  let image_size: USize
  let image: ImageBuilder
  let env: Env

  var ray_count: U32 = 0

  new create(scene': Scene,
             row': USize,
             grid_size': USize,
             image_size': USize,
             image': ImageBuilder,
             env': Env) =>
    rand = Rand(row'.u64())
    scene = scene'
    row = row'
    grid_size = grid_size'
    image_size = image_size'
    image = image'
    env = env'
    pixels = Array[U8].init(0, image_size * 3)

  fun ref trace_ray(ray: Ray, colour: Colour, contribution: F32 = 0.5, depth: USize = 0): Colour =>
    if depth >= 2 then
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
    if closest_hit.is_none() and (depth == 0) then
      return scene.ambient_colour
    end

    // We hit something!
    if closest_hit.is_light then
      // It was a light source.
      if depth == 0 then
        return closest_hit.colour // BRIGHT light source.
      else
        return colour + closest_hit.colour // light highlights.
      end
    end

    let colour' = colour + (closest_hit.colour * contribution)
    var in_shadow: F32 = 0
    var reflect_colour = Colour(0, 0, 0)

    let reflection_dir = closest_hit.reflection_dir(ray.direction)
    let u = reflection_dir.cross(closest_hit.normal)
    let v = u.cross(reflection_dir)
    let pixel_size = scene.camera.pixel_delta_u.x
    let cell_delta = pixel_size / grid_size.f32()
    let corner = reflection_dir - ((u + v) * (pixel_size / 2))
    for subray_num in Range(0, grid_size * grid_size) do
      ray_count = ray_count + 1
      let shadow_ray = scene.light.grid_ray(closest_hit.point, subray_num, grid_size)
      if scene.in_light(shadow_ray) then
        in_shadow = in_shadow + 1
      end

      let cell_x = (subray_num % grid_size).f32()
      let cell_y = (subray_num / grid_size).f32()
      let offset = ((u * cell_x) + (v * cell_y)) * cell_delta
      let dir = corner + offset
      ray_count = ray_count + 1
      let ray' = Ray(closest_hit.point, dir)
      reflect_colour = reflect_colour + trace_ray(ray', Colour(0, 0, 0), 0.2 * contribution, depth + 1)
    end
    reflect_colour = reflect_colour / (grid_size * grid_size).f32()
    in_shadow = in_shadow / (grid_size * grid_size).f32()
    (colour' + reflect_colour) * in_shadow

  be render_pixel(x: USize) =>
    let idx = x * 3

    var colour = Colour(0, 0, 0)
    for sample in Range(0, grid_size * grid_size) do
      ray_count = ray_count + 1
      let ray = scene.camera.pixel_grid_ray(sample, grid_size, x.f32(), row.f32())
      colour = colour + trace_ray(ray, Colour(0, 0, 0))
    end
    colour = colour / (grid_size * grid_size).f32()

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
    image.add_ray_count(ray_count)

  be render() =>
    for x in Range(0, image_size) do
      render_pixel(x)
    end
    submit_row()
