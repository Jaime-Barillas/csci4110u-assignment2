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
  let scene: Array[Shape val] val = [
    Sphere(Vec3( 0.00,  0.00, -1), 0.35, Colour(188,  79,  79))
    Sphere(Vec3(-0.60,  0.25, -2), 0.35, Colour( 79, 188,  79))
    Sphere(Vec3( 1.00, -0.80, -3), 0.35, Colour( 79,  79, 188))
    Plane(Vec3(0, -1, -1), Vec3(0, -1, 0), Colour(211, 220, 237))
    /* Area Light */
    Plane(Vec3(0, 1, -1), Vec3(0, 1, 0), Colour(255, 255, 255))
  ]

  /**** Runtime Known Vars ****/
  let image: ImageBuilder
  let camera: Camera

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

    image = ImageBuilder(image_size)
    camera = Camera(Vec3(0, 0, 0), Vec3(2, 2, 0), image_size)

    env.out.print("Renderer: " + renderer.string())
    env.out.print("Size: " + image_size.string() + "x" + image_size.string())
    env.out.print("Samples per pixel: " + spp.string())
    Debug.out("======================")
    Debug.out("Pixel delta: " + (camera.pixel_delta_u + camera.pixel_delta_v).string())

    render_image()

  be render_image() =>
    let start_time = Time.millis()

    for row in Range(0, image_size) do
      match renderer
      | Path => PathTracer(camera, scene, image_size, row, image, env).render()
      | Distributed => PathTracer(camera, scene, image_size, row, image, env).render()
      end
    end

    let ellapsed = (Time.millis() - start_time).f32()
    env.out.print("Done in " + (ellapsed / 1000).string() + " seconds")

