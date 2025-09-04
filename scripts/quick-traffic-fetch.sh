#!/bin/bash

# Quick GitHub Traffic Fetcher for QRAMM
# Usage: ./quick-traffic-fetch.sh YOUR_GITHUB_TOKEN

TOKEN=${1:-$GITHUB_TOKEN}
OWNER="csnp"
REPO="qramm"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

if [ -z "$TOKEN" ]; then
    echo "❌ Error: GitHub token required"
    echo "Usage: ./quick-traffic-fetch.sh YOUR_GITHUB_TOKEN"
    echo "Or set GITHUB_TOKEN environment variable"
    exit 1
fi

echo "📊 Fetching traffic data for $OWNER/$REPO..."

# Create directory for data
mkdir -p traffic-snapshots

# Fetch all traffic data
echo "→ Views..."
curl -s -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/traffic/views" \
     > "traffic-snapshots/views_$DATE.json"

echo "→ Clones..."
curl -s -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/traffic/clones" \
     > "traffic-snapshots/clones_$DATE.json"

echo "→ Popular paths..."
curl -s -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/traffic/popular/paths" \
     > "traffic-snapshots/paths_$DATE.json"

echo "→ Referrers..."
curl -s -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/repos/$OWNER/$REPO/traffic/popular/referrers" \
     > "traffic-snapshots/referrers_$DATE.json"

echo "✅ Data saved to traffic-snapshots/*_$DATE.json"
echo ""
echo "Quick Stats:"
echo "------------"
jq '.count' "traffic-snapshots/views_$DATE.json" | xargs echo "Total views:"
jq '.uniques' "traffic-snapshots/views_$DATE.json" | xargs echo "Unique visitors:"
jq '.count' "traffic-snapshots/clones_$DATE.json" | xargs echo "Total clones:"
jq '.uniques' "traffic-snapshots/clones_$DATE.json" | xargs echo "Unique cloners:"