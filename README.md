# dockerfile-consul-swarm

This repository contains the Dockerfile for a [Consul](https://consul.io) image ready to be run in a [Docker Swarm](https://docs.docker.com/engine/swarm/) (in Swarm mode). The image can be found as an automated build on [Docker Hub](https://hub.docker.com/r/sh4rk/consul-swarm/).

## Usage

In order to use this image you will need a working Docker Swarm in Swarm mode.

It's helpful (but optional) to create a pair of additional Overlay networks. For example:
```
$ docker network create --driver overlay --subnet 10.42.2.0/24 --opt encrypted consul-backend
$ docker network create --driver overlay --subnet 10.42.3.0/24 --opt encrypted consul-client
```

Then, create the `docker` service:

```
$ docker service create --mode global \
                        --name consul \
                        --network consul-backend \
                        --network consul-client \
                        --env "CONSUL_BIND_INTERFACE=eth0" \
                        --env "CONSUL_CLIENT_INTERFACE=eth2" \
                        sh4rk/consul-swarm
```

You can use all further customization options as described by the [official image's docs](https://hub.docker.com/r/_/consul/).

There is no manual bootstrapping required after this step. The containers will automagically discover each other and join a cluster.

## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request! :)

## History

- v0.1.0 (2016-12-11): initial version

## License

This project is licensed under the MIT License. See LICENSE for details.
