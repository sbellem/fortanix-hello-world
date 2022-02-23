FROM rust as dev

RUN apt-get update && apt-get install --yes \
                protobuf-compiler \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/hello-world

COPY rust-toolchain ./

RUN rustup target add x86_64-fortanix-unknown-sgx

RUN cargo install fortanix-sgx-tools sgxs-tools

COPY . .

RUN cargo build --target x86_64-fortanix-unknown-sgx

RUN ftxsgx-elf2sgxs target/x86_64-fortanix-unknown-sgx/debug/hello \
                --heap-size 0x20000 \
                --stack-size 0x20000 \
                --debug

FROM rust

COPY --from=dev /usr/src/hello-world/target/x86_64-fortanix-unknown-sgx/debug/hello.sgxs /opt/hello.sgxs
COPY --from=dev /usr/local/cargo/bin/ftxsgx-runner /usr/local/cargo/bin/

CMD ["ftxsgx-runner", "/opt/hello.sgxs"]
