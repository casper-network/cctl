# Dockerfile script to download, create and setup a local casper-node CCTL
# The script is split into two sections across two Debian images:
# Build: install dependencies, download the source code,
# install rust and build the casper-node
# Run: install run time dependencies, create a non root user and
# copy over the compiled binaries from the build ready for cctl start
FROM debian:buster AS build

# Allow users to specify forked node, or specific commit
# If not fallback to release branch (or alternatively just specify branch)
ARG NODE_REPO=https://github.com/casper-network/casper-node.git
ARG NODE_COMMIT=
ARG NODE_GITBRANCH=feat-2.0

ARG CLIENT_REPO=https://github.com/casper-ecosystem/casper-client-rs.git
ARG CLIENT_GITBRANCH=
ARG CLIENT_COMMIT=609ac2892140e664663e69f12185a62c247fd566

ARG SIDECAR_REPO=https://github.com/casper-network/casper-sidecar.git
ARG SIDECAR_GITBRANCH=feat-2.0
ARG SIDECAR_COMMIT=


RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y sudo tzdata curl gnupg gcc git ca-certificates \
        protobuf-compiler libprotobuf-dev \
        pkg-config libssl-dev make build-essential gettext-base lsof cmake\
        && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

RUN curl -f -L https://static.rust-lang.org/rustup.sh -O \
    && sh rustup.sh -y
ENV PATH="$PATH:/root/.cargo/bin"

RUN git clone https://github.com/casper-network/casper-node-launcher.git
RUN if [ -n "$NODE_COMMIT" ]; then \
        git clone $NODE_REPO && cd casper-node && git checkout $NODE_COMMIT && cd ..; \
    else \
        git clone -b $NODE_GITBRANCH $NODE_REPO; \
    fi \
    && if [ -n "$CLIENT_COMMIT" ]; then \
        git clone $CLIENT_REPO && cd casper-client-rs && git checkout $CLIENT_COMMIT && cd ..; \
    else \
        git clone -b $CLIENT_GITBRANCH $CLIENT_REPO; \
    fi \
    && if [ -n "$SIDECAR_COMMIT" ]; then \
        git clone $SIDECAR_REPO && cd casper-sidecar && git checkout $SIDECAR_COMMIT && cd ..; \
    else \
        git clone -b $SIDECAR_GITBRANCH $SIDECAR_REPO; \
    fi

# Local CCTL source code.
COPY ./cmds ./cctl/cmds
COPY ./resources ./cctl/resources
COPY ./utils ./cctl/utils
COPY ./activate ./cctl/activate

WORKDIR /casper-node

RUN make setup-rs && echo '. /cctl/activate' >> ~/.bashrc

WORKDIR /

COPY ./docker/build.sh .
RUN chmod +x ./build.sh && source build.sh

COPY ./docker/clean.sh .
RUN chmod +x clean.sh && source clean.sh

FROM debian:buster AS run

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
      && apt-get install -y sudo curl git ca-certificates jq supervisor lsof python3 python3-pip python3-toml \
      && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash cctl && echo "cctl:cctl" | chpasswd && adduser cctl sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER cctl

WORKDIR /home/cctl

COPY --from=build --chown=cctl:cctl /casper-node-launcher ./casper-node-launcher
COPY --from=build --chown=cctl:cctl /casper-client-rs ./casper-client-rs
COPY --from=build --chown=cctl:cctl /casper-node ./casper-node
COPY --from=build --chown=cctl:cctl /casper-sidecar ./casper-sidecar
COPY --from=build --chown=cctl:cctl /cctl ./cctl

ENV CCTL="/home/cctl/cctl"

RUN echo "source $CCTL/activate" >> .bashrc

COPY --chown=cctl:cctl ./docker/start.sh .
RUN chmod +x start.sh

EXPOSE 11101-11105 12101-12105 13101-13105 14101-14105 21101-21105 22101-22105

HEALTHCHECK --interval=10s --timeout=5s --retries=4 --start-period=20s \
    CMD curl --silent --location 'http://127.0.0.1:21101/rpc' --header 'Content-Type: application/json' --data '{"id": "1", "jsonrpc": "2.0", "method": "info_get_status", "params": []}' | jq -e -n 'input.result.reactor_state' | grep "Validate"

CMD ["/bin/bash", "-c", "source start.sh"]
