meson setup --vsenv build
meson configure build -Dspng:default_library=shared
meson configure build -Dspng:static_zlib=false
meson configure build -Dzlib:default_library=shared
meson compile -C build

copy build\assignment2.exe build-win\
copy build\subprojects\libspng-0.7.4\spng-0.dll build-win\
copy build\subprojects\zlib-1.2.13\z.dll build-win\
