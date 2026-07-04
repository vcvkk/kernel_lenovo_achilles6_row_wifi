### AnyKernel3 Ramdisk Mod Script
## Custom kernel for Lenovo Tab M10 Plus (TB-X606F / achilles6_row_wifi, MT6765)

### AnyKernel setup
# global properties
properties() { '
kernel.string=achilles6_row_wifi custom kernel (4.9.337, KernelSU Next, SUSFS, DT2W)
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=achilles6_row_wifi
device.name2=TB-X606F
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# do.devicecheck is intentionally 0 (skipped): the exact ro.product.device
# string this tablet reports has not been confirmed against real hardware
# this session. Only flash this zip on a Lenovo Tab M10 Plus TB-X606F
# (achilles6_row_wifi) -- there is no automatic guard against flashing it
# on the wrong device.

### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=/dev/block/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
#
# No ramdisk modifications are needed: KernelSU Next is built directly into
# this kernel image (manual/non-kprobe hooks, not a ramdisk-injected overlay
# like Magisk), so this just unpacks boot.img, lets AnyKernel3 swap in the
# Image.gz-dtb placed at the root of this zip, and repacks with the
# original ramdisk and header untouched.
dump_boot;
write_boot;
## end boot install
