{
  "ui.help" = {
    fg = "white";
    bg = "black";
  };

  "ui.popup" = {
    bg = "black";
  };
  "ui.popup.info" = {
    fg = "white";
    bg = "black";
  };

  "ui.selection" = {
    bg = "selection";
  };
  "ui.selection.primary" = {
    bg = "selection-primary";
  };

  "ui.virtual.whitespace" = "light-gray";
  "ui.virtual.indent-guide" = "gray";
  "ui.virtual.inlay-hint" = {
    fg = "gray";
    modifiers = [ "italic" ];
  };
  "ui.virtual.jump-label" = {
    fg = "light-red";
    modifiers = [
      "bold"
      "underlined"
    ];
  };
  "ui.virtual.ruler" = {
    bg = "black";
  };

  "ui.window" = {
    bg = "black";
  };
  "ui.gutter" = {
    bg = "black";
  };

  "ui.menu" = {
    fg = "white";
    bg = "black";
  };
  "ui.menu.selected" = {
    fg = "blue";
    modifiers = [
      "bold"
      "reversed"
    ];
  };
  "ui.menu.scroll" = {
    fg = "light-blue";
    bg = "black";
  };

  "ui.statusline" = {
    bg = "black";
  };
  "ui.statusline.inactive" = {
    fg = "light-gray";
    bg = "black";
  };
  "ui.statusline.normal" = {
    fg = "blue";
    modifiers = [
      "bold"
      "reversed"
    ];
  };
  "ui.statusline.insert" = {
    fg = "green";
    modifiers = [
      "bold"
      "reversed"
    ];
  };
  "ui.statusline.select" = {
    fg = "magenta";
    modifiers = [
      "bold"
      "reversed"
    ];
  };
  "ui.statusline.separator" = "light-gray";

  "ui.cursor.primary" = {
    modifiers = [
      "bold"
      "reversed"
    ];
  };
  "ui.cursor.secondary" = {
    fg = "gray";
    modifiers = [ "reversed" ];
  };
  "ui.cursor.match" = {
    fg = "light-yellow";
    modifiers = [
      "bold"
      "underlined"
    ];
  };
  "ui.cursor.normal" = {
    fg = "blue";
    modifiers = [ "reversed" ];
  };
  "ui.cursor.insert" = {
    fg = "green";
    modifiers = [ "reversed" ];
  };
  "ui.cursor.select" = {
    fg = "magenta";
    modifiers = [ "reversed" ];
  };
  "ui.cursorline.primary" = {
    bg = "black";
  };

  "ui.linenr" = {
    fg = "light-gray";
    bg = "black";
  };
  "ui.linenr.selected" = {
    fg = "light-blue";
    bg = "black";
    modifiers = [ "bold" ];
  };

  comment = {
    fg = "light-gray";
    modifiers = [ "italic" ];
  };
  constant = "cyan";
  "constant.builtin" = {
    fg = "cyan";
    modifiers = [ "bold" ];
  };
  "constant.character.escape" = {
    fg = "light-red";
    modifiers = [ "bold" ];
  };
  type = "violet";
  "type.builtin" = {
    fg = "violet";
    modifiers = [ "bold" ];
  };
  "type.enum.variant" = "light-violet";
  constructor = "violet";
  string = "cyan";
  "variable.builtin" = {
    modifiers = [ "bold" ];
  };
  function = "blue";
  "function.builtin" = {
    fg = "blue";
    modifiers = [ "bold" ];
  };
  "function.macro" = "orange";
  keyword = "green";
  "keyword.directive" = "orange";
  "keyword.storage.modifier" = "yellow";
  label = "magenta";
  namespace = "violet";
  punctuation = "light-gray";
  operator = "yellow";
  special = {
    fg = "magenta";
    modifiers = [ "bold" ];
  };

  "markup.heading" = {
    modifiers = [ "bold" ];
  };
  "markup.heading.marker" = {
    fg = "yellow";
    modifiers = [ "bold" ];
  };
  "markup.list" = "red";
  "markup.bold" = {
    modifiers = [ "bold" ];
  };
  "markup.link.text" = {
    fg = "light-blue";
    modifiers = [ "underlined" ];
  };
  "markup.link.label" = "violet";
  "markup.link.url" = {
    fg = "cyan";
  };
  "markup.quote" = "light-gray";

  "diff.plus" = "light-green";
  "diff.delta" = "yellow";
  "diff.minus" = "light-red";

  info = "light-blue";
  hint = "light-gray";
  debug = "light-gray";
  warning = "yellow";
  error = "light-red";

  "diagnostic.hint" = {
    underline = {
      color = "gray";
      style = "curl";
    };
  };
  "diagnostic.info" = {
    underline = {
      color = "light-blue";
      style = "curl";
    };
  };
  "diagnostic.warning" = {
    underline = {
      color = "yellow";
      style = "curl";
    };
  };
  "diagnostic.error" = {
    underline = {
      color = "light-red";
      style = "curl";
    };
  };
  "diagnostic.unnecessary" = {
    modifiers = [ "dim" ];
  };
  "diagnostic.deprecated" = {
    modifiers = [ "crossed_out" ];
  };

  palette = {
    selection = "#184956";
    selection-primary = "#2d5b69";

    orange = "#ed8649";
    violet = "#af88eb";
    light-orange = "#fd9456";
    light-violet = "#bd96fa";
  };
}
