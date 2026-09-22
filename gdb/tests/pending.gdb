# Start without an executable, just like Dape's GDB adapter.
# The caller supplies -iex "set language rust" from the Rust preset.
set pagination off
set confirm off
set breakpoint pending on
set may-call-functions off

python
import os

helper_dir = os.environ["RUST_GDB_HELPER_DIR"]
gdb.execute("source " + os.path.join(helper_dir, "rust_strings.py"))
bp = gdb.Breakpoint(source=os.path.join(helper_dir, "tests", "strings.rs"), line=8)
bp.condition = '$rust_streq(value, b"match")'
gdb.execute("file " + os.environ["RUST_GDB_TEST_BINARY"])
assert len(bp.locations) == 1 and bp.locations[0].enabled
end

run

python
assert gdb.selected_frame().name() == "strings::conditional"
assert _rust_string_bytes(gdb.parse_and_eval("value")) == b"match"
end

continue

python
assert int(gdb.parse_and_eval("$_exitcode")) == 0
print("PASS: pending String breakpoint condition with byte literal")
end
