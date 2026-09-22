"""Rust string comparisons for GDB breakpoint conditions.

Loaded by the Home Manager GDB init file.  Rust's pretty-printers must
also be available (run rust-gdb) when the function is evaluated.
"""

import gdb


def _rust_string_bytes(value):
    """Read complete string contents, independently of print limits."""
    # In GDB's Rust parser, b"text" is a debugger-owned TYPE_CODE_STRING.
    # Unlike "text" (&str), it does not require an inferior malloc call.
    if value.type.code == gdb.TYPE_CODE_STRING:
        return value.bytes

    while value.type.code in (
        gdb.TYPE_CODE_PTR,
        gdb.TYPE_CODE_REF,
        gdb.TYPE_CODE_RVALUE_REF,
    ):
        value = value.referenced_value()

    # Delegate Rust's unstable String layout to its toolchain's printers.
    printer = gdb.default_visualizer(value)
    if printer is None or printer.display_hint() != "string":
        raise gdb.GdbError(
            "$rust_streq expects Rust String, &str, or a byte-string literal; "
            "use rust-gdb to load Rust's pretty-printers"
        )
    string = printer.to_string()
    if not isinstance(string, gdb.LazyString) or string.length < 0:
        raise gdb.GdbError("$rust_streq requires a string with an explicit length")
    # Empty Rust strings can have a dangling, non-readable data pointer.
    if string.length == 0:
        return b""
    return bytes(gdb.selected_inferior().read_memory(string.address, string.length))


class RustStrEq(gdb.Function):
    """Compare complete Rust strings by their UTF-8 bytes.

Usage: $rust_streq(value, b"expected") or $rust_streq(left, right).
Accepts String, &str, references to these, and Rust byte-string literals.
Returns true for equal contents, including any embedded NUL bytes.
No inferior functions are called by this helper.  Prefer b"expected":
GDB may call the inferior's allocator to construct a plain "expected".
"""

    def __init__(self):
        super().__init__("rust_streq")

    def invoke(self, left, right):
        return _rust_string_bytes(left) == _rust_string_bytes(right)


RustStrEq()
