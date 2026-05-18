#!/usr/bin/env bash
# reinstall-all.sh
# Completely uninstalls and rebuilds both macOS and Android apps with the latest code changes.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}▶ Starting total clean and rebuild for ClipRelay...${NC}\n"

# ==========================================
# 1. macOS Reinstall
# ==========================================
echo -e "${BLUE}▶ [macOS] Stopping existing processes...${NC}"
pkill -x ClipRelay || true
pkill -x cliprelay-daemon || true

echo -e "${BLUE}▶ [macOS] Building latest version...${NC}"
bash scripts/build-macos.sh

echo -e "${BLUE}▶ [macOS] Uninstalling old version...${NC}"
rm -rf /Applications/ClipRelay.app

echo -e "${BLUE}▶ [macOS] Installing new version to /Applications...${NC}"
cp -a platforms/macos/build/ClipRelay.app /Applications/

echo -e "${GREEN}▶ [macOS] ✅ Installed! Launching...${NC}"
open -a /Applications/ClipRelay.app

echo -e "\n----------------------------------------\n"

# ==========================================
# 2. Android Reinstall
# ==========================================
echo -e "${BLUE}▶ [Android] Building latest APK...${NC}"
bash scripts/build-android.sh --debug

echo -e "${BLUE}▶ [Android] Uninstalling old version from connected device...${NC}"
adb uninstall com.cliprelay.debug || echo -e "${RED}Warning: com.cliprelay.debug not found on device or no device connected.${NC}"

echo -e "${BLUE}▶ [Android] Installing new version...${NC}"
if adb install -r platforms/android/app/build/outputs/apk/debug/app-debug.apk; then
    echo -e "${GREEN}▶ [Android] ✅ Installed! Launching...${NC}"
    adb shell am start -n com.cliprelay.debug/com.cliprelay.MainActivity
else
    echo -e "${RED}▶ [Android] ❌ Failed to install APK. Is a device connected?${NC}"
fi

echo -e "\n${GREEN}🎉 All done! Both platforms have been reinstalled with the latest code.${NC}"
