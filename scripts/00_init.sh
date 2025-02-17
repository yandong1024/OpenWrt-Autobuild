#!/usr/bin/env bash

set -ex


__get_other-repos() {
    git clone -b master --depth 1 --single-branch https://github.com/coolsnowwolf/lede lede
    git clone -b master --depth 1 --single-branch https://github.com/immortalwrt/immortalwrt immortalwrt
    git clone -b master --depth 1 --single-branch https://github.com/immortalwrt/packages immortalwrt-packages
    git clone -b master --depth 1 --single-branch https://github.com/immortalwrt/luci immortalwrt-luci
    echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> ./openwrt/feeds.conf.default
}

__patch_fullconenat() {
    # patch kernel
    cp -f ./lede/target/linux/generic/hack-6.6/952-add-net-conntrack-events-support-multiple-registrant.patch ./openwrt/target/linux/generic/hack-6.6/
    # disable KERNEL_WERROR
    sed -i 's,imply KERNEL_WERROR,#imply KERNEL_WERROR,g' ./openwrt/toolchain/gcc/Config.version
    # fullconenat-nft
    cp -rf ./immortalwrt/package/network/utils/fullconenat-nft ./openwrt/package/network/utils/
    # libnftnl
    rm -rf ./openwrt/package/libs/libnftnl
    cp -rf ./immortalwrt/package/libs/libnftnl ./openwrt/package/libs/
    # nftables
    rm -rf ./openwrt/package/network/utils/nftables/
    cp -rf ./immortalwrt/package/network/utils/nftables ./openwrt/package/network/utils/
    # firewall4
    rm -rf ./openwrt/package/network/config/firewall4
    cp -rf ./immortalwrt/package/network/config/firewall4 ./openwrt/package/network/config/
    # patch luci
    patch -d ./openwrt/feeds/luci -p1 -i ../../../patches/fullconenat-luci.patch
}

__burn_onecloud() {
    ver="v0.3.1"
    curl -L -o ./AmlImg https://github.com/hzyitc/AmlImg/releases/download/$ver/AmlImg_${ver}_linux_amd64
    chmod +x ./AmlImg

    curl -L -o ./uboot.img https://github.com/hzyitc/u-boot-onecloud/releases/download/build-20221028-0940/eMMC.burn.img
    ./AmlImg unpack ./uboot.img burn/
    echo "::endgroup::"
    gunzip -k openwrt/bin/targets/*/*/*.gz
    diskimg=$(ls openwrt/bin/targets/*/*/*.img)
    loop=$(sudo losetup --find --show --partscan $diskimg)
    img_ext="openwrt.img"
    img_mnt="xd"
    rootfs_mnt="img"
    boot_img=$1${img_ext}
    boot_img_mnt=$1${img_mnt}
    rootfs_img_mnt=$1${rootfs_mnt}
    echo ${boot_img}
    echo ${boot_img_mnt}
    echo ${rootfs_img_mnt}
    sudo rm -rf ${boot_img}
    sudo rm -rf ${boot_img_mnt}
    sudo rm -rf ${rootfs_img_mnt}
    sudo dd if=/dev/zero of=${boot_img} bs=1M count=400
    sudo mkfs.ext4 ${boot_img}
    sudo mkdir ${boot_img_mnt}
    sudo mkdir ${rootfs_img_mnt}
    sudo mount ${boot_img} ${boot_img_mnt}
    sudo mount ${loop}p2 ${rootfs_img_mnt}

    pushd ${rootfs_img_mnt}
    sudo cp -r * ../${boot_img_mnt}
    sudo sync
    popd

    sudo umount ${boot_img_mnt}
    sudo umount ${rootfs_img_mnt}

    sudo img2simg ${loop}p1 burn/boot.simg
    sudo img2simg openwrt.img burn/rootfs.simg

    sudo rm -rf *.img
    sudo losetup -d $loop
    cat <<EOF >>burn/commands.txt
PARTITION:boot:sparse:boot.simg
PARTITION:rootfs:sparse:rootfs.simg
EOF
    prefix=$(ls openwrt/bin/targets/*/*/*.img | sed 's/sdcard.img$/emmc/')
    burnimg=${prefix}.img
    ./AmlImg pack $burnimg burn/

    for f in openwrt/bin/targets/*/*/*-emmc.img; do
        gzip "$f"
    done
    sudo rm -rf openwrt/bin/targets/*/*/*.img
}


case $1 in
    other-repos)        __get_other-repos   ;;
    patch-fullconenat)  __patch_fullconenat ;;
    burn-onecloud)      __burn_onecloud     ;;
    *)                  echo "input error"  ;;
esac

exit 0
