{
  description = "fortanix hello world";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.fortanix-sgx-tools.url = "github:initc3/nix-fortanix?dir=fortanix-sgx-tools";
  inputs.sgxs-tools.url = "github:initc3/nix-fortanix?dir=sgxs-tools";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    fortanix-sgx-tools,
    sgxs-tools,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in rec {
          defaultPackage = pkgs.rustPlatform.buildRustPackage rec {
            pname = "fortanix-hello-world";
            version = "0.0.0";

            src = builtins.path {
              path = ./.;
              name = "${pname}-${version}";
            };

            cargoSha256 = "sha256-oI59jnr2Dzkq4rO3+RL2v7f5wudXpSMESo5j8wRrCUY=";

            nativeBuildInputs = with pkgs; [
              fortanix-sgx-tools.defaultPackage.${system}
              (rust-bin.nightly."2021-12-05".default.override {
                targets = [
                  "x86_64-fortanix-unknown-sgx"
                ];
              })
            ];

            buildInputs = with pkgs; [
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
              cp -r target/x86_64-fortanix-unknown-sgx/debug/hello.sgxs $out/bin/hello.sgxs

              runHook postInstall
            '';

            doCheck = false;
          };

          #defaultApp = apps.hello;
          #apps.hello = {
          #  type = "app";
          #  program = "c-hello.packages.${system}.hello";
          #};

          #defaultApp = {
          #  type = "app";
          #  #program = "${fortanix-sgx-tools}.defaultPackage.${system}/bin/ftxsgx-runner" self.defaultPackage/bin/hello.sgxs;
          #  #program = "${fortanix-sgx-tools}.defaultPackage.${system}/bin/ftxsgx-runner --help";
          #  program = "${pkgs}.hello";
          #  #program = pkgs.hello;
          #};

          devShell = pkgs.mkShell {
            CARGO_TARGET_X86_64_FORTANIX_UNKNOWN_SGX_RUNNER = "ftxsgx-runner-cargo";
            buildInputs = with pkgs; [
              fortanix-sgx-tools.defaultPackage.${system}
              (rust-bin.nightly."2021-12-05".default.override {
                targets = [
                  "x86_64-fortanix-unknown-sgx"
                ];
              })
              sgxs-tools.defaultPackage.${system}
            ];
          };
        }
    );
}
