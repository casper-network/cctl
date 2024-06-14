# Dockerfile script to download, create and setup a local casper-node CCTL
# The script is split into two sections across the lates Ubunut image:
# Build: install dependencies, download the source code,
# install rust and build the casper-node
# Run: install run time dependencies, create a non root user and
# copy over the compiled binaries from the build ready for cctl start
FROM ubuntu:latest as build

# Allow users to specify forked node, or specific commit
# If not fallback to release branch (or alternatively just specify branch)
ARG NODE_REPO=https://github.com/casper-network/casper-node.git
ARG CLIENT_REPO=https://github.com/casper-ecosystem/casper-client-rs.git
ARG CCTL_REPO=https://github.com/casper-network/cctl.git
ARG SIDECAR_REPO=https://github.com/casper-network/casper-sidecar.git
ARG NODE_LAUNCHER_REPO=https://github.com/casper-network/casper-node-launcher.git

ARG NODE_COMMIT=f803ee53db31edd5f7f3c1fa1e0ec0ea59550158
ARG NODE_GITBRANCH=release-2.0.0-rc2
ARG CLIENT_GITBRANCH=dev
ARG CLIENT_COMMIT=8f94939fcb1df15d15e9e9f7670c597ab4d4a6fe
ARG CCTL_GITBRANCH=dev
ARG CCTL_COMMIT=
ARG SIDECAR_GITBRANCH=feat-2.0
ARG SIDECAR_COMMIT=d82ec869b626429457b0c54860a1ca6654e11d2d
ARG NODE_LAUNCHER_GITBRAN=main
ARG NODE_LAUNCHER_COMMIT=e115305f332de29564b100b906d9469bf6466edb

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
    && if [ -n "$CCTL_COMMIT" ]; then \
        git clone $CCTL_REPO && cd cctl && git checkout $CCTL_COMMIT && cd ..; \
    else \
        git clone -b $CCTL_GITBRANCH $CCTL_REPO; \
    fi \
    && if [ -n "$SIDECAR_COMMIT" ]; then \
        git clone $SIDECAR_REPO && cd casper-sidecar && git checkout $SIDECAR_COMMIT && cd ..; \
    else \
        git clone -b $SIDECAR_GITBRANCH $SIDECAR_REPO; \
    fi \
    && if [ -n "$NODE_LAUNCHER_COMMIT" ]; then \
        git clone $NODE_LAUNCHER_REPO && cd casper-node-launcher && git checkout $NODE_LAUNCHER_COMMIT && cd ..; \
    else \
        git clone -b $NODE_LAUNCHER_GITBRANCH $NODE_LAUNCHER_REPO; \
    fi

WORKDIR /casper-node

RUN make setup-rs && echo '. /cctl/activate' >> ~/.bashrc

WORKDIR /

COPY ./build.sh .
RUN chmod +x build.sh && source build.sh

COPY ./clean.sh .
RUN chmod +x clean.sh && source clean.sh

FROM ubuntu:latest as run

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
      && DEBIAN_FRONTEND='noninteractive' apt-get install -y python3 \
      && apt-get install -y --no-install-recommends sudo curl git ca-certificates jq supervisor lsof python3-pip python3-toml adduser less \
      && apt-get clean \
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

COPY --chown=cctl:cctl ./start.sh .
RUN chmod +x start.sh

EXPOSE 11101-11105 14101-14105 18101-18105

CMD ["/bin/bash", "-c", "source start.sh"]
