use "lib:spng"
use "lib:z"

/* TODO: Who needs type safety? */
use @fopen[Pointer[None]](pathname: Pointer[U8] tag, mode: Pointer[U8] tag)
use @fclose[I32](stream: Pointer[None] tag)
use @spng_ctx_new[Pointer[None] tag](flags: I32)
use @spng_ctx_free[None](ctx: Pointer[None] tag)
use @spng_set_png_file[I32](ctx: Pointer[None] tag, file: Pointer[None] tag)
use @spng_set_ihdr[I32](ctx: Pointer[None] tag, ihdr: SpngIHdr tag)
use @spng_encode_image[I32](ctx: Pointer[None] tag, img: Pointer[None] tag, len: USize, fmt: I32, flags: I32)

struct SpngIHdr
  var width: U32 = 0
  var height: U32 = 0
  var bit_depth: U8 = 0
  var color_type: U8 = 0
  var compression_method: U8 = 0
  var filter_method: U8 = 0
  var interlace_method: U8 = 0

primitive Spng
  fun save_image(path: String, data: Array[U8] box, width: U32, height: U32) =>
    let mode = "wb"
    let file = @fopen(path.cpointer(), mode.cpointer())
    let ctx = @spng_ctx_new(2) // 2 == SPNG_CTX_ENCODER
    let hdr = SpngIHdr

    hdr.width = width
    hdr.height = height
    hdr.bit_depth = 8
    hdr.color_type = 2 // 2 == SPNG_COLOR_TYPE_TRUECOLOR (No Alpha)

    @spng_set_png_file(ctx, file)
    @spng_set_ihdr(ctx, hdr)
    @spng_encode_image(ctx, data.cpointer(), data.size(), 256, 2)
    // fmt = 256 == SPNG_FMT_PNG (Does not work with others), flags = 2 == SPNG_ENCODE_FINALIZE

    @spng_ctx_free(ctx)
    @fclose(file)

