#
# Automatically generated file. DO NOT MODIFY
#

PRODUCT_SOONG_NAMESPACES += \
    vendor/pixel/launcher/common

PRODUCT_COPY_FILES += \
    vendor/pixel/launcher/common/proprietary/product/etc/default-permissions/default-permissions_pixelweather.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions_pixelweather.xml

PRODUCT_PACKAGES += \
    NexusLauncherRelease

ifeq ($(TARGET_IS_TABLET),true)

PRODUCT_PACKAGES += \
    NexusLauncherReleaseTablet

endif
