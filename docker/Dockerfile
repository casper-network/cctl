# Dockerfile script to download, create and setup a local casper-node CCTL
# The script is split into two sections across two Debian images:
# Build: install dependencies, download the source code,
# install rust and build the casper-node
# Run: install run time dependencies, create a non root user and
# copy over the compiled binaries from the build ready for cctl start
FROM debian:buster as build

# Allow users to specify forked node, or specific commit
# If not fallback to release branch (or alternatively just specify branch)
ARG NODE_REPO=https://github.com/casper-network/casper-node.git
ARG NODE_COMMIT=
ARG CLIENT_REPO=https://github.com/casper-ecosystem/casper-client-rs.git
ARG CLIENT_COMMIT=
ARG NODE_GITBRANCH=release-1.5.6
ARG CLIENT_GITBRANCH=release-2.0.0

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

RUN git clone https://github.com/casper-network/casper-node-launcher.git \
    && git clone https://github.com/casper-network/cctl.git
RUN if [ -n "$NODE_COMMIT" ]; then \
        git clone -b $NODE_COMMIT $NODE_REPO; \
    else \
        git clone -b $NODE_GITBRANCH $NODE_REPO; \
    fi \
    && if [ -n "$CLIENT_COMMIT" ]; then \
        git clone -b $CLIENT_COMMIT $CLIENT_REPO; \
    else \
        git clone -b $CLIENT_GITBRANCH $CLIENT_REPO; \
    fi

WORKDIR /casper-node

RUN make setup-rs && echo '. /cctl/activate' >> ~/.bashrc

WORKDIR /

COPY ./build.sh .
RUN chmod +x build.sh && source build.sh

COPY ./clean.sh .
RUN chmod +x clean.sh && source clean.sh

FROM debian:buster as run

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
COPY --from=build --chown=cctl:cctl /cctl ./cctl

ENV CCTL="/home/cctl/cctl"

RUN echo "source $CCTL/activate" >> .bashrc

COPY --chown=cctl:cctl ./start.sh .
RUN chmod +x start.sh

EXPOSE 11101-11105 14101-14105 18101-18105

CMD ["/bin/bash", "-c", "source start.sh"]