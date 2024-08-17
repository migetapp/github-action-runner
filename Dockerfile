FROM quay.io/podman/stable:latest

USER root
RUN dnf install -y \
    curl \
    jq \
    git \
    sudo \
    tar \
    gcc \
    glibc-devel \
    libffi-devel \
    openssl-devel \
    make \
    && dnf clean all

RUN cd /home/podman && curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz && \
    tar xzf actions-runner-linux-x64.tar.gz && \
    rm actions-runner-linux-x64.tar.gz

RUN chown podman -R /home/podman

RUN cd /home/podman/bin && chmod 755 installdependencies.sh && ./installdependencies.sh

COPY entrypoint.sh /home/podman/entrypoint.sh
RUN chmod +x /home/podman/entrypoint.sh

COPY storage.conf /home/podman/.config/containers/storage.conf

USER podman
WORKDIR /home/podman

ENTRYPOINT ["/home/podman/entrypoint.sh"]
