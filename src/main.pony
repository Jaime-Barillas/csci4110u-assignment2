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
  var spp: USize = 100

  /**** Runtime Known Vars ****/
  let image: ImageBuilder
  let scene: Scene

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
      spp = env.args(3)?.usize()?.max(1)
    end

    image = ImageBuilder("out/render.png", image_size, env)
    scene = Scene(Camera(Vec3(0, 0, 0), Vec3(2, 2, 0), image_size))

    env.out.print("Renderer: " + renderer.string())
    env.out.print("Size: " + image_size.string() + "x" + image_size.string())
    match renderer
    | Path => env.out.print("Samples per pixel: " + spp.string())
    | Distributed => env.out.print("Grid size: " + spp.string() + "x" + spp.string())
    end
    Debug.out("======================")
    Debug.out("Pixel delta: " + (scene.camera.pixel_delta_u + scene.camera.pixel_delta_v).string())

    render_image()

  be render_image() =>
    for row in Range(0, image_size) do
      match renderer
      | Path => PathTracer(scene, row, spp, image_size, image, env).render()
      | Distributed => DistributedTracer(scene, row, spp, image_size, image, env).render()
      end
    end

