class val Scene
  let camera: Camera
  let light: AreaLight
  let shapes: Array[Shape] val
  let ambient_colour: Colour = Colour(89/255, 124/255, 178/255) // Sky blue

  new val create(camera': Camera) =>
    // Hard code scene.
    camera = camera'
    // Note: AreaLight position is "back-left" corner.
    light = AreaLight(Vec3(-0.5, 1.0, -1.5), 1, 1.5, Colour(1, 1, 1))
    shapes = [
      Sphere(Vec3( 0.00,  0.00, -1), 0.35, Colour(188/255,  79/255,  79/255))
      Sphere(Vec3(-0.60,  0.25, -2), 0.35, Colour( 79/255, 188/255,  79/255))
      Sphere(Vec3( 1.00, -0.80, -3), 0.35, Colour( 79/255,  79/255, 188/255))
      Plane(Vec3(0, -1, -1), Vec3(0, 1, 0), Colour(211/255, 220/255, 237/255))
      light
    ]

  fun box in_light(ray: Ray): Bool =>
    var closest_hit = Hit.none()
    var hit_idx: USize = 0 // Hack: Light obj is always last item in shapes.
    for shape in shapes.values() do
      let hit = Hit.none()
      if shape.intersect(ray, hit) and hit.is_closer(closest_hit) then
        closest_hit = hit
        hit_idx = hit_idx + 1
      end
    end

    hit_idx == (shapes.size() - 1)

