# fortanix-hello-world
Toy example for [fortanix rust-sgx](https://github.com/fortanix/rust-sgx).

We provide two ways to build and run the project:

1. Via `docker`
2. Via `nix` (work-in-progress)

## Prerequisites
Requires an SGX-enabled computer.

If you have `nix` installed you can quickly check with:

```console
nix shell github:initc3/nix-fortanix?dir=sgxs-tools -c sgx-detect
```

Alternatively, install `sgxs-tools`, and run `sgx-detect`. Note that you may
need to install `protobuf-compiler` (assuming Debian), e.g.:

```console
apt-get install protobuf-compiler
```

```console
cargo install sgxs-tools
```
```console
sgx-detect
```

See https://github.com/ayeks/SGX-hardware for help.

## Hello World with Docker
See the [`Dockerfile`](./Dockerfile) for learning purposes.

To build the image to run the hello world app:

```console
docker build --tag fortanix-hello-world .
```

Run it:

```console
docker run --rm -it \
        --device /dev/isgx \
        --volume /var/run/aesmd:/var/run/aesmd \
    fortanix-hello-world
```

Note that this assumes you have installed the out-of-tree SGX driver, and the
aesm service.

For development and experimentation purposes build the `dev` target:

```console
docker build --target dev --tag fortanix-hello-world:dev .
```

and start a bash session in a container:

```console
docker run --rm -it \
        --device /dev/isgx \
        --volume /var/run/aesmd:/var/run/aesmd \
    fortanix-hello-world:dev bash
```

Run the app with `cargo`:

```console
root@e77744f76a00:/usr/src/hello-world# cargo run --target x86_64-fortanix-unknown-sgx
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `ftxsgx-runner-cargo target/x86_64-fortanix-unknown-sgx/debug/hello`
Hello, world!
```

## Hello World with Nix
Install `nix` if you don't have it.

Run:

```console
nix-shell --pure
```

To run with `cargo`:

```console
cargo run --target x86_64-fortanix-unknown-sgx
```

To build with cargo:

```console
cargo build --target x86_64-fortanix-unknown-sgx
```

```console
ftxsgx-elf2sgxs target/x86_64-fortanix-unknown-sgx/debug/hello \
            --heap-size 0x20000 \
            --stack-size 0x20000 \
            --debug
```

Run:

```console
ftxsgx-runner ./target/x86_64-fortanix-unknown-sgx/debug/hello.sgxs
```
