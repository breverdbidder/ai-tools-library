#!/usr/bin/env python3
"""
CENTRAL INTELLIGENCE HUB - Auto-Population Script
Scans all GitHub repos and indexes everything to Supabase
Run daily via GitHub Actions or manually

Required environment variables:
- GITHUB_PAT: GitHub Personal Access Token
- SUPABASE_URL: Supabase project URL
- SUPABASE_KEY: Supabase service role key
"""

import os
import json
import requests
from datetime import datetime, timezone

# Configuration from environment
GITHUB_PAT = os.environ['GITHUB_PAT']
SUPABASE_URL = os.environ['SUPABASE_URL']
SUPABASE_KEY = os.environ['SUPABASE_KEY']
GITHUB_ORG = os.environ.get('GITHUB_ORG', 'breverdbidder')

# Project mapping based on repo names
PROJECT_MAP = {
    'zonewise': 'zonewise',
    'bidded': 'biddeed',
    'brevard': 'biddeed',
    'spd': 'spd',
    'life-os': 'life-os',
    'tax': 'life-os',
    'competitive': 'general',
    'context-boot': 'infrastructure',
}

# Important file patterns to index
IMPORTANT_FILES = [
    'README.md', 'SKILL.md', 'PROJECT_STATE.json', 'TODO.md',
    'BRAND', 'STRATEGY', 'SPEC', 'REPORT', 'ANALYSIS'
]

def get_project(repo_name):
    """Determine project from repo name"""
    repo_lower = repo_name.lower()
    for key, project in PROJECT_MAP.items():
        if key in repo_lower:
            return project
    return 'general'

def github_request(endpoint):
    """Make authenticated GitHub API request"""
    headers = {
        'Authorization': f'Bearer {GITHUB_PAT}',
        'Accept': 'application/vnd.github.v3+json'
    }
    response = requests.get(f'https://api.github.com{endpoint}', headers=headers)
    return response.json() if response.status_code == 200 else None

def supabase_upsert(table, data):
    """Upsert data to Supabase"""
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates'
    }
    response = requests.post(
        f'{SUPABASE_URL}/rest/v1/{table}',
        headers=headers,
        json=data
    )
    return response.status_code in [200, 201]

def index_repos():
    """Index all repositories"""
    repos = github_request(f'/users/{GITHUB_ORG}/repos?per_page=100')
    if not repos:
        print("Failed to fetch repos")
        return 0
    
    indexed = 0
    for repo in repos:
        commits = github_request(f'/repos/{GITHUB_ORG}/{repo["name"]}/commits?per_page=1')
        last_commit = commits[0] if commits else None
        
        master_data = {
            'item_type': 'repo',
            'item_name': repo['name'],
            'item_description': repo.get('description', ''),
            'location_type': 'github',
            'location_path': repo['html_url'],
            'project': get_project(repo['name']),
            'tags': [repo.get('language', 'unknown'), 'repository'],
            'item_date': repo.get('updated_at'),
            'content_summary': f"GitHub repo: {repo.get('description', 'No description')}. Last commit: {last_commit['commit']['message'][:100] if last_commit else 'N/A'}"
        }
        
        if supabase_upsert('master_index', master_data):
            indexed += 1
    
    return indexed

def index_important_files():
    """Index important files from each repo"""
    repos = github_request(f'/users/{GITHUB_ORG}/repos?per_page=100')
    if not repos:
        return 0
    
    indexed = 0
    for repo in repos:
        tree = github_request(f'/repos/{GITHUB_ORG}/{repo["name"]}/git/trees/main?recursive=1')
        if not tree or 'tree' not in tree:
            continue
        
        for item in tree['tree']:
            if item['type'] != 'blob':
                continue
            
            is_important = any(pattern.lower() in item['path'].lower() for pattern in IMPORTANT_FILES)
            if not is_important:
                continue
            
            doc_data = {
                'item_type': 'file',
                'item_name': item['path'].split('/')[-1],
                'item_description': f"File in {repo['name']}",
                'location_type': 'github',
                'location_path': f"https://github.com/{GITHUB_ORG}/{repo['name']}/blob/main/{item['path']}",
                'project': get_project(repo['name']),
                'tags': [item['path'].split('.')[-1] if '.' in item['path'] else 'unknown', repo['name']],
                'content_summary': f"File: {item['path']} in repo {repo['name']}"
            }
            
            if supabase_upsert('master_index', doc_data):
                indexed += 1
    
    return indexed

def main():
    print("=" * 50)
    print("CENTRAL INTELLIGENCE HUB - Population Script")
    print(f"Started: {datetime.now(timezone.utc).isoformat()}")
    print("=" * 50)
    
    print("\n1. Indexing repositories...")
    repo_count = index_repos()
    print(f"   Indexed {repo_count} repositories")
    
    print("\n2. Indexing important files...")
    file_count = index_important_files()
    print(f"   Indexed {file_count} important files")
    
    print("\n" + "=" * 50)
    print(f"COMPLETE - Total items indexed: {repo_count + file_count}")
    print("=" * 50)

if __name__ == '__main__':
    main()
