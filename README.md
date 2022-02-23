# fortanix-hello-world

Toy example for [fortanix rust-sgx](https://github.com/fortanix/rust-sgx).

We provide two ways to build and run the project:

1. Via `docker`
2. Via `nix` (work-in-progress)

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

**WORK-in-PROGRESS**

**MISSING**:

* `fortanix-sgx-tools` dependency must be added to the `moz.nix` file (for
  `ftxsgx-elf2sgxs` and `ftxsgx-runner`).

In order to work right now, must install `fortanix-sgx-tools` on host system,
and cannot run with `nix-shell --pure` option.

Run:

```console
nix-shell moz.nix
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


## Notes
The `.cargo/config` file contains:

```config
[target.x86_64-fortanix-unknown-sgx]
runner = "ftxsgx-runner-cargo"
```

The equivalent can be set via an environment variable, e.g.:

```shell
CARGO_TARGET_X86_64_FORTANIX_UNKNOWN_SGX_RUNNER = "ftxsgx-runner-cargo"
```
