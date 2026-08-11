{
  disko,
  pkgs,
  system,
}:

pkgs.writeShellApplication {
  name = "install-vetiver";
  runtimeInputs = [
    disko.packages.${system}.disko
    pkgs.coreutils
    pkgs.git
    pkgs.gnugrep
    pkgs.nixos-install-tools
    pkgs.nvme-cli
    pkgs.systemd
    pkgs.util-linux
  ];
  text = ''
    set -euo pipefail

    target=/dev/nvme0n1
    key_file=/tmp/disk.key
    repo_dir=$PWD

    if [[ $EUID -ne 0 ]]; then
      exec sudo "$0" "$@"
    fi

    if [[ ! -f $repo_dir/flake.nix || ! -f $repo_dir/disko.nix ]]; then
      echo "Run this app from the root of the nixos configuration repository." >&2
      exit 1
    fi

    if [[ ! -b $target ]]; then
      echo "$target is not a block device." >&2
      exit 1
    fi

    if lsblk -nrpo MOUNTPOINTS "$target" | grep -q '[^[:space:]]'; then
      echo "$target or one of its children is mounted; boot the NixOS installer first." >&2
      lsblk -o NAME,TYPE,SIZE,MOUNTPOINTS "$target" >&2
      exit 1
    fi

    if [[ -e $key_file ]]; then
      echo "$key_file already exists; refusing to overwrite it." >&2
      exit 1
    fi

    if ! nvme id-ns "$target" -H | grep -Eq 'LBA Format +1.*Data Size: 4096 bytes'; then
      echo "$target does not report LBA format 1 as 4096 bytes." >&2
      exit 1
    fi

    echo "WARNING: this will irreversibly erase $target and reinstall vetiver."
    echo "Its NVMe namespace will be reformatted to native 4096-byte LBAs."
    read -r -p "Type 'FORMAT $target' to continue: " confirmation
    if [[ $confirmation != "FORMAT $target" ]]; then
      echo "Aborted."
      exit 1
    fi

    nvme format "$target" --lbaf=1
    udevadm settle

    logical_sector_size=$(blockdev --getss "$target")
    if [[ $logical_sector_size != 4096 ]]; then
      echo "Expected a 4096-byte logical sector after formatting, got $logical_sector_size." >&2
      exit 1
    fi

    while true; do
      read -r -s -p "New LUKS password: " password
      echo
      read -r -s -p "Confirm LUKS password: " password_confirmation
      echo

      if [[ -n $password && $password == "$password_confirmation" ]]; then
        break
      fi

      echo "Passwords did not match or were empty; try again." >&2
    done

    install -m 600 /dev/null "$key_file"
    trap 'rm -f "$key_file"' EXIT
    printf %s "$password" > "$key_file"
    unset password password_confirmation

    disko --mode destroy,format,mount "$repo_dir/disko.nix"
    nixos-install --root /mnt --flake "$repo_dir#vetiver"

    git clone --no-hardlinks "$repo_dir" /mnt/home/aqrln/nixos
    nixos-enter --root /mnt -c \
      'chown -R aqrln:users /home/aqrln/nixos'

    rm -f /mnt/etc/nixos/configuration.nix
    ln -sfn /home/aqrln/nixos/flake.nix /mnt/etc/nixos/flake.nix

    rm -f "$key_file"
    trap - EXIT
    echo "Installation complete. You may reboot."
  '';
}
