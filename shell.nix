let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs {overlays = [(import sources.rust-overlay)];};
  fortanix = import sources.fortanix;
in
  with nixpkgs;
    mkShell {
      name = "fortanix-hello-world";

      buildInputs = [
        fortanix.fortanix-sgx-tools
        fortanix.sgxs-tools
        (rust-bin.nightly.latest.default.override {
          targets = [
            "x86_64-fortanix-unknown-sgx"
          ];
        })
      ];

      CARGO_TARGET_X86_64_FORTANIX_UNKNOWN_SGX_RUNNER = "ftxsgx-runner-cargo";
    }
