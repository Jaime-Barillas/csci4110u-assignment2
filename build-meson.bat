meson setup --vsenv build
meson configure build -Dspng:default_library=shared
meson configure build -Dspng:static_zlib=false
meson configure build -Dzlib:default_library=shared
meson compile -C build
