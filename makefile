# Build thẳng thành dylib, không cần Theos
TARGET = libfluck.dylib

all: $(TARGET)

$(TARGET): fluck.mm
	clang++ -dynamiclib -arch arm64 \
		-isysroot $(shell xcrun --sdk iphoneos --show-sdk-path) \
		-framework Foundation \
		-framework UIKit \
		-framework CoreGraphics \
		-framework QuartzCore \
		-framework AVFoundation \
		-framework CoreLocation \
		-framework MapKit \
		-framework WebKit \
		-framework SceneKit \
		-framework SpriteKit \
		-framework Metal \
		-framework CoreImage \
		-framework Security \
		-framework SystemConfiguration \
		-Oz \
		-o $@ \
		fluck.mm \
		-lz -lc++ -ObjC

clean:
	rm -f $(TARGET)

.PHONY: all clean
