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

  kdePackages = with pkgs.kdePackages; [
    kmail
    kmail-account-wizard
    merkuro
  ];

  devToolsPackages = with pkgs; [
    gnumake
    pkg-config
    python3
    qemu
    rustup
  ];

  lspPackages = with pkgs; [
    nil
  ];

  desktopApps = with pkgs; [
    freecad
    kicad
    libreoffice-qt-fresh
    lingot
  ];

  miscPackages = with pkgs; [
    papirus-icon-theme
  ];

in
{
  imports = [
    ./helix
  ];

  home.stateVersion = "26.05";

  home.packages = kdePackages ++ devToolsPackages ++ lspPackages ++ desktopApps ++ miscPackages;

  xdg.configFile = {
    "konsolerc".source = fromRepo "konsole/konsolerc";
    "kwinrulesrc".source = fromRepo "plasma/kwinrulesrc";
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
      "plasma/look-and-feel/my-dark".source = fromRepo "plasma/look-and-feel/my-dark";
      "plasma/look-and-feel/my-light".source = fromRepo "plasma/look-and-feel/my-light";
    };

  systemd.user.services.onepassword = {
    Unit = {
      Description = "1Password";
      After = [ "plasma-plasmashell.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = ''
        ${lib.getExe pkgs.bash} -c 'until ${lib.getExe' pkgs.systemd "busctl"} --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1; do sleep 0.1; done'
      '';
      ExecStart = "${lib.getExe pkgs._1password-gui} --silent";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.fd.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Fantasque Sans Mono:size=11:fontfeatures=ss01";
        gamma-correct-blending = "yes";
        initial-window-mode = "maximized";
        include = "${pkgs.foot.themes}/share/foot/themes/selenized";
        initial-color-theme = "dark";
      };
      csd.size = 0;
      key-bindings.color-theme-toggle = "Control+Shift+t";
    };
  };

  programs.gcc.enable = true;

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

  programs.ripgrep.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*".IdentityAgent = "~/.1password/agent.sock";
  };

  programs.codex.enable = true;

  programs.zellij.enable = true;
}
