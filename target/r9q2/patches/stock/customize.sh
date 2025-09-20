


echo "- Adding stock GameDriver"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/priv-app/GameDriver-SM8350/GameDriver-SM8350.apk" 0 0 644 "u:object_r:system_file:s0"



# echo "- Fixing artifacting and WiFi"
# ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/bin/insthk"
# ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/bin/remotedisplay"
# ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libhwui.so"

# echo "- Adding stock WFD blobs"
# ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/bin/insthk" 0 2000 755 "u:object_r:insthk_exec:s0"
# ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/bin/remotedisplay" 0 2000 755 "u:object_r:remotedisplay_exec:s0"
# ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libremotedisplay.so" 0 0 644 "u:object_r:system_lib_file:s0"
