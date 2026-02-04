#!/usr/bin/env python3
"""
Convert AI Tools Guide from Markdown to structured JSON format
"""

import json
import re
from typing import List, Dict

def parse_category_table(category_name: str, table_text: str) -> List[Dict]:
    """Parse a markdown table into structured tool data"""
    tools = []
    lines = table_text.strip().split('\n')
    
    # Skip header and separator
    data_lines = [line for line in lines[2:] if line.strip().startswith('|')]
    
    for line in data_lines:
        parts = [p.strip() for p in line.split('|')[1:-1]]
        if len(parts) >= 5:
            # Extract tool name and URL from markdown link
            tool_match = re.search(r'\[([^\]]+)\]\(([^\)]+)\)', parts[0])
            if tool_match:
                tool_name = tool_match.group(1)
                tool_url = tool_match.group(2)
            else:
                tool_name = parts[0]
                tool_url = ""
            
            tool = {
                "id": tool_name.lower().replace(' ', '-').replace('.', ''),
                "name": tool_name,
                "url": tool_url,
                "description": parts[1],
                "category": category_name,
                "hebrew_support": parts[2] == '✅',
                "price": parts[3],
                "rating": parts[4].count('⭐'),
                "last_updated": "2026-02-03"
            }
            tools.append(tool)
    
    return tools

# Sample data structure - in production, this would parse the markdown file
categories = {
    "Writing & Content Creation": [],
    "AI Chatbots & Assistants": [],
    "Productivity & Workflow": [],
    "Agentic AI & Automation Platforms": [],
    "Cybersecurity for AI & Agentic Systems": [],
    "Startup Valuation & Financial Modeling": [],
    "Data Analytics & Business Intelligence": [],
    "Code Development & DevOps": [],
    "Agentic AI Development & Frameworks": [],
    "Agentic AI Observability & Monitoring": [],
    "Agentic AI Deployment & Orchestration": [],
    "Agentic AI Marketing & Go-to-Market": [],
    "Competitive Intelligence & Reverse Engineering": [],
    "Image Generation & Editing": [],
    "Video Generation & Editing": [],
    "Audio & Music Generation": [],
    "Research & Knowledge Management": [],
    "Education & Learning": [],
    "Web Development & Design": [],
    "Marketing & Social Media": [],
    "Customer Support & Sales": [],
    "SEO & Content Optimization": []
}

print("AI Tools JSON Converter")
print("This script converts the markdown guide to JSON format")
print(f"Categories defined: {len(categories)}")

