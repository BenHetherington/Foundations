# If the PRODUCT_NAME environment variable is not defined, define it now
PRODUCT_NAME ?= Foundations
BUILD_DIR = ./build/

ROM_FILENAME = $(BUILD_DIR)$(PRODUCT_NAME).gbc

MAP_FILENAME = $(BUILD_DIR)$(PRODUCT_NAME).map
SYM_FILENAME = $(BUILD_DIR)$(PRODUCT_NAME).sym

LINK_FLAGS = -m "$(MAP_FILENAME)" -n "$(SYM_FILENAME)"

SOURCE_FILES = $(wildcard *.asm) $(wildcard */*.asm) $(wildcard */*/*.asm)
OBJECT_FILES = $(patsubst %.asm, $(BUILD_DIR)%.o, $(SOURCE_FILES))
INCLUDE_FILES = $(wildcard *.inc) $(wildcard */*/.inc) $(wildcard */*/*/.inc)

# Linking - produces the final .gbc file (and corrects its checksums)
$(ROM_FILENAME) : $(OBJECT_FILES)
	rgbasm -o $(BUILD_DIR)AssemblyString.o AssemblyString.asm
	rgblink -o "$@" $(LINK_FLAGS) $^
	rgbfix -v $@

# Assembling - using object files
$(BUILD_DIR)%.o : %.asm $(INCLUDE_FILES)
ifeq ($(wildcard $(BUILD_DIR)$(dir $<).),)
	mkdir -p "$(BUILD_DIR)$(dir $<)"
endif
	rgbasm -o $@ $<

Engine.asm : Interface.s

# Binary files to be included
Ben10doScreen.asm : Ben10doScreenData.pu
Sound/Engine.asm : Sound/FrequencyTable

# Clean out all the build products
.PHONY : clean
clean :
	rm -f $(ROM_FILENAME) $(MAP_FILENAME) $(SYM_FILENAME) $(OBJECT_FILES)
