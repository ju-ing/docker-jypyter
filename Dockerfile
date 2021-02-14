# Systemd inside a Docker container, for CI only
# FROM ubuntu:18.04
From nvidia/cuda:11.0-devel-ubuntu18.04

RUN apt-get update --yes

RUN apt-get install --yes systemd curl git sudo wget nano htop zip

RUN wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/libnvinfer7_7.1.3-1+cuda11.0_amd64.deb

RUN apt-get install ./libnvinfer7_7.1.3-1+cuda11.0_amd64.deb --yes

# tensorflow-model-server
RUN echo "deb [arch=amd64] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | tee /etc/apt/sources.list.d/tensorflow-serving.list && \
curl https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | apt-key add -

RUN apt-get update --yes

RUN apt-get install tensorflow-model-server

RUN apt-get autoremove -y

# Kill all the things we don't need
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

RUN mkdir -p /etc/sudoers.d

RUN systemctl set-default multi-user.target

STOPSIGNAL SIGRTMIN+3

# Uncomment these lines for a development install
# ENV TLJH_BOOTSTRAP_DEV=yes
# ENV TLJH_BOOTSTRAP_PIP_SPEC=/srv/src
# ENV PATH=/opt/tljh/hub/bin:${PATH}

CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
