{
  programs.helix = {
    enable = true;

    themes.selenized = import ./selenized.nix;

    settings = {
      theme = "selenized";
      editor.shell = [
        "fish"
        "-c"
      ];
    };

    languages.language-server.rust-analyzer.config.cargo = {
      features = "all";
      targetDir = true;
    };

    languages.language = [
      {
        name = "markdown";
        soft-wrap.enable = true;
      }
    ];
  };
}
