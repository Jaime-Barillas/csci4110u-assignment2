class val Camera
  let position: Vec3
  let pixel_0: Vec3
  let pixel_delta_u: Vec3
  let pixel_delta_v: Vec3

  new val create(position': Vec3, image_plane_size': Vec3, image_size': USize) =>
    position = position'
    pixel_0 = Vec3(-1, 1, -1) // Top left pixel
    pixel_delta_u = Vec3(image_plane_size'.x / image_size'.f32(), 0, 0)
    pixel_delta_v = Vec3(0, -image_plane_size'.y / image_size'.f32(), 0)

