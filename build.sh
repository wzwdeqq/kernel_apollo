workdir="$HOME/apollo"
srcdir="$workdir/kernel_apollo"
objdir="$srcdir/out/arch/arm64/boot"

export PATH="/usr/lib/ccache/bin:$workdir/proton-clang/bin:$PATH"

export KBUILD_BUILD_USER="spac3b0y"
export KBUILD_BUILD_HOST="TheHurtlocker"

export ARCH="arm64"

export CROSS_COMPILE="aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"

build() {
 make CC=clang O=out vendor/apollo_user_defconfig
 make CC="ccache clang" AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip LD=ld.lld O=out -j$(nproc --all) 2>&1 | tee build.log
}

name_zip() {
 kvstring="$(strings $objdir/Image | grep -m1 "Linux version")"

 kernelversion="$(cut -d' ' -f 3 <<< $kvstring)"
 glitchedversion="$(cut -d'-' -f 3 <<< $kernelversion)"

 buildcount=r"$(cat $srcdir/out/.version)"

 kernelname="$(cut -d'-' -f 2 <<< $kernelversion)"
 kernelname="${kernelname,,}"

 zipname="$kernelname-$glitchedversion-$buildcount"
}

package() {
 cd $workdir/AnyKernel3

 rm dtbo.img
 rm dtb
 rm *.zip

 python2 $workdir/mkdtboimg.py create dtbo.img $objdir/dts/vendor/qcom/*.dtbo

 cp $objdir/Image zImage
 cat $objdir/dts/vendor/qcom/*.dtb > dtb

 zip -r $zipname.zip *
}

build
name_zip
package
