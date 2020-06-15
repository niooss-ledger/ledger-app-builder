FROM python:3.8-slim
ENV LANG C.UTF-8

RUN apt-get update && apt-get upgrade -qy && \
  apt-get install -qy \
    gcc-arm-linux-gnueabihf \
    linux-libc-dev \
    linux-libc-dev-armhf-cross \
    libc6-dev-armhf-cross \
    cmake \
    git \
    libudev-dev \
    libusb-1.0-0-dev \
    python3-pip \
    wget && \
  apt-get clean

RUN pip3 install ledgerblue pytest

# CMocka
RUN \
  echo f0ccd8242d55e2fd74b16ba518359151f6f8383ff8aef4976e48393f77bba8b6 cmocka-1.1.5.tar.xz >> SHA256SUMS && \
  wget https://cmocka.org/files/1.1/cmocka-1.1.5.tar.xz && \
  sha256sum --check SHA256SUMS && \
  mkdir cmocka && \
  tar xf cmocka-1.1.5.tar.xz && \
  cd cmocka && \
  cmake ../cmocka-1.1.5 -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_C_FLAGS=-mthumb -DWITH_STATIC_LIB=true -DCMAKE_INSTALL_PREFIX=/install && \
  make install && \
  cd .. && \
  rm -rf cmoka/ cmocka-1.1.5/ cmocka-1.1.5.tar.xz SHA256SUMS

RUN apt-get install -qy gcc-multilib g++-multilib && apt-get clean

# GCC
RUN \
  wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/5_3-2016q1/gccarmnoneeabi532016q120160330linuxtar.bz2 -O gcc.tar.bz2 && \
  tar xf gcc.tar.bz2 && \
  mkdir /compilers && \
  mv gcc-arm-none-eabi-5_3-2016q1 /compilers && \
  rm -rf gcc.tar.bz2

ENV BOLOS_ENV=/compilers

ENV PATH="/compilers/gcc-arm-none-eabi-5_3-2016q1/bin:${PATH}"

RUN git clone --branch nanos-160 https://github.com/LedgerHQ/nanos-secure-sdk.git sdk
ENV BOLOS_SDK=/sdk

CMD ["/bin/bash"]
