{ pkgs }:

let
  rawBenchmark =
    {
      device,
      name,
    }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.fio
        pkgs.util-linux
      ];
      text = ''
        set -euo pipefail

        device=${device}

        if [[ $EUID -ne 0 ]]; then
          exec sudo "$0" "$@"
        fi

        if [[ ! -b $device ]]; then
          echo "$device is not a block device." >&2
          exit 1
        fi

        lsblk -o NAME,TYPE,SIZE,LOG-SEC,PHY-SEC "$device"
        fio \
          --name=${name} \
          --filename="$device" \
          --readonly \
          --rw=read \
          --bs=1M \
          --direct=1 \
          --ioengine=io_uring \
          --iodepth=32 \
          --size=16G \
          --runtime=30 \
          --time_based \
          --group_reporting
      '';
    };

  nvme = rawBenchmark {
    name = "benchmark-nvme";
    device = "/dev/nvme0n1";
  };

  luks = rawBenchmark {
    name = "benchmark-luks";
    device = "/dev/mapper/cryptlvm";
  };

  filesystem = pkgs.writeShellApplication {
    name = "benchmark-filesystem";
    runtimeInputs = [
      pkgs.e2fsprogs
      pkgs.fio
      pkgs.gawk
      pkgs.gnugrep
    ];
    text = ''
      set -euo pipefail

      test_file=''${1:-./fio-test-uncompressed.tmp}

      if [[ ! -e $test_file ]]; then
        touch "$test_file"
        chattr +C "$test_file"
      fi

      if [[ ! -f $test_file ]]; then
        echo "$test_file is not a regular file." >&2
        exit 1
      fi

      if ! lsattr -d "$test_file" | awk '{ print $1 }' | grep -q C; then
        echo "$test_file does not have the No_COW attribute." >&2
        echo "Remove it and rerun this command so it can be created uncompressed." >&2
        exit 1
      fi

      fio \
        --name=benchmark-filesystem \
        --filename="$test_file" \
        --size=8G \
        --rw=read \
        --bs=1M \
        --direct=1 \
        --ioengine=io_uring \
        --iodepth=32 \
        --runtime=30 \
        --time_based \
        --group_reporting
    '';
  };

  all = pkgs.writeShellApplication {
    name = "benchmark-vetiver";
    runtimeInputs = [
      filesystem
      luks
      nvme
    ];
    text = ''
      set -euo pipefail

      echo "== Physical NVMe (read-only) =="
      benchmark-nvme

      echo
      echo "== Opened LUKS mapper (read-only) =="
      benchmark-luks

      echo
      echo "== Uncompressed filesystem file =="
      benchmark-filesystem "''${1:-./fio-test-uncompressed.tmp}"
    '';
  };
in
{
  inherit
    all
    filesystem
    luks
    nvme
    ;

  package = pkgs.symlinkJoin {
    name = "vetiver-benchmarks";
    paths = [
      all
      filesystem
      luks
      nvme
    ];
  };
}
