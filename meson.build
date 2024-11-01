project('assignment2', 'c',
  default_options: ['default_library=static', 'buildtype=release']
)

libspng = subproject('spng', default_options: ['static_zlib=true'])

ponyc = find_program('ponyc')

assignment_exe = custom_target('assignment2_exe',
  output: 'assignment',
  build_by_default: true,
  command: [ponyc, '--output', '@OUTDIR@', '--bin-name', 'assignment2', '@SOURCE_ROOT@/src'],
)
