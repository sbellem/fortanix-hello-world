let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs {overlays = [(import sources.nixpkgs-mozilla)];};
  fortanix = import sources.fortanix;
in
  with nixpkgs;
    stdenv.mkDerivation {
      name = "fortanix-hello-world";

      buildInputs = [
        fortanix.fortanix-sgx-tools
        fortanix.sgxs-tools
        (nixpkgs.latest.rustChannels.nightly.rust.override {
          targets = [
            "x86_64-fortanix-unknown-sgx"
          ];
        })
      ];

      LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";

      CARGO_TARGET_X86_64_FORTANIX_UNKNOWN_SGX_RUNNER = "ftxsgx-runner-cargo";
    }
