ARCHS = arm64 arm64e
TARGET = iphone:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = fluck
fluck_FILES = Tweak.xm
fluck_CFLAGS = -fobjc-arc -O2 -Wno-deprecated-declarations -Wno-error
fluck_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
