#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(WITH_GMS),true)

# Inherit from the proprietary version
$(call inherit-product, vendor/pixel/themepicker/common/common-vendor.mk)

# Overlay
PRODUCT_PACKAGES += \
	FrameworkOverlayThemePicker \
	PixelLauncherOverlayThemePicker \
    SettingsOverlayThemePicker \
    SystemUIOverlayThemePicker

# Tensorflow
PRODUCT_PACKAGES += \
    libtensorflowlite_jni \

# Config
PRODUCT_COPY_FILES += \
    vendor/pixel/themepicker/prebuilt/etc/hiddenapi-package-whitelist-themepicker.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google-hiddenapi-package-whitelist.xml \
    vendor/pixel/themepicker/prebuilt/etc/preinstalled-packages-product-themepicker.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/google-preinstalled-packages-product-themepicker.xml \
    vendor/pixel/themepicker/prebuilt/etc/sysconfig-themepicker.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/sysconfig-themepicker.xml \
    vendor/pixel/themepicker/prebuilt/etc/privapp-permissions-themepicker-se.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/google-privapp-permissions-themepicker-se.xml

endif
