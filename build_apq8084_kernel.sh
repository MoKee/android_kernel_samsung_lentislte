#!/bin/bash
# APQ8084 JBP kernel build script v0.4

BUILD_COMMAND=$1

MODEL=${BUILD_COMMAND%%_*}
TEMP=${BUILD_COMMAND#*_}
REGION=${TEMP%%_*}
CARRIER=${TEMP##*_}
PRODUCT_NAME=${MODEL}${CARRIER}

BUILD_WHERE=$(pwd)
BUILD_KERNEL_DIR=$BUILD_WHERE
MKBOOT_CMD=$BUILD_KERNEL_DIR/mkboot
BUILD_ROOT_DIR=$BUILD_KERNEL_DIR/../kernel_out
BUILD_KERNEL_OUT_DIR=$BUILD_ROOT_DIR/android/out/target/product/$PRODUCT_NAME/obj/KERNEL_OBJ
PRODUCT_OUT=$BUILD_ROOT_DIR/android/out/target/product/$PRODUCT_NAME

BUILD_CROSS_COMPILE=$BUILD_KERNEL_DIR/../tc/bin/arm-eabi-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

# Default Python version is 2.7
mkdir -p bin
ln -sf /usr/bin/python2.7 ./bin/python
export PATH=$(pwd)/bin:$PATH
KERNEL_DEFCONFIG=apq8084_sec_defconfig
DEBUG_DEFCONFIG=
SELINUX_DEFCONFIG=selinux_defconfig
SELINUX_LOG_DEFCONFIG=
DMVERITY_DEFCONFIG=

#sed -i.bak "s/CONFIG_MODVERSIONS=y/CONFIG_MODVERSIONS=n/g" ${BUILD_KERNEL_DIR}/arch/arm/configs/${KERNEL_DEFCONFIG}

while getopts "w:t:" flag; do
	case $flag in
		w)
			BUILD_OPTION_HW_REVISION=$OPTARG
			echo "-w : "$BUILD_OPTION_HW_REVISION""
			;;
		t)
			TARGET_BUILD_VARIANT=$OPTARG
			echo "-t : "$TARGET_BUILD_VARIANT""
			;;
		*)
			echo "wrong 2nd param : "$OPTARG""
			exit -1
			;;
	esac
done

shift $((OPTIND-1))

VARIANT=${CARRIER}
DTS_NAMES=apq8084-sec-
PROJECT_NAME=${VARIANT}
VARIANT_DEFCONFIG=apq8084_sec_${MODEL}_${CARRIER}_defconfig
case $1 in
		clean)
		echo "Not support... remove kernel out directory by yourself"
		exit 1
		;;
		
		*)
		
		BOARD_KERNEL_BASE=0x00000000
		BOARD_KERNEL_PAGESIZE=4096
		BOARD_KERNEL_TAGS_OFFSET=0x01E00000
		BOARD_RAMDISK_OFFSET=0x02000000
		BOARD_KERNEL_CMDLINE="console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3"
		mkdir -p $BUILD_KERNEL_OUT_DIR
		;;

esac

KERNEL_ZIMG=$BUILD_KERNEL_OUT_DIR/arch/arm/boot/zImage
DTC=$BUILD_KERNEL_OUT_DIR/scripts/dtc/dtc

FUNC_CLEAN_DTB()
{
	if ! [ -d $BUILD_KERNEL_OUT_DIR/arch/arm/boot/dts ] ; then
		echo "no directory : "$BUILD_KERNEL_OUT_DIR/arch/arm/boot/dts""
	else
		echo "rm files in : "$BUILD_KERNEL_OUT_DIR/arch/arm/boot/dts/*.dtb""
		rm $BUILD_KERNEL_OUT_DIR/arch/arm/boot/dts/*.dtb
	fi
}

INSTALLED_DTIMAGE_TARGET=${PRODUCT_OUT}/dt.img
DTBTOOL=$BUILD_KERNEL_DIR/tools/dtbTool

FUNC_BUILD_DTIMAGE_TARGET()
{
	echo ""
	echo "================================="
	echo "START : FUNC_BUILD_DTIMAGE_TARGET"
	echo "================================="
	echo ""
	echo "DT image target : $INSTALLED_DTIMAGE_TARGET"
	
	if ! [ -e $DTBTOOL ] ; then
		if ! [ -d $BUILD_ROOT_DIR/android/out/host/linux-x86/bin ] ; then
			mkdir -p $BUILD_ROOT_DIR/android/out/host/linux-x86/bin
		fi
		cp $BUILD_ROOT_DIR/kernel/tools/dtbTool $DTBTOOL
	fi

	echo "$DTBTOOL -o $INSTALLED_DTIMAGE_TARGET -s $BOARD_KERNEL_PAGESIZE \
						-p $BUILD_KERNEL_OUT_DIR/scripts/dtc/ $BUILD_KERNEL_OUT_DIR/arch/arm/boot/dts/"
	$DTBTOOL -o $INSTALLED_DTIMAGE_TARGET -s $BOARD_KERNEL_PAGESIZE \
						-p $BUILD_KERNEL_OUT_DIR/scripts/dtc/ $BUILD_KERNEL_OUT_DIR/arch/arm/boot/dts/

	chmod a+r $INSTALLED_DTIMAGE_TARGET

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_DTIMAGE_TARGET"
	echo "================================="
	echo ""
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build project="$PROJECT_NAME""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build variant config="$VARIANT_DEFCONFIG ""

        if [ "$BUILD_COMMAND" == "" ]; then
                SECFUNC_PRINT_HELP;
                exit -1;
        fi

	FUNC_CLEAN_DTB

	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=arm \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG VARIANT_DEFCONFIG=$VARIANT_DEFCONFIG \
			DEBUG_DEFCONFIG=$DEBUG_DEFCONFIG SELINUX_DEFCONFIG=$SELINUX_DEFCONFIG \
			SELINUX_LOG_DEFCONFIG=$SELINUX_LOG_DEFCONFIG || exit -1

	make -C $BUILD_KERNEL_DIR O=$BUILD_KERNEL_OUT_DIR -j$BUILD_JOB_NUMBER ARCH=arm \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	FUNC_BUILD_DTIMAGE_TARGET
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_BOOT()
{
	cp $BUILD_KERNEL_OUT_DIR/arch/arm/boot/zImage $MKBOOT_CMD/stock/zImage
	cd $MKBOOT_CMD
	./mkboot stock boot.img
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_BOOT"
	echo "================================="
	echo ""
	
}



SECFUNC_PRINT_HELP()
{
    echo -e '\E[33m'
    echo "Help"
    echo "$0 \$1"
    echo "  \$1 : "
        echo "  lentislte_skt"
        echo "  lentislte_att"
        echo "  trlte_skt"
        echo "  trlte_att"
        echo "  trlte_tmo"
        echo "  trlte_vzw"
        echo "  trlte_spr"
        echo "  trlte_can"
        echo "  trlte_dcm"
        echo "  trlte_kdi"
        echo "  tblte_chn"
        echo "  tblte_dcm"
        echo "  tblte_kdi"
        echo -e '\E[0m'
}


# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

	FUNC_BUILD_KERNEL
	FUNC_BUILD_BOOT
	

    END_TIME=`date +%s`
	
    let "ELAPSED_TIME=$END_TIME-$START_TIME"
    echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log
