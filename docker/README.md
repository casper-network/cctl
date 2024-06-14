## Casper Node CCTL Docker

The following instructions enable developers to spin up a local dockerised casper-node using cctl.

### Build

After starting docker on your machine follow these simple instructions:

Build and run using `docker build` or `docker compose`:
```bash
git clone git@github.com:casper-network/cctl.git && cd cctl/docker

docker build . --build-arg NODE_GITBRANCH=feat-2.0 --build-arg CLIENT_GITBRANCH=release-2.0.0 -t cspr-cctl/feat-2.0
# or
docker compose up # optional: -d argument detaches it from terminal
```

Here are some additional build args:
```bash
# Additional build args:
--build-arg NODE_REPO= # Specify forked/modified node repository
--build-arg CLIENT_REPO= # Specify forked/modified client repository
--build-arg CCTL_REPO= # Specify forked/modified CCTL repository
--build-arg SIDECAR_REPO= # Specify forked/modified sidecar repository
--build-arg NODE_LAUNCHER_REPO= # Specify forked/modified node launcher repository

--build-arg NODE_COMMIT= # Specify commit hash from default or custom node repo
--build-arg CLIENT_COMMIT= # Specify commit hash from default or custom client repo
--build-arg CCTL_COMMIT= # Specify commit hash from default or CCTL client repo
--build-arg SIDECAR_COMMIT= # Specify commit hash from default or custom sidecar repo
--build-arg NODE_LAUNCHER_COMMIT= # Specify commit hash from default or custom node launcher repo

--build-arg NODE_GITBRANCH= # Specify branch name
--build-arg CLIENT_GITBRANCH= # Specify branch name
--build-arg CCTL_GITBRANCH= # Specify branch name
--build-arg SIDECAR_GITBRANCH= # Specify branch name
--build-arg NODE_LAUNCHER_GITBRANCH= # Specify branch name
```

The build will take approx 30 mins. After this the docker system will store the built layers sensibly negating the need for future full builds.

### Run

Now we have a built cctl docker image we can run it using `docker run` or `docker compose up`:

Run using `docker run`:
```bash
# Run the container forwarding the required ports
docker run -it --name cspr-cctl -d -p 25101:25101 -p 21101:21101 -p 14101:14101 -p 18101:18101 cspr-cctl/feat-2.0
```

Run using `docker compose`:
```bash
# Docker compose will handle the port forwarding, and will show 'healthy' once the first block is processed
# Make sure the docker-compose.yaml file is in your current working directory, or specify it using the `-f` flag
docker compose up -d
```

And test that it's started with one of the following options, the last is `docker compose` only:

```bash
docker exec -t cspr-cctl /bin/bash -c -i 'cctl-infra-net-status'
# or
docker exec -t -i  cspr-cctl /bin/bash
cctl-infra-net-status
# or
docker logs cspr-cctl

# These will output the following if the network is running:
validator-group-1:cctl-node-1            RUNNING   pid 79858, uptime 0:00:02
validator-group-1:cctl-node-1-sidecar    RUNNING   pid 79859, uptime 0:00:02
validator-group-1:cctl-node-2            RUNNING   pid 79860, uptime 0:00:02
validator-group-1:cctl-node-2-sidecar    RUNNING   pid 79861, uptime 0:00:02
validator-group-1:cctl-node-3            RUNNING   pid 79862, uptime 0:00:02
validator-group-1:cctl-node-3-sidecar    RUNNING   pid 79863, uptime 0:00:02
validator-group-2:cctl-node-4            RUNNING   pid 79895, uptime 0:00:01
validator-group-2:cctl-node-4-sidecar    RUNNING   pid 79896, uptime 0:00:01
validator-group-2:cctl-node-5            RUNNING   pid 79897, uptime 0:00:01
validator-group-2:cctl-node-5-sidecar    RUNNING   pid 79898, uptime 0:00:01
```

```bash
# docker compose only, container will say healthy once ready
docker compose ps
    NAME          IMAGE                                                                     COMMAND                  SERVICE   CREATED       STATUS                 PORTS
    kairos-cctl   sha256:6a206d32a671c7c08afbed964ad40f4a3a367afb9060442bb39866d22475c2a2   "/bin/bash -c 'sourc…"   cctl      2 hours ago   Up 2 hours (healthy)   0.0.0.0:21101->21101/tcp, :::21101->21101/tcp, 11102-11105/tcp, 0.0.0.0:14101->14101/tcp, :::14101->14101/tcp, 14102-14105/tcp, 0.0.0.0:18101->18101/tcp, :::18101->18101/tcp, 0.0.0.0:25101->25101/tcp, :::25101->25101/tcp, 18102-18105/tcp
```

### Use

Now that we have a docker image with exposed ports we can run it via localhost:

```bash
curl --location 'http://localhost:21101/rpc' \
--header 'Content-Type: application/json' \
--data '{
    "id": "383766004",
    "jsonrpc": "2.0",
    "method": "info_get_chainspec",
    "params": []
}'
```

Or we can exec into the image and run the supplied cctl aliases:

```bash
docker exec -t -i  cspr-cctl /bin/bash
cctl-chain-view-genesis-chainspec
```

[TODO: Add a deploy example]

To view how cctl can be used within a project view the following Terminus SDK test projects:

- [Java](https://github.com/casper-sdks/terminus-java-tests)

- [Python](https://github.com/casper-sdks/terminus-python-tests)

- [Go](https://github.com/casper-sdks/terminus-go-tests)

- [JS](https://github.com/casper-sdks/terminus-js-tests)

- [C#](https://github.com/casper-sdks/terminus-dotnet-tests)

### Pre-built images

Pre-built images can be found [here](https://hub.docker.com/repository/docker/stormeye2000/cspr-cctl/general)