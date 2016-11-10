# Rivet

TCP server implementing the protocol for Lab 2.


## Dependencies

This project is built using [elixir](http://www.elixir-lang.org).
Follow the installation guides on [their site](http://www.elixir-lang.org/install.html)

## Compilation

With elixir installed, you can compile the project using `compile.sh`

```bash
$ ./compile.sh [port] [ip address]
```

The port to listen on and the IP address to return in each message can be
specified at compile time. They default to `4000` and `127.0.0.1` respectively.


## Run

Once the project has been compiled, you can run it using `run.sh`

```bash
$ ./run.sh
```
