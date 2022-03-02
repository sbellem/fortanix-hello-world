let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs {overlays = [(import sources.rust-overlay)];};
  fortanix = import sources.fortanix;
in
  with nixpkgs;
    rustPlatform.buildRustPackage rec {
      pname = "fortanix-hello-world";
      version = "0.0.0";

      src = builtins.path {
        path = ./.;
        name = "${pname}-${version}";
      };

      cargoSha256 = "sha256-oI59jnr2Dzkq4rO3+RL2v7f5wudXpSMESo5j8wRrCUY=";

      nativeBuildInputs = [
        fortanix.fortanix-sgx-tools
        fortanix.sgxs-tools
        (rust-bin.nightly.latest.default.override {
          targets = [
            "x86_64-fortanix-unknown-sgx"
          ];
        })
      ];

      buildInputs = [
        openssl.dev
      ];

      buildPhase = ''
        runHook preBuild

        cargo build --target x86_64-fortanix-unknown-sgx

        ftxsgx-elf2sgxs target/x86_64-fortanix-unknown-sgx/debug/hello \
          --heap-size 0x20000 \
          --stack-size 0x20000 \
          --debug

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        cp -r target/x86_64-fortanix-unknown-sgx/debug $out/bin/debug

        runHook postInstall
      '';

      doCheck = false;

      #CARGO_TARGET_X86_64_FORTANIX_UNKNOWN_SGX_RUNNER = "ftxsgx-runner-cargo";
    }
