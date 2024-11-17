#import "../../typst-template.typ": otech
#show: otech.with(
  title: [CSCI4110U - Assignment 2],
  authors: ("Jaime Barillas - 100505421",)
)


= Compiling

== Via Docker (Preffered)

+ Build the image: `docker build -t 100505421 .`
+ Create and run a container: `docker run --rm -v${PWD}/out:/app/out 100505421 <args...>`

== Manually

Install Build dependencies:
- Install Ninja (tested on v1.12.1)
- Install Meson (tested on v1.5.1)
- Install the Pony compiler (tested on v0.58.6)
- Install VS Build Tools ~v17.7.4 (on Windows)
- Run either `run.bat` or `run.sh`: `./run.sh <args...>`

= Evaluation

The following images were generated on a laptop with an Intel I7-7700HQ CPU.
Implementation details follow the images.

== Path Tracing

Each image is 512x512 pixels in size and can be viewed in the `./out` folder.
Each object in the scene is treated as a purely diffuse object.

Varying the number of paths per pixel raises the average rays per pixel, and
execution time, in proportion. A reasonable image with moderate to little noise
can be had with a mere 128 paths per pixels.

#grid(
  columns: 4,
  gutter: 5pt,
  image("out/render-512-8.png"),
  image("out/render-512-16.png"),
  image("out/render-512-32.png"),
  image("out/render-512-64.png"),
  [Path tracing at 8 samples per pixel. \~0.6 sec averaging \~13 rays per pixel.],
  [Path tracing at 16 samples per pixel. \~0.9 sec averaging \~26 rays per pixel.],
  [Path tracing at 32 samples per pixel. \~1.4 sec averaging \~52 rays per pixel.],
  [Path tracing at 64 samples per pixel. \~2.5 sec averaging \~104 rays per pixel.]
)
  
#grid(
  columns: 4,
  gutter: 5pt,
  image("out/render-512-128.png"),
  image("out/render-512-256.png"),
  image("out/render-512-512.png"),
  rect(width: 50%, fill: none, stroke: none),
  [Path tracing at 128 samples per pixel. \~4.5 sec averaging \~208 rays per pixel.],
  [Path tracing at 256 samples per pixel. \~8.5 sec averaging \~415 rays per pixel.],
  [Path tracing at 512 samples per pixel. \~19 sec averaging \~831 rays per pixel.]
)

== Distributed Ray Tracing

Each image is 128x128 pixels in size. Each object in the scene exhibits
mirror-like "perfect" reflection instead of diffuse. I only had the patience to
wait for renders with a grid size of up to 5x5. To get a reasonable image, with
my implementation, a higher grid size (and more patience) is required.

#grid(
  columns: 4,
  gutter: 5pt,
  image("out/render-128-1.png"),
  image("out/render-128-2.png"),
  image("out/render-128-3.png"),
  image("out/render-128-4.png"),
  [Distributed tracing with a grid size of 1x1. \~0.02 sec averaging \~3 rays per pixel.],
  [Distributed tracing with a grid size of 2x2. \~0.1 sec averaging \~93 rays per pixel.],
  [Distributed tracing with a grid size of 3x3. \~0.7 sec averaging \~915 rays per pixel.],
  [Distributed tracing with a grid size of 4x4. \~9.4 sec averaging \~4886 rays per pixel.]
)

#grid(
  columns: 4,
  gutter: 5pt,
  image("out/render-128-5.png"),
  rect(width: 50%, fill: none, stroke: none),
  rect(width: 50%, fill: none, stroke: none),
  rect(width: 50%, fill: none, stroke: none),
  [Distributed tracing with a grid size of 5x5. \~40.4 sec averaging \~18218 rays per pixel.],
)

= Implementation Details (Light)

The program is implemented in the #link("https://www.ponylang.io")[Pony]
programming language. The general overview of the program is as follows (green
boxes are actors):
#figure(
  image("out/overview.png", width: 80%),
  caption: [Program overview.]
)

The `Main` class initializes up the `Scene`, `ImageBuilder`, and `PathTracer`/
`DistributedTracer` classes/actors. The `Scene` class maintains both eye and
scene object data, the `ImageBuilder` actor recieves pixel data and generates
the final image file, and the `PathTracer`/`DistributedTracer` actors perform
the actual ray tracing. One ray tracer actor is instantiated for _each row of
pixels_ and generates the pixel colours using the scene data from the `Scene`
class, then sends the entire row of pixels to the `ImageBuilder` actor.

== Path Tracing

Rays are generated from the `Camera` class (`src/camera.pony`) by calculating
the position of the target pixel, plus a random offset, on the image plane: \
(`pixel_0` is the position of the top-left pixel on the image plane.
`pixel_delta_*` is the length of a pixel on the image plane.)
#figure(
  image("out/random-pixel-ray.png", width: 80%),
  caption: [Creating a ray from the eye position to a pixel.]
)

The `PathTracer` actor (`src/renderers.pony`) uses these rays as the primary
ray for each pixel. Once all primary rays have finished being traced, their
resulting colours are averaged and saved to an array containing the pixel data:
#figure(
  image("out/path-render-pixel.png", width: 80%),
  caption: [
    `spp` holds the number of paths per pixel, `pixels` is the pixel
    array.
  ]
)

The `trace_ray` function is where the most of the computation happens. It is a
bit long so only the important sections of code are shown. This function
iterates the objects in the scene and performs intersection tests, keeping only
the closest intersection:
#figure(
  image("out/path-shape-intersection.png", width: 80%),
  caption: [
    The `Hit` class (`src/shapes.pony`) stores information about the
    intersection, including the intersection point, normal, and object colour.
  ]
)

Assuming the ray hit an object, the `trace_ray` function then either shoots a
shadow ray or a reflection ray. In the case of a shadow ray, a ray towards a
random point on the light (an `AreaLight`, `src/arealight.pony`) is created and
used to determine if the intersection point is in light:
#grid(
  columns: 2,
  gutter: 5pt,
  image("out/path-shadow-ray.png"),
  image("out/path-light-random-ray.png"),
  [The object colour is returned unchanged if the point is in light, some ambient colour is returned otherwise.],
  [The `random_ray` function of the `AreaLight` class.]
)

If a reflection ray is traced, the generated reflection direction is a random
direction on the hemisphere of the intersection. This technique was taken from
the _Raytracing in One Weekend_ website, which also informed the code (to the
extent that it could be translated to Pony):
#grid(
  columns: 2,
  gutter: 5pt,
  image("out/path-reflection-ray.png"),
  image("out/path-random-hemisphere.png"),
  [`trace_ray` recursively follows the reflected ray. It terminates once the ray's contribution reaches a minimum.],
  [`Hit.random_on_hemisphere`, `src/shape.pony`. Generates a direction vector pointing away from the surface.]
)

== Distributed Tracing

The code is much the same to the Path Tracing code, so only notable differences
are described.

First, primary, reflection, and shadow rays are generated in a grid-like
pattern. The code between them is similar so only the code for primary rays
is shown below. The size of the grid for reflection rays is the same as the
size used for primary rays which causes the reflected rays to be close in
proximity to each other and mimic mirror reflections.
#figure(
  image("out/distr-camera-random-grid-ray.png"),
  caption: [
    `src/camera.pony`, `grid_size` is the length of one side of the (square)
    grid. See also the `grid_ray` function in `src/arealight.pony` and the
    `trace_ray` function of the _DistributedTracer_ actor in
    `src/renderers.pony`.
  ]
)

The following code is gnarly because it interleaves shadow rays, reflection
rays, and the calculation of the grid pattern for the reflection rays. The
first set of `let` statements calculate the direction vectors used to move
along the grid pattern for the reflected rays using two cross products. It
also finds the starting `corner` of the grid pattern.
#figure(
  image("out/distr-big-1.png"),
  caption: [`src/renderers.pony`]
)

The ray tracer then loops through each subray for both shadow rays and
reflection rays at the same time. For shadow rays, it counts how many rays
reach the light source, which will be averaged and then multiplied against the
final colour to produce shadows. This calculation is what causes the odd
shadow shading on objects in the distributed tracer images. Properly
calculating the colour and averaging it should fix these issues.
#figure(
  image("out/distr-big-2.png"),
  caption: [The first part of the for loop for shadow and reflection rays.]
)

Lastly, the reflection ray direction is calculated, the rays are recursively
traced and the resulting colours and shadow values are averaged and mixed
together.
#figure(
  image("out/distr-big-3.png"),
  caption: [The rest of the for loop and mixing the resulting colours.]
)

== Shape Intersection

See the `intersect` function in the `src/sphere.pony`, `src/plane.pony`, and
`src/arealight.pony` files. The code for the `src/sphere.pony` intersection
comes from the _Raytracing in One Weekend_ website.

