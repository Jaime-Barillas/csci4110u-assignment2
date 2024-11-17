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

= Path Tracing

The following images were generated on a laptop with an AMD Ryzen 5 7530U CPU.
The laptop was _unplugged and running on battery_ with the default power
profile. Each image is 256x256 pixels in size.

#grid(
  columns: 4,
  gutter: 5pt,
  image("report/path8.png"),
  image("report/path16.png"),
  image("report/path32.png"),
  image("report/path64.png"),
  [Path tracing at 8 samples per pixel. \~1.2 sec.],
  [Path tracing at 16 samples per pixel. \~1.8 sec.],
  [Path tracing at 32 samples per pixel. \~2.4 sec.],
  [Path tracing at 64 samples per pixel. \~3.9 sec.]
)
  
#grid(
  columns: 4,
  gutter: 5pt,
  image("report/path128.png"),
  image("report/path256.png"),
  image("report/path512.png"),
  rect(width: 50%, fill: none, stroke: none),
  [Path tracing at 128 samples per pixel. \~7.1 sec.],
  [Path tracing at 256 samples per pixel. \~13.6 sec.],
  [Path tracing at 512 samples per pixel. \~28.4 sec.]
)

A reasonable image: 128 paths per pixels.

A nice looking image: 1024 paths per pixels.

= Distributed Ray Tracing

A reasonable image: ?x? grid size.
