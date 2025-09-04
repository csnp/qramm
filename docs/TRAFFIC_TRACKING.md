# GitHub Traffic Tracking Guide for QRAMM

## Problem
GitHub traffic insights reset every 14 days for detailed data, making long-term tracking impossible through the UI.

## Solutions

### 1. Automated Collection (Recommended)

We've set up automated traffic collection that runs daily:

```bash
# Manual run
cd /Users/decimai/workspace/qramm
export GITHUB_TOKEN='your_github_personal_access_token'
python scripts/github-traffic-collector.py
```

The GitHub Action will automatically collect data daily at 2 AM UTC.

### 2. Quick Manual Collection

```bash
# One-time fetch
cd /Users/decimai/workspace/qramm
chmod +x scripts/quick-traffic-fetch.sh
./scripts/quick-traffic-fetch.sh YOUR_GITHUB_TOKEN
```

### 3. Getting a GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a name like "QRAMM Traffic Collector"
4. Select scope: `repo` (full control needed for private repos, or `public_repo` for public only)
5. Generate and copy the token

### 4. Alternative Services

#### Free Options:
- **GitHub Insights Action**: https://github.com/marketplace/actions/github-insights
- **Repo Analytics**: https://repo-analytics.github.io/
- **GitHub Stats**: https://githubstats.com/

#### Paid Options:
- **Graphite**: https://graphite.dev (has free tier)
- **LinearB**: https://linearb.io (developer analytics)
- **Waydev**: https://waydev.co (git analytics)

### 5. Data Storage Structure

```
traffic-data/
├── 2025-09-04.json          # Daily snapshots
├── 2025-09-05.json
├── cumulative_traffic.json  # All historical data
└── TRAFFIC_REPORT.md        # Generated report
```

### 6. Viewing Reports

After collection, view your traffic report:
```bash
cat traffic-data/TRAFFIC_REPORT.md
```

Or view cumulative JSON data:
```bash
jq '.' traffic-data/cumulative_traffic.json
```

### 7. Setting Up Cron (Local)

To run daily on your machine:
```bash
# Edit crontab
crontab -e

# Add this line (runs at 2 AM daily)
0 2 * * * cd /Users/decimai/workspace/qramm && GITHUB_TOKEN='your_token' python scripts/github-traffic-collector.py
```

### 8. Metrics Tracked

- **Views**: Page views and unique visitors
- **Clones**: Git clones and unique cloners  
- **Popular Paths**: Most visited pages
- **Referrers**: Traffic sources
- **Daily Trends**: Historical patterns

## Important Notes

- GitHub API has rate limits (5000 requests/hour with token)
- Traffic data older than 14 days is permanently lost if not collected
- Clone data helps track developer adoption
- View data helps track user interest
- Referrer data shows where traffic comes from (social, search, direct)

## Quick Stats Command

Get current stats without storing:
```bash
curl -H "Authorization: token YOUR_TOKEN" \
     https://api.github.com/repos/csnp/qramm/traffic/views | \
     jq '{total_views: .count, unique_visitors: .uniques}'
```