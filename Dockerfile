# syntax=docker/dockerfile:1.0.0-experimental
FROM pytorch/pytorch:1.7.1-cuda11.0-cudnn8-devel

# ssh server
USER root
EXPOSE 2222
EXPOSE 6000
EXPOSE 8088
ENV LANG=en_US.UTF-8
RUN apt update && \
    apt install -y \
        ca-certificates supervisor openssh-server bash ssh tmux \
        curl wget vim procps htop locales nano man net-tools iputils-ping && \
    sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && \
    locale-gen && \
    useradd -m -u 13011 -s /bin/bash toolkit && \
    passwd -d toolkit && \
    useradd -m -u 13011 -s /bin/bash --non-unique console && \
    passwd -d console && \
    useradd -m -u 13011 -s /bin/bash --non-unique _toolchain && \
    passwd -d _toolchain && \
    useradd -m -u 13011 -s /bin/bash --non-unique coder && \
    passwd -d coder && \
    chown -R toolkit:toolkit /run /etc/shadow /etc/profile && \
    apt autoremove --purge && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo ssh >> /etc/securetty && \
    rm -f /etc/legal /etc/motd
COPY --chown=13011:13011 --from=registry.console.elementai.com/shared.image/sshd:base /tk /tk
RUN chmod 0600 /tk/etc/ssh/ssh_host_rsa_key

# some helpful software
RUN apt-get update && \
    apt-get install -y git zsh && \
    apt-get clean;

WORKDIR /app
ENV PYTHONPATH=/app

RUN chmod a+wx /app

RUN mkdir /app/wheels
COPY wheels/* /app/wheels/
RUN pip install /app/wheels/*

COPY main.py main.py
CMD python3 main.py
