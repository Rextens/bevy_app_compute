{
  description = "bevy flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs =
              [
                (rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; })
                pkg-config
              ]
              ++ lib.optionals (lib.strings.hasInfix "linux" system) [
                # Zależności Linux
                alsa-lib
                vulkan-loader
                vulkan-tools
                libudev-zero
                xorg.libX11
                xorg.libXcursor
                xorg.libXi
                xorg.libXrandr
                libxkbcommon
                wayland
                wayland-protocols
              ];

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            # Ścieżka do narzędzi rust (rustc, cargo, rustfmt)
            RUSTC_PATH = "${pkgs.rust-bin.stable.latest.default}/bin/rustc";
            CARGO_PATH = "${pkgs.rust-bin.stable.latest.default}/bin/cargo";

            # Możesz dodać także inne ścieżki, jeśli chcesz mieć dostęp do np. rustfmt
            RUSTFMT_PATH = "${pkgs.rust-bin.stable.latest.default}/bin/rustfmt";

            # Ustawienie LD_LIBRARY_PATH dla zależności
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              vulkan-loader
              xorg.libX11
              xorg.libXi
              xorg.libXcursor
              libxkbcommon
            ];
          };

      }
    );
}
