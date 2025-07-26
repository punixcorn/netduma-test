#!/bin/bash
set -e

echo "=== Netduma wget Build Script ==="
echo "Run this script from the OpenWrt SDK base directory"

# Verify we're in the SDK directory
if [ ! -f "scripts/feeds" ] || [ ! -d "package" ]; then
    echo "ERROR: This script must be run from the OpenWrt SDK base directory"
    echo "Expected files: scripts/feeds, package/ directory"
    exit 1
fi

# Update feeds and install wget
echo "Updating feeds..."
./scripts/feeds update -a 
./scripts/feeds install -p packages wget

# Configure packages (non-interactive)
echo "Configuring wget packages..."
echo "CONFIG_PACKAGE_wget-nossl=y" >> .config
echo "CONFIG_PACKAGE_wget-ssl=y" >> .config
echo "CONFIG_WGET_NETDUMA_BANNER=y" >> .config

# Apply configuration
make defconfig V=s

# Prepare wget package
echo "Preparing wget package..."
make package/wget/prepare -j$(nproc) V=s

# Set up quilt environment
echo "Setting up patch environment..."
# this is useless for now but too late to do anychanges
export  QUILT_PATCHES=package/feeds/packages/wget/patches

sed -i '/^include $(INCLUDE_DIR)\/package\.mk$/a \
# Add Netduma banner flag if enabled\
ifdef CONFIG_WGET_NETDUMA_BANNER\
  TARGET_CFLAGS += -DNETDUMA_BANNER\
  endif' package/feeds/packages/wget/patches/Makefile
# echo "100-add-netduma-banner.patch" > package/feeds/packages/wget/patches/series

# # Adding patch
# quilt add src/main.c

echo "100-add-netduma-banner.patch" > package/feeds/packages/wget/patches/series

cat > package/feeds/packages/wget/patches/100-add-netduma-banner.patch <<EOF
--- a/src/main.c
+++ b/src/main.c
@@ -582,6 +582,11 @@ print_usage (_GL_UNUSED int error)
 _Noreturn static void
 print_help (void)
 {
+
+#ifdef NETDUMA_BANNER
+  printf("Netduma Banner Test\n");
+#endif
+
 #ifndef TESTING
   /* We split the help text this way to ease translation of individual
      entries.  */
@@ -1256,6 +1261,10 @@ print_version (void)
   char *env_wgetrc, *user_wgetrc;
   int i;

+#ifdef NETDUMA_BANNER
+  printf("Netduma Banner Test\n");
+#endif
+
   if (printf (_("GNU Wget %s built on %s.\n\n"), version_string, OS_TYPE) < 0)
     exit (WGET_EXIT_IO_FAIL);
EOF

export  QUILT_PATCHES=../../../../package/feeds/packages/wget/patches

cd build_dir/target-*/wget-nossl/wget-*/

quilt push
quilt refresh
quilt diff 

make package/wget/clean 
make package/wget/prepare  V=s

# if netduma is not configured
echo "CONFIG_WGET_NETDUMA_BANNER=y" >> .config

# Build
make package/wget/compile V=s
find bin/ -iname "*wget*.ipk"
