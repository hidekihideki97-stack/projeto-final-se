#!/bin/sh
set -e
BR=$BASE_DIR/..
CS=$BR/custom-scripts
CC=$HOST_DIR/bin/aarch64-linux-gcc

# 1) Header GPIO v2: o toolchain traz headers 5.4 (sem a ABI v2).
#    Exporta só o linux/gpio.h do kernel selecionado.
if ! grep -q GPIO_V2_GET_LINE_IOCTL $($CC -print-sysroot)/usr/include/linux/gpio.h 2>/dev/null; then
    KDIR=$(ls -d $BUILD_DIR/linux-* | grep -v headers | head -n1)
    make -C $KDIR ARCH=arm64 INSTALL_HDR_PATH=$BUILD_DIR/kuapi headers_install
    mkdir -p $BUILD_DIR/gpio-inc/linux
    cp $BUILD_DIR/kuapi/include/linux/gpio.h $BUILD_DIR/gpio-inc/linux/
    EXTRA_INC="-I$BUILD_DIR/gpio-inc"
fi

# 2) Compila o benchmark para a placa
$CC -O2 -std=c11 -Wall -Wextra $EXTRA_INC \
    -o $TARGET_DIR/usr/bin/benchmark $CS/rpi_benchmark/benchmark.c -lm

# 3) Anúncio de IP (scripts da prática Buildroot parte 2)
install -m 0755 $CS/S60announce  $TARGET_DIR/etc/init.d/S60announce
install -m 0755 $CS/announced.sh $TARGET_DIR/usr/bin/announced.sh
