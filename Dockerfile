FROM ubuntu:20.04

EXPOSE 22
ENV DEBIAN_FRONTEND noninteractive
RUN apt update \
 && apt install -y curl wget socat git python3 python3-yaml python3-requests
RUN adduser --home /ops --gecos "" --disabled-password --shell /bin/bash --uid 10042 ops

RUN wget https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz \
  && wget https://storage.googleapis.com/kubernetes-release/release/v1.20.5/bin/linux/amd64/kubectl \
  && wget https://github.com/derailed/k9s/releases/download/v0.24.7/k9s_Linux_x86_64.tar.gz \
  && tar -xvzf  helm-v3.5.3-linux-amd64.tar.gz \
  && tar -xvzf  k9s_Linux_x86_64.tar.gz \
  && mv linux-amd64/helm kubectl k9s /usr/bin \
  && rm -rf linux-amd64 \
  && chmod a+x /usr/bin/kubectl \
  && chmod a+x /usr/bin/k9s \
  && chmod a+x /usr/bin/helm 

ADD pack-publish.sh update-version.sh update-version.py /

#USER ops
#WORKDIR /ops
CMD ["/bin/bash"]
#heml
#k9s
#user 1000
 



