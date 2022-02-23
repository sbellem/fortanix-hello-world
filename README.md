# fortanix-hello-world

Toy example for fortanix rust-sgx.

See the `Dockerfile` for learning purposes.

To build the image to run the hello world app:

```shell
docker build --tag fortanix-hello-world .
```

Run it:

```shell
docker run --rm -it \
        --device /dev/isgx \
        --volume /var/run/aesmd:/var/run/aesmd \
    fortanix-hello-world
```
```shell
Hello, world!
```

Note that this assumes you have installed the out-of-tree SGX driver, and the
aesm service.

For development and experimentation purposes build the `dev` target:

```shell
docker build --target dev --tag fortanix-hello-world:dev .
```

and start a bash session in a container:

```shell
docker run --rm -it \
        --device /dev/isgx \
        --volume /var/run/aesmd:/var/run/aesmd \
    fortanix-hello-world:dev bash
```

Run the app with `cargo`:

```console
root@e77744f76a00:/usr/src/hello-world# cargo run --target x86_64-fortanix-unknown-sgx
```
```console
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `ftxsgx-runner-cargo target/x86_64-fortanix-unknown-sgx/debug/hello`
Hello, world!
```
