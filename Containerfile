FROM --platform=linux/amd64 cruizba/ubuntu-dind:latest

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    sudo bash wget gpg locales uidmap apt-transport-https ca-certificates curl software-properties-common xz-utils \
    && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

# Google Chrome repository setup
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmour -o /usr/share/keyrings/chrome-keyring.gpg
RUN sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'

# Install dependencies
RUN apt-get update && apt-get install -yy \
build-essential \
dbus-user-session \
google-chrome-stable \
gir1.2-appindicator3-0.1 \
libayatana-appindicator3-dev \
libgtk-3-dev \
libssl-dev \
libxi6 \
libnss3 \
libgconf-2-4 \
libpci-dev \
libglvnd0 \
libbtrfs-dev \
libgpgme-dev \
libdevmapper-dev \
python3 \
python3-pip \
python3-dev \
python3-venv \
python3-gssapi \
git \
jq \
vim \
make \
zip \
unzip \
bzip2 \
xvfb \
fluxbox && \
apt-get clean autoclean && apt-get autoremove --yes && \
rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install firefox
RUN wget -O /tmp/firefox-latest.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar xjf /tmp/firefox-latest.tar.bz2 -C /tmp && mv /tmp/firefox /opt/firefox-latest && \
    rm /tmp/firefox-latest.tar.bz2 && \
    ln -s /opt/firefox-latest/firefox /usr/bin/firefox

# Install chromedriver
RUN CHROME_VERSION=$(curl https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json | jq -r .channels.Stable.version) && \
    wget -O /tmp/chromedriver-linux64.zip https://storage.googleapis.com/chrome-for-testing-public/$CHROME_VERSION/linux64/chromedriver-linux64.zip && \
    unzip /tmp/chromedriver-linux64.zip -d /tmp && mv /tmp/chromedriver-linux64/chromedriver /usr/bin/ && \
    rm /tmp/chromedriver-linux64.zip

RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

ENV DISPLAY=":99"

# Install nix
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --extra-conf "filter-syscalls = false" \
  --init none \
  --no-confirm

# Install devbox
RUN curl -fsSL https://get.jetify.com/devbox | bash -s -- -f

# Copy repos
RUN mkdir -p $HOME/kie

WORKDIR $HOME/kie

COPY ./ $HOME/kie

RUN devbox shell

ENTRYPOINT [""]

CMD devbox shell
