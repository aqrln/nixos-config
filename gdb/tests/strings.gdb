set pagination off
set confirm off
set may-call-functions off
set print elements 2
set print characters 2

python
import os

gdb.execute("source " + os.path.join(os.environ["RUST_GDB_HELPER_DIR"], "rust_strings.py"))

checked = 0
matched = 0


class CheckStrings(gdb.Breakpoint):
    def stop(self):
        global checked
        try:
            expected = bool(gdb.parse_and_eval("expected"))
            for expression in [
                "$rust_streq(owned, slice)",
                "$rust_streq(&owned, slice)",
                "$rust_streq(slice, &owned)",
            ]:
                assert bool(gdb.parse_and_eval(expression)) == expected, expression
            if checked == 0:
                assert bool(gdb.parse_and_eval('$rust_streq(owned, b"hello")'))
                assert not bool(gdb.parse_and_eval('$rust_streq(slice, b"hell")'))
                try:
                    gdb.parse_and_eval("$rust_streq(expected, slice)")
                except gdb.error:
                    pass
                else:
                    raise AssertionError("accepted a boolean as a string")
            if checked == 3:
                assert bool(gdb.parse_and_eval('$rust_streq(owned, b"")'))
            if checked == 5:
                assert bool(gdb.parse_and_eval(
                    r'$rust_streq(owned, b"caf\xc3\xa9 \xf0\x9f\xa6\x80")'
                ))
            if checked == 6:
                assert bool(gdb.parse_and_eval(r'$rust_streq(owned, b"a\0b")'))
            checked += 1
        except Exception:
            import traceback
            traceback.print_exc()
            gdb.execute("quit 1")
        return False


CheckStrings("strings::inspect")
conditional = gdb.Breakpoint("strings::conditional")
conditional.condition = '$rust_streq(value, b"match")'
conditional.commands = "silent\npython matched += 1\ncontinue"
end

run

python
assert checked == 9, f"expected 9 string cases, got {checked}"
assert matched == 1, f"expected one conditional stop, got {matched}"
assert int(gdb.parse_and_eval("$_exitcode")) == 0
print("PASS: Rust string comparisons and conditional breakpoint (inferior calls disabled)")
end
