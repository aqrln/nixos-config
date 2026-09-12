{
  config,
  inputs,
  pkgs,
  ...
}:

let
  codex-acp = pkgs.buildNpmPackage rec {
    pname = "agentclientprotocol-codex-acp";
    version = "1.10.0";

    src = pkgs.fetchFromGitHub {
      owner = "agentclientprotocol";
      repo = "codex-acp";
      rev = "v${version}";
      hash = "sha256-D8uYd30NRXQYUSBFCi66Oq0iRZXpl8P7nWv2m3+KBig=";
    };

    npmDepsHash = "sha256-df1/kPiZFBEq9Um26Qbo9XaYj2J8BOXQmunCQWquDTo=";

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      package_dir=$out/lib/node_modules/@agentclientprotocol/codex-acp
      mkdir -p "$package_dir" "$out/bin"

      cp -r dist node_modules package.json README.md LICENSE "$package_dir"

      makeWrapper ${pkgs.nodejs}/bin/node "$out/bin/codex-acp" \
        --add-flags "$package_dir/dist/index.js" \
        --set-default CODEX_PATH ${pkgs.codex}/bin/codex

      runHook postInstall
    '';

    meta = {
      description = "ACP server that exposes Codex CLI functionality";
      homepage = "https://github.com/agentclientprotocol/codex-acp";
      license = pkgs.lib.licenses.asl20;
      mainProgram = "codex-acp";
    };
  };
in
{
  programs.emacs = {
    enable = true;

    package = pkgs.emacs31-pgtk;

    extraPackages =
      epkgs: with epkgs; [
        agent-shell
        avy
        cargo-mode
        consult
        corfu
        embark
        embark-consult
        envrc
        expreg
        fish-mode
        ghostel
        (trivialBuild {
          pname = "kitty-graphics";
          version = "1.1.0";
          src = inputs.kitty-graphics;
        })
        marginalia
        majutsu
        nix-ts-mode
        orderless
        rust-mode
        solarized-theme
        xclip
        (treesit-grammars.with-grammars (
          grammars: with grammars; [
            tree-sitter-bash
            tree-sitter-c
            tree-sitter-cpp
            tree-sitter-css
            tree-sitter-dockerfile
            tree-sitter-fish
            tree-sitter-html
            tree-sitter-javascript
            tree-sitter-json
            tree-sitter-markdown
            tree-sitter-markdown-inline
            tree-sitter-nix
            tree-sitter-python
            tree-sitter-rust
            tree-sitter-toml
            tree-sitter-tsx
            tree-sitter-typescript
            tree-sitter-yaml
          ]
        ))
        vc-jj
        vertico
      ];

    extraConfig = builtins.readFile ./init.el;
  };

  services.emacs = {
    enable = true;
    # Plasma imports the display environment before starting this target.
    startWithUserSession = "graphical";
    package = config.programs.emacs.finalPackage;
    client = {
      enable = true;
      # Plasma also exports DISPLAY for XWayland.  Select the native Wayland
      # display explicitly instead of letting emacsclient fall back to :0.
      arguments = [
        "-c"
        "--display=wayland-0"
      ];
    };
    # defaultEditor = true;
  };

  # A PGTK build running through GTK's X11 backend is unsupported.  Refuse
  # that fallback in the daemon as well as selecting Wayland in the client.
  systemd.user.services.emacs.Service.Environment = [
    "GDK_BACKEND=wayland"
    "COLORTERM=truecolor"
  ];

  home.packages = [
    codex-acp
    pkgs.imagemagick
    pkgs.libsixel
  ];
}
