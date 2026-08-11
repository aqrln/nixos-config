{
  config,
  inputs,
  lib,
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
  imports = [
    ./helix
  ];

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    nil
    papirus-icon-theme
  ];

  xdg.configFile = {
    "autostart/1password.desktop".text = ''
      [Desktop Entry]
      Name=1Password
      Exec=${lib.getExe pkgs._1password-gui} --silent
      Terminal=false
      Type=Application
      Icon=1password
      StartupWMClass=1Password
      X-GNOME-Autostart-enabled=true
    '';
    "konsolerc".source = fromRepo "konsole/konsolerc";
    "zellij/config.kdl".source = fromRepo "zellij/config.kdl";
  };

  xdg.dataFile =
    lib.mapAttrs'
      (
        name: _:
        lib.nameValuePair "konsole/${name}" {
          source = inputs.selenized + "/terminals/konsole/${name}";
        }
      )
      (
        lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".colorscheme" name) (
          builtins.readDir (inputs.selenized + "/terminals/konsole")
        )
      )
    // {
      "konsole/Default.profile".source = fromRepo "konsole/Default.profile";
    };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Fantasque Sans Mono:size=10.5:fontfeatures=ss01";
        gamma-correct-blending = "yes";
        initial-window-mode = "maximized";
        include = "${pkgs.foot.themes}/share/foot/themes/selenized";
        initial-color-theme = "dark";
      };
      csd.size = 0;
      key-bindings.color-theme-toggle = "Control+Shift+t";
    };
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

  programs.codex.enable = true;
}
