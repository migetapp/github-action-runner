FROM quay.io/podman/stable:latest

USER root
RUN dnf group install -y "C Development Tools and Libraries"
RUN dnf install -y \
    curl \
    jq \
    git \
    sudo \
    tar \
    bzip2 \
    libffi-devel \
    openssl-devel \
    readline-devel \
    zlib-devel \
    libyaml-devel \
    postgresql-devel \
    && dnf clean all

RUN ln -s /usr/bin/podman /usr/bin/docker

RUN mkdir -p /etc/containers/registries.conf.d/ && \
    echo "unqualified-search-registries = [\"docker.io\"]" > /etc/containers/registries.conf.d/default.conf && \
    echo "[[registry]]" >> /etc/containers/registries.conf.d/default.conf && \
    echo "location = \"docker.io\"" >> /etc/containers/registries.conf.d/default.conf

RUN echo '[containers]' > /etc/containers/containers.conf && \
    echo 'default_sysctls = []' >> /etc/containers/containers.conf && \
    echo 'netns="private"' >> /etc/containers/containers.conf && \
    echo 'userns="auto"' >> /etc/containers/containers.conf && \
    echo 'ipcns="private"' >> /etc/containers/containers.conf && \
    echo 'utsns="private"' >> /etc/containers/containers.conf && \
    echo 'cgroupns="private"' >> /etc/containers/containers.conf && \
    echo 'cgroups="enabled"' >> /etc/containers/containers.conf && \
    echo 'log_driver = "k8s-file"' >> /etc/containers/containers.conf && \
    echo '[network]' >> /etc/containers/containers.conf && \
    echo 'default_network="slirp4netns"' >> /etc/containers/containers.conf && \
    echo '[network.slirp4netns]' >> /etc/containers/containers.conf && \
    echo 'enable_ipv6=true' >> /etc/containers/containers.conf && \
    echo 'cidr="10.0.2.0/24"' >> /etc/containers/containers.conf && \
    echo 'mtu=65520' >> /etc/containers/containers.conf && \
    echo 'port_handler="slirp4netns"' >> /etc/containers/containers.conf && \
    echo '[engine]' >> /etc/containers/containers.conf && \
    echo 'cgroup_manager = "cgroupfs"' >> /etc/containers/containers.conf && \
    echo 'events_logger="file"' >> /etc/containers/containers.conf && \
    echo 'runtime="crun"' >> /etc/containers/containers.conf

RUN mkdir -p /home/podman/actions-runner && \
    cd /home/podman/actions-runner && \
    curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz && \
    tar xzf actions-runner-linux-x64.tar.gz && \
    rm actions-runner-linux-x64.tar.gz

RUN mkdir -p /home/podman/runner && \
    chown -R podman:podman /home/podman

RUN cd /home/podman/actions-runner/bin && chmod 755 installdependencies.sh && ./installdependencies.sh

COPY entrypoint.sh /home/podman/entrypoint.sh
RUN chmod +x /home/podman/entrypoint.sh

COPY storage.conf /home/podman/.config/containers/storage.conf

VOLUME /home/podman/runner

USER podman
WORKDIR /home/podman

RUN git clone https://github.com/rbenv/rbenv.git /home/podman/.rbenv \
    && echo 'export PATH="/home/podman/.rbenv/bin:$PATH"' >> /home/podman/.bashrc \
    && echo 'eval "$(rbenv init -)"' >> /home/podman/.bashrc \
    && git clone https://github.com/rbenv/ruby-build.git /home/podman/.rbenv/plugins/ruby-build \
    && echo 'export PATH="/home/podman/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/podman/.bashrc

ENV PATH /home/podman/.rbenv/shims:/home/podman/.rbenv/bin:$PATH

ENTRYPOINT ["/home/podman/entrypoint.sh"]
