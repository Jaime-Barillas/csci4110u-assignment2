FROM ghcr.io/ponylang/ponyc:0.58.6

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    unzip \
    python3 \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sSLo /opt/ninja.zip https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip \
  && unzip -d /opt/ninja /opt/ninja.zip \
  && rm /opt/ninja.zip
ENV PATH="$PATH:/opt/ninja"
RUN pip3 install --break-system-packages meson==1.5.2

COPY . /app
WORKDIR /app

RUN meson setup build \
  && meson compile -C build
CMD ["/app/build/assignment2"]
