ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = fluck
fluck_FILES = Tweak.xm
fluck_CFLAGS = -fobjc-arc -O2
fluck_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
