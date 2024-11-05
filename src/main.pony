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
  var renderer: Renderer = Path
  var image_size: USize = 512
  var spp: I32 = 100
  let image: Array[U8]

  new create(env: Env) =>
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

    env.out.print("Renderer: " + renderer.string())
    env.out.print("Size: " + image_size.string() + "x" + image_size.string())
    env.out.print("Samples per pixel: " + spp.string())

    image = Array[U8].init(0, image_size * image_size * 3)
    render_image()

  be render_image() =>
    for y in Range(0, image_size) do
      for x in Range(0, image_size) do
        let idx = (x * 3) + (y * image_size * 3)
        try
          image(idx + 0)? = 255
          image(idx + 1)? = 0
          image(idx + 2)? = 0
        end
      end
    end

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

    // let start_time = Time.millis()

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

    // let end_time = Time.millis()
    // Debug.out((end_time - start_time).string() + " milliseconds")

