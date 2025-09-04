#!/usr/bin/env python3
"""
GitHub Traffic Data Collector for QRAMM
Fetches and stores GitHub traffic data before it expires (14 days)
Run this script daily via cron or GitHub Actions
"""

import json
import os
from datetime import datetime
import requests
from pathlib import Path

# Configuration
GITHUB_TOKEN = os.environ.get('GITHUB_TOKEN')  # Set as environment variable
OWNER = 'csnp'
REPO = 'qramm'
DATA_DIR = Path('traffic-data')

def fetch_traffic_data():
    """Fetch all traffic data from GitHub API"""
    
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    base_url = f'https://api.github.com/repos/{OWNER}/{REPO}'
    
    # Create data directory if it doesn't exist
    DATA_DIR.mkdir(exist_ok=True)
    
    today = datetime.now().strftime('%Y-%m-%d')
    
    # Fetch different traffic metrics
    metrics = {
        'views': f'{base_url}/traffic/views',
        'clones': f'{base_url}/traffic/clones',
        'popular_paths': f'{base_url}/traffic/popular/paths',
        'popular_referrers': f'{base_url}/traffic/popular/referrers'
    }
    
    daily_data = {
        'date': today,
        'timestamp': datetime.now().isoformat(),
        'repository': f'{OWNER}/{REPO}'
    }
    
    for metric_name, url in metrics.items():
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            daily_data[metric_name] = response.json()
            print(f"✓ Fetched {metric_name}")
        else:
            print(f"✗ Failed to fetch {metric_name}: {response.status_code}")
            daily_data[metric_name] = None
    
    # Save to daily file
    daily_file = DATA_DIR / f'{today}.json'
    with open(daily_file, 'w') as f:
        json.dump(daily_data, f, indent=2)
    
    print(f"\n📊 Data saved to {daily_file}")
    
    # Update cumulative file
    update_cumulative_data(daily_data)
    
    return daily_data

def update_cumulative_data(daily_data):
    """Append to cumulative data file"""
    
    cumulative_file = DATA_DIR / 'cumulative_traffic.json'
    
    # Load existing data or create new
    if cumulative_file.exists():
        with open(cumulative_file, 'r') as f:
            cumulative = json.load(f)
    else:
        cumulative = {
            'repository': f'{OWNER}/{REPO}',
            'data_points': []
        }
    
    # Add today's data
    cumulative['data_points'].append(daily_data)
    
    # Save updated cumulative data
    with open(cumulative_file, 'w') as f:
        json.dump(cumulative, f, indent=2)
    
    print(f"📈 Updated cumulative data: {len(cumulative['data_points'])} data points")

def generate_markdown_report():
    """Generate a markdown report from collected data"""
    
    cumulative_file = DATA_DIR / 'cumulative_traffic.json'
    
    if not cumulative_file.exists():
        print("No data to report yet")
        return
    
    with open(cumulative_file, 'r') as f:
        data = json.load(f)
    
    # Calculate totals
    total_views = 0
    total_unique_visitors = 0
    total_clones = 0
    total_unique_cloners = 0
    
    for point in data['data_points']:
        if point.get('views'):
            total_views += point['views'].get('count', 0)
            total_unique_visitors += point['views'].get('uniques', 0)
        if point.get('clones'):
            total_clones += point['clones'].get('count', 0)
            total_unique_cloners += point['clones'].get('uniques', 0)
    
    # Generate report
    report = f"""# GitHub Traffic Report - QRAMM

Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Summary Statistics

- **Total Views**: {total_views:,}
- **Unique Visitors**: {total_unique_visitors:,}
- **Total Clones**: {total_clones:,}
- **Unique Cloners**: {total_unique_cloners:,}
- **Data Points Collected**: {len(data['data_points'])}

## Recent Traffic (Last 7 Days)

| Date | Views | Unique Visitors | Clones | Unique Cloners |
|------|-------|----------------|--------|----------------|
"""
    
    # Add last 7 days of data
    recent_points = data['data_points'][-7:]
    for point in reversed(recent_points):
        date = point['date']
        views = point.get('views', {}).get('count', 0)
        unique_views = point.get('views', {}).get('uniques', 0)
        clones = point.get('clones', {}).get('count', 0)
        unique_clones = point.get('clones', {}).get('uniques', 0)
        
        report += f"| {date} | {views} | {unique_views} | {clones} | {unique_clones} |\n"
    
    # Save report
    report_file = DATA_DIR / 'TRAFFIC_REPORT.md'
    with open(report_file, 'w') as f:
        f.write(report)
    
    print(f"\n📄 Report generated: {report_file}")

if __name__ == '__main__':
    if not GITHUB_TOKEN:
        print("❌ Error: GITHUB_TOKEN environment variable not set")
        print("\nTo set it:")
        print("export GITHUB_TOKEN='your_github_personal_access_token'")
        exit(1)
    
    print(f"🔄 Fetching traffic data for {OWNER}/{REPO}...")
    fetch_traffic_data()
    generate_markdown_report()