if not exist ".\build\assignment2.exe" (
	meson setup --vsenv build
	meson configure build -Dspng:default_library=shared
	meson configure build -Dspng:static_zlib=false
	meson configure build -Dzlib:default_library=shared
	meson compile -C build
)

mkdir out
.\build\assignment2.exe %*
