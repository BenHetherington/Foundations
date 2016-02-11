set -e
rgbasm -o "$SRCROOT/$PRODUCT_NAME.o" BoxTest.asm
rgblink -o "$SRCROOT/$PRODUCT_NAME.gb" -m "$SRCROOT/$PRODUCT_NAME.map" -n "$SRCROOT/$PRODUCT_NAME.sym" "$SRCROOT/$PRODUCT_NAME.o"
rgbfix -v "$SRCROOT/$PRODUCT_NAME.gb"