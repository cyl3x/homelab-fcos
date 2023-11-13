FROM ghcr.io/cyl3x/fcos-zfs:latest

RUN mkdir /tmp/rpms

### zrepl ###
RUN curl -s -L -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/zrepl/zrepl/releases | jq -r '.[0].assets[].browser_download_url | select(endswith(".x86_64.rpm"))' > /tmp/zrepl_url.txt
RUN echo "ZREPL URL: $(cat /tmp/zrepl_url.txt)"
RUN curl -L -o /tmp/rpms/zrepl.x86_64.rpm "$(cat /tmp/zrepl_url.txt)"
### zrepl ###

### starship ###
RUN curl -s -L -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/starship/starship/releases | jq -r '.[0].assets[].browser_download_url | select(endswith("x86_64-unknown-linux-gnu.tar.gz"))' > /tmp/starship_url.txt
RUN echo "STARSHIP URL: $(cat /tmp/starship_url.txt)"
RUN curl -s -L -o /tmp/starship.tar.gz "$(cat /tmp/starship_url.txt)" \
    && tar xzf /tmp/starship.tar.gz --directory=/usr/bin
### starship ###

### yq ###
RUN curl -s -L -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/mikefarah/yq/releases | jq -r '.[0].assets[].browser_download_url | select(endswith("linux_amd64"))' > /tmp/yq_url.txt
RUN echo "YQ URL: $(cat /tmp/yq_url.txt)"
RUN curl -s -L -o /usr/bin/yq "$(cat /tmp/yq_url.txt)"
### yq ###

RUN ls /tmp/rpms/*.rpm
RUN rpm-ostree install /tmp/rpms/*.rpm \
    && ostree container commit
