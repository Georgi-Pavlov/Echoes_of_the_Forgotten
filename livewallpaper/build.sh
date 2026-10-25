#!/usr/bin/env bash
# Builds the live wallpaper APK with the SDK tools Godot already uses (no Gradle needed).
set -euo pipefail
cd "$(dirname "$0")"

SDK="${ANDROID_SDK:-C:/Users/Georgi/AppData/Local/Android/Sdk}"
BT="$SDK/build-tools/36.0.0"
JAR="$SDK/platforms/android-37.0/android.jar"
KEYSTORE="${KEYSTORE:-C:/Users/Georgi/AppData/Roaming/Godot/keystores/debug.keystore}"
OUT=echoes_live_wallpaper.apk

rm -rf build && mkdir -p build/classes build/dex

"$BT/aapt2.exe" compile --dir res -o build/res.zip
"$BT/aapt2.exe" link -o build/base.apk -I "$JAR" --manifest AndroidManifest.xml -A assets \
    --min-sdk-version 26 --target-sdk-version 34 --version-code 2 --version-name 2.0 build/res.zip

javac --release 8 -Xlint:-options -classpath "$JAR" -d build/classes $(find src -name '*.java')
"$BT/d8.bat" --lib "$JAR" --min-api 26 --output build/dex $(find build/classes -name '*.class')

(cd build/dex && jar uf ../base.apk classes.dex)
"$BT/zipalign.exe" -f -p 4 build/base.apk build/aligned.apk
"$BT/apksigner.bat" sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android \
    --ks-key-alias androiddebugkey --out "$OUT" build/aligned.apk
"$BT/apksigner.bat" verify --verbose "$OUT" | head -3
ls -la "$OUT"
