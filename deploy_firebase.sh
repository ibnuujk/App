#!/bin/bash

echo "🚀 Deploying Firebase configuration for PersalinanKu App..."

# Deploy Firestore indexes (simplified)
echo "📊 Deploying simplified Firestore indexes..."
firebase deploy --only firestore:indexes

# Deploy Firestore security rules
echo "🔒 Deploying Firestore security rules..."
firebase deploy --only firestore:rules

echo ""
echo "⚠️  IMPORTANT: Using SimpleNotificationService to avoid index errors"
echo "📱 Notification badge should now work without complex Firebase indexes"
echo "🔄 Real-time chat integration enabled"
echo "📊 Additional indexes for chats, users, and konsultasi added"
echo "📱 Enhanced notification system with real-time data integration"
echo "🔗 Real-time chat and konsultasi integration enabled"

echo "✅ Firebase deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Wait for indexes to build (may take a few minutes)"
echo "2. Test the notification system"
echo "3. Check Firebase Console for any errors"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com"
