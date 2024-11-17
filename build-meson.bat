meson setup --vsenv build
meson configure -C build -Dspng:default_library=shared
meson configure -C build -Dspng:static_zlib=false
meson configure -C build -Dzlib:default_library=shared
meson compile -C build
