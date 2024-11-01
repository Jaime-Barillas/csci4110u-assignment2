use "lib:spng"
use "lib:z"

use @spng_version_string[Pointer[U8]]()

actor Main
  new create(env: Env) =>
    let str = recover val String.copy_cpointer(@spng_version_string(), 5) end
    env.out.print("Hello, World!")
    env.out.print(str)
