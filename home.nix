{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICJNVFYoy4BuuFkv3jqiFzti+IkGA0dUW0DnJr6dxl+T";
  identity = {
    name = "Oleksii Orlenko";
    email = "alex@aqrln.net";
  };

  # assumes the system flake is in ~/nixos
  fromRepo = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/${path}";

in
{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    nil
  ];

  programs.helix = {
    enable = true;
    settings = {
      # theme = "solarized_dark";
      editor.shell = ["fish" "-c"];
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

  programs.git = {
    enable = true;
    signing = {
      key = signingKey;
      format = "ssh";
      signByDefault = true;
      signer = lib.getExe' pkgs._1password-gui "op-ssh-sign";
    };
    settings = {
      user = identity;
      init.defaultBranch = "main";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = identity;
      git.subprocess = true;
      signing = {
        behavior = "own";
        backend = "ssh";
        key = signingKey;
        backends.ssh.program = lib.getExe' pkgs._1password-gui "op-ssh-sign";
      };
      templates = {
        git_push_bookmark = ''"aqrln-" ++ change_id.short()'';
      };
      aliases.tug = [
        "bookmark"
        "move"
        "--from"
        "heads(::@- & bookmarks())"
        "--to"
        "@-"
      ];
      ui.default-command = "log";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*".IdentityAgent = "~/.1password/agent.sock";
  };
}
