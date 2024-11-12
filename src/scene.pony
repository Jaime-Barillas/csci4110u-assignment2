class val Scene
  let camera: Camera
  let light: AreaLight
  let shapes: Array[Shape] val

  new val create(camera': Camera) =>
    // Hard code scene.
    camera = camera'
    light = AreaLight(Vec3(-0.25, 1, -1), 0.5, 0.5, Colour(1, 1, 1))
    shapes = [
      Sphere(Vec3( 0.00,  0.00, -1), 0.35, Colour(188/255,  79/255,  79/255))
      Sphere(Vec3(-0.60,  0.25, -2), 0.35, Colour( 79/255, 188/255,  79/255))
      Sphere(Vec3( 1.00, -0.80, -3), 0.35, Colour( 79/255,  79/255, 188/255))
      Plane(Vec3(0, -1, -1), Vec3(0, -1, 0), Colour(211/255, 220/255, 237/255))
      light
    ]

