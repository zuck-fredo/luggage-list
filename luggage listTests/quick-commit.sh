#!/bin/bash

# Quick Git Commit Script
# Usage: ./quick-commit.sh "Your commit message"

if [ -z "$1" ]; then
    echo "❌ Error: Please provide a commit message"
    echo "Usage: ./quick-commit.sh \"Your commit message\""
    exit 1
fi

echo "📝 Staging all changes..."
git add .

echo "💾 Committing with message: $1"
git commit -m "$1"

echo "🚀 Pushing to GitHub..."
git push origin main

echo "✅ Done! Changes synced to GitHub"
