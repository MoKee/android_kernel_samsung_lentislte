#!/bin/bash

export ARCH=arm
export CROSS_COMPILE=/home/callmesuper/Mokee/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-
mkdir output

make -C $(pwd) O=output emotion_cm_defconfig VARIANT_DEFCONFIG=apq8084_sec_lentislte_skt_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -C $(pwd) O=output

cp output/arch/arm/boot/Image $(pwd)/arch/arm/boot/zImage
