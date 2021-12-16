#!/bin/bash

# configure your choices here
KERNEL_VERSION=5.10.85
BUSYBOX_VERSION=1.33.2

PARENT_FOLDER_NAME=busybox-linux

mkdir ${PARENT_FOLDER_NAME}
cd ${PARENT_FOLDER_NAME}

	mkdir src
	cd src

	# getting the kernel sources and building it
	wget "https://cdn.kernel.org/pub/linux/kernel/v$(echo $KERNEL_VERSION | cut -d'.' -f1).x/linux-${KERNEL_VERSION}.tar.xz"
	tar -xvJf "linux-${KERNEL_VERSION}.tar.xz"
	cd "linux-${KERNEL_VERSION}"
		make defconfig
		make -j$(nproc)
	cd ..

	# getting the busybox sources and building it
	wget "https://www.busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
	tar -xvjf "busybox-${BUSYBOX_VERSION}.tar.bz2"
	cd "busybox-${BUSYBOX_VERSION}"
		make defconfig
		sed 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' -i .config
		make -j$(nproc)
		make CONFIG_PREFIX="$(pwd)/x86-busybox" install
			cd "$(pwd)/x86-busybox"
			# making necessary virtual file system mounting folders
			mkdir dev proc sys
			# creating the init scripts such that the kernel will execute after booting
			echo '#!/bin/sh' > init
			echo 'mount -t sysfs sysfs /sys' >> init
			echo 'mount -t proc proc /proc' >> init
			echo 'mount -t devtmpfs udev /dev' >> init
			echo '/bin/sh' >> init
			# without the calling of /bin/sh, the kernel will panic
			echo 'poweroff -f' >> init
			# with this exiting the machine should halt the system
			chmod 777 init
			find * | cpio -o -H newc | gzip > ../rootfs.cpio.gz
			cd ..
	cd ..
	cd ..

mkdir system
cd system

	cp "../src/linux-${KERNEL_VERSION}/arch/x86/boot/bzImage" .
	cp "../src/busybox-${BUSYBOX_VERSION}/rootfs.cpio.gz" .
	echo "qemu-system-x86_64 -nographic -no-reboot -kernel bzImage -initrd rootfs.cpio.gz -append \"panic 1 console=ttyS0\"" > run.sh
	chmod 777 run.sh
cd ..

echo "BUILD FINISHED !"
echo "GO TO ${PARENT_FOLDER_NAME}THEN system AND RUN run.sh IN TERMINAL"
