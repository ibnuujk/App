#!/bin/bash

echo "🔥 Deploying Firebase rules and indexes..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "Please install it using: npm install -g firebase-tools"
    exit 1
fi

# Login to Firebase (if not already logged in)
echo "🔑 Checking Firebase login..."
firebase login --no-localhost

# Deploy Firestore rules
echo "📋 Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Deploy Firestore indexes
echo "📊 Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

echo "✅ Firebase deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Wait for indexes to build (can take several minutes)"
echo "2. Check Firebase Console for index status"
echo "3. Test the app again"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/project/skripsi-ibnu"
