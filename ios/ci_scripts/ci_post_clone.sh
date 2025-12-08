#!/bin/sh
set -e

# The default execution directory of this script is the ci_scripts directory.
# Traverse up to the root of the repository.
cd $CI_PRIMARY_REPOSITORY_PATH

echo "Installing Flutter..."
# Install Flutter using git clone to ensure we have the stable version
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "Flutter version:"
flutter --version

echo "Installing dependencies..."
flutter pub get

echo "Installing Pods..."
# Navigate to ios directory to run pod install
cd ios
# Install CocoaPods if not available (Xcode Cloud usually has it, but good to be safe or just run it)
# Running pod install
pod install

exit 0
