#!/bin/bash

export ARCH=arm
export PATH=$(pwd)/../PLATFORM/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin:$PATH

mkdir output

make -C $(pwd) O= output VARIANT_DEFCONFIG=apq8084_sec_lentislte_skt_defconfig apq8084_sec_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -j64 -C $(pwd) O=output CROSS_COMPILE=arm-eabi-

cp output/arch/arm/boot/zImage $(pwd)/arch/arm/boot/zImage
