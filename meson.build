project('assignment2', 'c',
  default_options: ['default_library=static', 'buildtype=release']
)

fs = import('fs')

libspng = subproject('spng', default_options: ['static_zlib=true']).get_variable('spng_lib')
libspng_dir = fs.parent(libspng.full_path())
libzlib = subproject('zlib').get_variable('zlib')
libzlib_dir = fs.parent(libzlib.full_path())

ponyc = find_program('ponyc')
sources = files(
  'src/main.pony',
  'src/spng/spng.pony',
  'src/primitives.pony',
  'src/shapes.pony',
)

ponyc_opts = [
  '--path', libspng_dir,
  '--path', libzlib_dir,
  '--output', '@OUTDIR@',
  '--bin-name', 'assignment2',
]
if get_option('debug')
  ponyc_opts += '--debug'
endif

assignment_exe = custom_target('assignment2_exe',
  output: 'assignment',
  input: sources,
  depends: libspng,
  build_by_default: true,
  command: [
    ponyc,
    ponyc_opts,
    '@SOURCE_ROOT@/src'
  ],
)
