# Tiny Linux System with BusyBox
 A bash script that can help build a kernel and a initrd image/rootfs for x86_64 architecture.
Then generates another script to run it using qemu-system-x86_64. 

If you cannot build one, I have added a zip file in releases, you can unzip it in a folder, ensure that you have qemu-system-x86_64 installed in you system and then simply use run.sh to boot the kernel along with the initrd image !

# hello_world_init
This is another rootfs, which only has a Hello World program compiled statically, if you use this cpio archive to boot, you will only get that message and nothing else !
x86_64 only
