#!/bin/bash
set -e

# Client
cd ton_crypto_farm_client
echo "Cleaning Flutter client..."
flutter clean
echo "Getting Flutter client packages..."
flutter pub get
echo "Building Flutter client (debug)..."
flutter build apk || flutter build web || echo "Build for other platforms as needed."
echo "Running Flutter client (in background)..."
flutter run &
CLIENT_PID=$!
cd ..

# Server
cd ton_crypto_farm_server
echo "Getting Dart server packages..."
dart pub get
echo "Running Dart server (in background)..."
dart run bin/server.dart &
SERVER_PID=$!
cd ..

# Wait for user to finish
trap "kill $CLIENT_PID $SERVER_PID" EXIT

echo "Both client and server are running. Press Ctrl+C to stop."
wait 