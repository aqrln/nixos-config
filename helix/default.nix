{
  programs.helix = {
    enable = true;

    themes.selenized = import ./selenized.nix;

    settings = {
      theme = "selenized";
      editor.shell = [ "fish" "-c" ];
    };

    languages.rust-analyzer.config.cargo = {
      allFeatures = true;
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
