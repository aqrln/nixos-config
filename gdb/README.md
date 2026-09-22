Home Manager loads `rust_strings.py` through `~/.config/gdb/gdbinit`.
It takes effect for new GDB sessions after rebuilding the Home Manager
configuration. In an existing session, load it with:

```gdb
source ~/nixos/gdb/rust_strings.py
```

Run `rust-gdb` so the toolchain's Rust pretty-printers are available. Compare
`String`, `&str`, or references to them in a breakpoint condition:

```gdb
condition 1 $rust_streq(name, b"expected")
condition 2 $rust_streq(left, right)
```

In Dape's conditional breakpoint prompt, enter just
`$rust_streq(name, b"expected")`.

The Dape Rust presets pass `-iex "set language rust"` to GDB. This matters
because Dape creates pending breakpoints before loading the executable:
GDB otherwise records the default C expression language and can disable a
breakpoint whose condition contains `b"..."`. In other frontends, use
`set language rust` before creating such pending breakpoints. Recreate an
existing breakpoint after changing the language.

Use a byte-string literal (`b"expected"`): GDB's Rust expression parser may
call the debugged program's allocator to construct an ordinary `"expected"`.
The helper itself only reads memory. It compares the full UTF-8 bytes,
preserves embedded NULs, and ignores display truncation settings. For non-ASCII
byte literals, use UTF-8 escapes, e.g. `b"caf\xc3\xa9"` for `café`.

Run the integration test from the repository root, with `rustc` and `rust-gdb`
from the same toolchain available:

```sh
test_dir=$(mktemp -d)
rustc -g -C opt-level=0 gdb/tests/strings.rs -o "$test_dir/strings"
RUST_GDB_HELPER_DIR="$PWD/gdb" rust-gdb -nx -batch \
  -x gdb/tests/strings.gdb "$test_dir/strings"
RUST_GDB_HELPER_DIR="$PWD/gdb" RUST_GDB_TEST_BINARY="$test_dir/strings" \
  rust-gdb -nx -batch -iex "set language rust" -x gdb/tests/pending.gdb
```
