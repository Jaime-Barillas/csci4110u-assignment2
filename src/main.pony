use "spng"
use "debug"
use "collections"
use "time"

primitive Path
  fun string(): String => "path"
primitive Distributed
  fun string(): String => "distributed"

type Renderer is (Path | Distributed)

actor Main
  let env: Env

  /**** Program Inputs ****/
  var renderer: Renderer = Path
  var image_size: USize = 512
  var spp: I32 = 100

  /**** Statically Known Vars ****/
  let eye: Vec3 = Vec3(0, 0, 0)
  let iplane_size: Vec3 = Vec3(2, 2, 0) // Image plane, ranges [-1, 1]
  let pixel_0: Vec3 = Vec3(-1, 1, -1) // Top left pixel, image plane at z = -1
  let scene: Array[Shape val] val = [
    Sphere(Vec3( 0.00,  0.00, -1), 0.35, Colour(188,  79,  79))
    Sphere(Vec3(-0.60,  0.25, -2), 0.35, Colour( 79, 188,  79))
    Sphere(Vec3( 1.00, -0.80, -3), 0.35, Colour( 79,  79, 188))
    Plane(Vec3(0, -1, -1), Vec3(0, -1, 0), Colour(211, 220, 237))
    /* Area Light */
    Plane(Vec3(0, 1, -1), Vec3(0, 1, 0), Colour(255, 255, 255))
  ]

  /**** Runtime Known Vars ****/
  let image: Array[U8]
  var pixel_delta_u: Vec3
  var pixel_delta_v: Vec3

  new create(env': Env) =>
    env = env'

    try
      match env.args(1)?
      | "path" => renderer = Path
      | "distributed" => renderer = Distributed
      end
    end
    try
      image_size = env.args(2)?.usize()?.max(1)
    end
    try
      spp = env.args(3)?.i32()?.max(1)
    end

    pixel_delta_u = Vec3(iplane_size.x / image_size.f32(), 0, 0)
    pixel_delta_v = Vec3(0, -iplane_size.y / image_size.f32(), 0)

    env.out.print("Renderer: " + renderer.string())
    env.out.print("Size: " + image_size.string() + "x" + image_size.string())
    env.out.print("Samples per pixel: " + spp.string())
    Debug.out("======================")
    Debug.out("Pixel delta: " + (pixel_delta_u + pixel_delta_v).string())

    image = Array[U8].init(0, image_size * image_size * 3)
    render_image()

  be render_image() =>
    let start_time = Time.millis()

    for y in Range(0, image_size) do
      for x in Range(0, image_size) do
        let idx = (x * 3) + (y * image_size * 3)
        let pixel = pixel_0 + (pixel_delta_u * x.f32()) + (pixel_delta_v * y.f32())
        let ray_direction = pixel - eye
        let ray = Ray(eye, ray_direction)

        // ray_colour() function
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
          image(idx + 0)? = colour.r()
          image(idx + 1)? = colour.g()
          image(idx + 2)? = colour.b()
        end
      end
    end

    let ellapsed = (Time.millis() - start_time).f32()
    env.out.print("Done in " + (ellapsed / 1000).string() + " seconds")

    Spng.save_image("src/test.png", image, image_size.u32(), image_size.u32())


    // let scene: Array[Shape] val = [
    //   // Plane(position, normal, colour)
    //   Plane(Vec3(0, -1, 0), Vec3(0, 1, 0), Vec3(190, 190, 190))

    //   // Sphere(position, radius, colour)
    //   Sphere(Vec3( 0.0,  0.3, 0), 0.25, Vec3(188,  79,  79))
    //   Sphere(Vec3(-0.1,  0.0, 0), 0.25, Vec3( 79, 188,  79))
    //   Sphere(Vec3( 0.0, -0.2, 0), 0.25, Vec3( 79,  79, 188))

    //   // AreaLight(Position, normal, width, length, colour)
    //   // AreaLight(Vec3(0.1, 0.8, 0), Vec3(0, -1, 0), 0.6, 0.1, Vec3(255, 255, 255))
    // ]

    // let width: USize = 128
    // let height: USize = 128
    // let arr = Array[U8].init(255, width * height * 3)
    // // let scene: Array[Shape] = [
    // //   Sphere(Vec3(0.25, 0.5, 0), 0.5, Vec3(1, 1, 1))
    // //   Plane(Vec3(3, -4, -10), Vec3(0, 0, 1), Vec3(1, 1, 1))
    // //   Sphere(Vec3(-0.25, -0.25, -2), 0.5, Vec3(1, 1, 1))]
    // var closest_shape: Shape val = Sphere(Vec3(0, 0, 0), 0, Vec3(1, 1, 1)) // dummy value to start with.

    // // Each pixel pos (center)
    // let offset: F32 = 2 / (2 * width.f32())
    // let pix_x = Range[USize](0, width)
    // let pix_y = Range[USize](0, height)
    // let ray_s = Vec3(0, 0, 5)
    // for y in pix_y do
    //   pix_x.rewind()
    //   for x in pix_x do
    //     let pix_idx = (x * 3) + (y * width * 3)
    //     let pix_xpos = (((x.f32() / width.f32()) * 2) - 1) + offset // [-1, +1] offset to center of pixel
    //     let pix_ypos = (((y.f32() / height.f32()) * -2) + 1) + offset // [-1, +1] "" and sample top-down to ensure png is right-side-up.

    //     let ray_d = Vec3(pix_xpos, pix_ypos, 0)
    //     ray_d - ray_s
    //     ray_d.normalize()
    //     //Debug.out("arr["+(pix_idx/3).string()+"] ("+pix_xpos.string()+", "+pix_ypos.string()+") - ray: ("+
    //     //  ray_d.x.string()+", "+ray_d.y.string()+", "+ray_d.z.string()+")")
    //     var closest_t: F32 = F32.max_value()
    //     for shape in scene.values() do
    //       let t = shape.ray_intersection(ray_s, ray_d)
    //       if (t > 0) and (t < closest_t) then
    //         closest_shape = shape
    //         closest_t = t
    //       end
    //     end

    //     match closest_shape
    //     | let sh: Sphere =>
    //       try // Red
    //         arr(pix_idx + 1)? = 0
    //         arr(pix_idx + 2)? = 0
    //       end
    //     | let sh: Plane =>
    //       try // Green
    //         arr(pix_idx)? = 0
    //         arr(pix_idx + 2)? = 0
    //       end
    //     end
    //   end
    // end

