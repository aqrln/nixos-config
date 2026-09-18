{
  config,
  inputs,
  pkgs,
  ...
}:

let
  lilypond-mode = pkgs.runCommand "lilypond-mode-${pkgs.lilypond.version}" { } ''
    mkdir -p "$out/share/emacs/site-lisp"
    cp ${pkgs.lilypond}/share/emacs/site-lisp/*.el "$out/share/emacs/site-lisp/"
    chmod u+w "$out/share/emacs/site-lisp/"*.el

    # Preserve dynamic binding while satisfying Emacs 31's explicit-cookie
    # requirement. lilypond-words.el is completion data, not Lisp code.
    for file in "$out/share/emacs/site-lisp/"*.el; do
      case "$file" in */lilypond-words.el) continue ;; esac
      if ! head -n 1 "$file" | grep -q 'lexical-binding:'; then
        sed -i '1s/$/ -*- lexical-binding: nil; -*-/' "$file"
      fi
    done
  '';

  # Drop the version override once nixpkgs includes Codex ACP 1.11.0 or newer.
  # Keep the patch until ACP also recognizes the "priority" service tier.
  codex-acp = pkgs.codex-acp.overrideAttrs (
    finalAttrs: old: {
      version = "1.11.0";

      src = pkgs.fetchFromGitHub {
        owner = "agentclientprotocol";
        repo = "codex-acp";
        tag = "v${finalAttrs.version}";
        hash = "sha256-u3uYZnMVJHGF9IWlXdIAdHWPiGC3ENFIEAaU4Nv0l7M=";
      };

      npmDepsHash = "sha256-MpBjRpOrOE7mGAAZEe1jwxR0XLf7IXsdWhtkAhuREaM=";
      npmDeps = pkgs.fetchNpmDeps {
        name = "codex-acp-${finalAttrs.version}-npm-deps";
        inherit (finalAttrs) src;
        hash = finalAttrs.npmDepsHash;
      };

      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/CodexAcpServer.ts \
          --replace-fail \
            'sessionMetadata.currentServiceTier === "fast"' \
          '["fast", "priority"].includes(sessionMetadata.currentServiceTier ?? "")'
      '';
    }
  );
in
{
  programs.emacs = {
    enable = true;

    package = pkgs.emacs31-pgtk;

    overrides = final: prev: {
      # Keep Markdown parsing upstream; expose image display to terminal backends.
      agent-shell = prev.agent-shell.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./agent-shell-image-backends.patch ];
      });
      # Majutsu is manually packaged, so emacs-overlay does not refresh it.
      majutsu = prev.majutsu.overrideAttrs (old: {
        version = "0.6.0-unstable-2026-09-11";
        src = pkgs.fetchFromGitHub {
          owner = "0WD0";
          repo = "majutsu";
          rev = "56b6e263cd4ecaf8e44e955647bffafe56f54f34";
          hash = "sha256-pMNImWrUKE6CV57Euy/ce1QtomxeWqenBllldPU1WFI=";
        };
        packageRequires = old.packageRequires ++ [ final.compat ];
      });
    };

    extraPackages =
      epkgs:
      let
        kitty-graphics = epkgs.trivialBuild {
          pname = "kitty-graphics";
          version = "1.4.0";
          src = inputs.kitty-graphics;
        };
      in
      with epkgs;
      [
        agent-shell
        (trivialBuild {
          pname = "agent-shell-kitty-graphics";
          version = "0.1.0";
          src = ./agent-shell-kitty-graphics.el;
          packageRequires = [
            agent-shell
            kitty-graphics
          ];
        })
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
        gptel
        gptel-agent
        kitty-graphics
        lilypond-mode
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
        with-editor
      ];

    extraConfig = ''
      ;; Prefer the patched mode over LilyPond's copy in the user profile.
      (add-to-list 'load-path "${lilypond-mode}/share/emacs/site-lisp")
    '' + builtins.readFile ./init.el;
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
  systemd.user.services.emacs.Service = {
    Environment = [
      "GDK_BACKEND=wayland"
      "COLORTERM=truecolor"
    ];
    OOMPolicy = "continue";
  };

  home.packages = [
    codex-acp
    pkgs.imagemagick
    pkgs.libsixel
    pkgs.tree # gptel-agent's Glob tool
  ];
}
