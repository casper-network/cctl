## Casper Node CCTL Docker

The following instructions enable developers to spin up a local dockerised casper-node using cctl.

### Build

[TODO: Use docker compose]

After starting docker on your machine follow these simple instructions:

```bash
git clone git@github.com:casper-network/cctl.git && cd cctl/docker

docker build . --build-arg NODE_GITBRANCH=release-1.5.6 --build-arg CLIENT_GITBRANCH=release-2.0.0 -t cspr-cctl/release-1.5.6
```

Where:

- NODE_GITBRANCH = required casper-node branch to build
- CLIENT_GITBRANCH = required  casper-client-rs to build

The build will take approx 30 mins. After this the docker system will store the built layers sensibly negating the need for future full builds.

### Run

Now we have a built cctl docker image we can run it:

First run the container with the required ports:

```bash
docker run -it --name cspr-cctl -d -p 25101:25101 -p 11101:11101 -p 14101:14101 -p 18101:18101 cspr-cctl/release-1.5.6
```

And test that it's started with one of the following options:

```bash
docker exec -t cspr-cctl /bin/bash -c -i 'cctl-infra-net-status'
```

```bash
docker exec -t -i  cspr-cctl /bin/bash
cctl-infra-net-status
```

```bash
docker logs cspr-cctl
```

Either way you should see this output:

```bash
validator-group-1:cctl-node-1    RUNNING   pid 639, uptime 0:53:06
validator-group-1:cctl-node-2    RUNNING   pid 638, uptime 0:53:06
validator-group-1:cctl-node-3    RUNNING   pid 637, uptime 0:53:06
validator-group-2:cctl-node-4    RUNNING   pid 659, uptime 0:53:05
validator-group-2:cctl-node-5    RUNNING   pid 658, uptime 0:53:05
validator-group-3:cctl-node-10   STOPPED   Not started
validator-group-3:cctl-node-6    STOPPED   Not started
validator-group-3:cctl-node-7    STOPPED   Not started
validator-group-3:cctl-node-8    STOPPED   Not started
validator-group-3:cctl-node-9    STOPPED   Not started
```

### Use

Now that we have a docker image with exposed ports we can run it via localhost:

```bash
curl --location 'http://localhost:11101/rpc' \
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

[TODO: Add the links once the Terminus project have migrated to CCTL]

- Java

- Python

- Go

- JS

- C#

  

  

  

  

  

 