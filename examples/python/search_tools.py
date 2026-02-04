#!/usr/bin/env python3
"""
Example: Search and filter AI tools using the library
"""

import json
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))


class AIToolsLibrary:
    """Simple library interface for AI tools data"""
    
    def __init__(self, data_path='data/ai_tools.json'):
        """Initialize the library with tools data"""
        with open(data_path, 'r') as f:
            self.data = json.load(f)
        self.tools = self.data.get('tools', [])
        self.categories = self.data.get('categories', [])
    
    def get_all_tools(self):
        """Get all tools"""
        return self.tools
    
    def get_by_category(self, category_name):
        """Get tools by category name"""
        return [tool for tool in self.tools if tool['category'] == category_name]
    
    def get_free_tools(self):
        """Get all free tools"""
        return [tool for tool in self.tools if 'free' in tool['price'].lower()]
    
    def get_top_rated(self, min_rating=5):
        """Get tools with rating >= min_rating"""
        return [tool for tool in self.tools if tool['rating'] >= min_rating]
    
    def get_hebrew_supported(self):
        """Get tools with Hebrew support"""
        return [tool for tool in self.tools if tool['hebrew_support']]
    
    def search_by_name(self, query):
        """Search tools by name (case-insensitive)"""
        query = query.lower()
        return [tool for tool in self.tools if query in tool['name'].lower()]
    
    def search_by_tag(self, tag):
        """Search tools by tag"""
        return [tool for tool in self.tools if tag in tool.get('tags', [])]
    
    def get_agentic_tools(self):
        """Get all agentic AI related tools"""
        return [tool for tool in self.tools if 'agentic' in tool['category'].lower()]
    
    def print_tool(self, tool):
        """Pretty print a tool"""
        print(f"\n{'='*60}")
        print(f"Name: {tool['name']}")
        print(f"URL: {tool['url']}")
        print(f"Category: {tool['category']}")
        print(f"Description: {tool['description']}")
        print(f"Price: {tool['price']}")
        print(f"Rating: {'⭐' * tool['rating']}")
        print(f"Hebrew Support: {'✅' if tool['hebrew_support'] else '❌'}")
        if tool.get('tags'):
            print(f"Tags: {', '.join(tool['tags'])}")
        print(f"{'='*60}")


def main():
    """Example usage"""
    print("AI Tools Library - Python Example\n")
    
    # Initialize library
    lib = AIToolsLibrary()
    
    print(f"Total tools loaded: {len(lib.tools)}")
    print(f"Total categories: {len(lib.categories)}\n")
    
    # Example 1: Get all agentic AI tools
    print("\n" + "="*60)
    print("Example 1: Agentic AI Tools")
    print("="*60)
    agentic_tools = lib.get_agentic_tools()
    print(f"Found {len(agentic_tools)} agentic AI tools:")
    for tool in agentic_tools[:3]:  # Show first 3
        print(f"  - {tool['name']} ({tool['category']})")
    
    # Example 2: Get free tools
    print("\n" + "="*60)
    print("Example 2: Free Tools")
    print("="*60)
    free_tools = lib.get_free_tools()
    print(f"Found {len(free_tools)} free tools:")
    for tool in free_tools[:3]:
        print(f"  - {tool['name']} - {tool['price']}")
    
    # Example 3: Get top-rated tools
    print("\n" + "="*60)
    print("Example 3: Top-Rated Tools (5 stars)")
    print("="*60)
    top_rated = lib.get_top_rated(5)
    print(f"Found {len(top_rated)} 5-star tools:")
    for tool in top_rated[:5]:
        print(f"  - {tool['name']}")
    
    # Example 4: Search by tag
    print("\n" + "="*60)
    print("Example 4: Tools with 'open-source' tag")
    print("="*60)
    open_source = lib.search_by_tag('open-source')
    print(f"Found {len(open_source)} open-source tools:")
    for tool in open_source:
        print(f"  - {tool['name']}")
    
    # Example 5: Get tools by category
    print("\n" + "="*60)
    print("Example 5: Competitive Intelligence Tools")
    print("="*60)
    ci_tools = lib.get_by_category('Competitive Intelligence & Reverse Engineering')
    print(f"Found {len(ci_tools)} competitive intelligence tools:")
    for tool in ci_tools:
        lib.print_tool(tool)
    
    # Example 6: Search by name
    print("\n" + "="*60)
    print("Example 6: Search for 'LangChain'")
    print("="*60)
    results = lib.search_by_name('langchain')
    if results:
        lib.print_tool(results[0])
    else:
        print("No results found")


if __name__ == '__main__':
    main()
