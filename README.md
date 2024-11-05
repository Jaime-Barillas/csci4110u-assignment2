# Compiling & Running

## Linux - Docker (Preferred)

1. Build the image: `docker build -t 100505421 .`
2. Create and run a container: `docker run --rm -v${PWD}/out:/app/out 100505421 <args...>`

## Using The Script

1. Install Ninja v1.12.1
2. Install Meson v1.5.1
3. Install the Pony compiler v0.58.6
4. Install VS Build Tools ~v17.7.4 (on Windows)
5. Run either `run.bat` or `run.sh`: `./run.sh <args...>`

## Linux - Meson

1. Install Ninja v1.12.1
2. Install Meson v1.5.1
3. Install the Pony compiler v0.58.6
4. Setup the Meson build dir: `meson setup build`
5. Compile the program: `meson compile -C build`
6. Run the program: `./build/assignment2`

## Windows - Meson

1. Install Ninja v1.12.1
2. Install Meson v1.5.1
3. Install the Pony compiler v0.58.6
4. Install VS Build Tools ~v17.7.4
5. Setup the Meson build dir: `meson setup --vsenv build`
6. Configure Meson for a dynamically linked exe:
   1. `meson configure build -Dspng:default_library=shared`
   2. `meson configure build -Dspng:static_zlib=false`
   3. `meson configure build -Dzlib:default_library=shared`
7. Compile the program: `meson compile -C build`
8. Run the program: `./build/assignment2.exe`
