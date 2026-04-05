#!/bin/bash

set -e

echo "🔨 Building Flutter web application..."
flutter build web --release --base-href "/curriculo-lab-github.io/"

echo ""
echo "📦 Copying build to docs folder..."
rm -rf docs
cp -r build/web docs

echo ""
echo "📝 Staging changes..."
git add docs/

echo ""
echo "💬 Committing changes..."
git commit -m "chore: rebuild and deploy to GitHub Pages" || echo "No changes to commit"

echo ""
echo "🚀 Pushing to GitHub..."
git push

echo ""
echo "✅ Deployment complete!"
echo "🌐 Visit: https://thauanny.github.io/curriculo-lab-github.io/
