{ ... }:

{
  xdg.configFile."gdb/gdbinit".text = ''
    source ${./rust_strings.py}
  '';
}
