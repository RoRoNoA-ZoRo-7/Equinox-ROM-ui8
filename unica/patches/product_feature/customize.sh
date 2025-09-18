#!/bin/bash

APPLY_PATCH()
{
    local PATCH
    local OUT

    DECODE_APK "$1"

    cd "$APKTOOL_DIR/$1"

    PATCH="$SRC_DIR/unica/patches/product_feature/$2"

    OUT="$(patch -p1 -s -t -N --dry-run < "$PATCH")" \
    || echo "$OUT" | grep -q "Skipping patch" || false
    patch -p1 -s -t -N --no-backup-if-mismatch < "$PATCH" &> /dev/null || true

    cd - &> /dev/null
}

GET_FP_SENSOR_TYPE()
{
    if [[ "$1" == *"ultrasonic"* ]]; then
        echo "ultrasonic"
    elif [[ "$1" == *"optical"* ]]; then
        echo "optical"
    elif [[ "$1" == *"side"* ]]; then
        echo "side"
    else
        echo "Unsupported type: $1"
        exit 1
    fi
}

MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)

# Apply fingerprint sensor patches if source and target fingerprint sensor types differ
if [[ "$(GET_FP_SENSOR_TYPE "$SOURCE_FP_SENSOR_CONFIG")" != "$(GET_FP_SENSOR_TYPE "$TARGET_FP_SENSOR_CONFIG")" ]]; then
    echo "Applying fingerprint sensor patches"

    DECODE_APK "system/framework/framework.jar"
    DECODE_APK "system/framework/services.jar"
    DECODE_APK "system/priv-app/SecSettings/SecSettings.apk"
    DECODE_APK "system/priv-app/BiometricSetting/BiometricSetting.apk"

    FTP="
    system/framework/framework.jar/smali_classes2/android/hardware/fingerprint/FingerprintManager.smali
    system/framework/framework.jar/smali_classes2/android/hardware/fingerprint/HidlFingerprintSensorConfig.smali
    system/framework/framework.jar/smali_classes5/com/samsung/android/bio/fingerprint/SemFingerprintManager.smali
    system/framework/framework.jar/smali_classes5/com/samsung/android/bio/fingerprint/SemFingerprintManager\$Characteristics.smali
    system/framework/framework.jar/smali_classes6/com/samsung/android/rune/InputRune.smali
    system/framework/services.jar/smali/com/android/server/biometrics/sensors/fingerprint/FingerprintUtils.smali
    system/priv-app/SecSettings/SecSettings.apk/smali_classes4/com/samsung/android/settings/biometrics/fingerprint/FingerprintSettingsUtils.smali
    "

    for f in $FTP; do
        sed -i "s/$SOURCE_FP_SENSOR_CONFIG/$TARGET_FP_SENSOR_CONFIG/g" "$APKTOOL_DIR/$f"
    done

    if [[ "$(GET_FP_SENSOR_TYPE "$TARGET_FP_SENSOR_CONFIG")" == "optical" ]]; then
        ADD_TO_WORK_DIR "r12sxxx" "system" "system/bin/surfaceflinger"
        ADD_TO_WORK_DIR "r12sxxx" "system" "system/lib64/libgui.so"
        ADD_TO_WORK_DIR "r12sxxx" "system" "system/lib64/libui.so"

        APPLY_PATCH "system/framework/services.jar" "fingerprint/services.jar/0001-Set-FP_FEATURE_SENSOR_IS_ULTRASONIC-to-false.patch"
        APPLY_PATCH "system/priv-app/BiometricSetting/BiometricSetting.apk" "fingerprint/BiometricSetting.apk/0001-Set-FP_FEATURE_SENSOR_IS_ULTRASONIC-to-false.patch"
        APPLY_PATCH "system/priv-app/BiometricSetting/BiometricSetting.apk" "fingerprint/BiometricSetting.apk/0002-Always-use-ultrasonic-FOD-animation.patch"

    elif [[ "$(GET_FP_SENSOR_TYPE "$TARGET_FP_SENSOR_CONFIG")" == "side" ]]; then
        ADD_TO_WORK_DIR "b6qxxx" "system" "."

        DELETE_FROM_WORK_DIR "system" "system/priv-app/BiometricSetting/oat"

        APPLY_PATCH "system/framework/services.jar" "fingerprint/services.jar/0001-Set-FP_FEATURE_SENSOR_IS_ULTRASONIC-to-false.patch"
        APPLY_PATCH "system/framework/services.jar" "fingerprint/services.jar/0002-Set-FP_FEATURE_SENSOR_IS_IN_DISPLAY_TYPE-to-false.patch"
    fi
fi
