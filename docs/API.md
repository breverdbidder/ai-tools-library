# AI Tools Library - API Documentation

## Overview

The AI Tools Library provides a simple, programmatic interface for accessing curated AI tools data. The library is available in both JSON and YAML formats, making it easy to integrate into any application or workflow.

---

## Data Format

### JSON Structure

The main data file (`data/ai_tools.json`) contains:

```json
{
  "metadata": {
    "version": "1.0.0",
    "last_updated": "2026-02-03",
    "total_tools": 200,
    "total_categories": 22,
    "curated_by": "@eilon.grouper & Manus AI"
  },
  "categories": [...],
  "tools": [...]
}
```

### Tool Object Schema

Each tool in the `tools` array has the following structure:

```json
{
  "id": "string",              // Unique identifier (kebab-case)
  "name": "string",            // Display name
  "url": "string",             // Tool website URL
  "description": "string",     // Brief description
  "category": "string",        // Primary category
  "subcategory": "string",     // Optional subcategory
  "hebrew_support": boolean,   // Hebrew language support
  "price": "string",           // Pricing information
  "rating": number,            // Rating (1-5)
  "tags": ["string"],          // Array of tags
  "last_updated": "string"     // ISO date format
}
```

### Category Object Schema

Each category in the `categories` array has:

```json
{
  "id": "string",              // Unique identifier (kebab-case)
  "name": "string",            // Display name
  "description": "string",     // Category description
  "icon": "string",            // Emoji icon
  "tool_count": number         // Number of tools in category
}
```

---

## Usage Examples

### Python

```python
import json

# Load the library
with open('data/ai_tools.json', 'r') as f:
    data = json.load(f)

# Access metadata
print(f"Total tools: {data['metadata']['total_tools']}")

# Get all tools
tools = data['tools']

# Filter by category
agentic_tools = [t for t in tools if 'Agentic' in t['category']]

# Filter by price
free_tools = [t for t in tools if 'Free' in t['price']]

# Filter by rating
top_rated = [t for t in tools if t['rating'] >= 5]

# Search by tag
open_source = [t for t in tools if 'open-source' in t.get('tags', [])]

# Get specific tool by ID
langchain = next(t for t in tools if t['id'] == 'langchain')
```

### JavaScript/Node.js

```javascript
const fs = require('fs');

// Load the library
const data = JSON.parse(fs.readFileSync('data/ai_tools.json', 'utf8'));

// Access metadata
console.log(`Total tools: ${data.metadata.total_tools}`);

// Get all tools
const tools = data.tools;

// Filter by category
const agenticTools = tools.filter(t => t.category.includes('Agentic'));

// Filter by price
const freeTools = tools.filter(t => t.price.includes('Free'));

// Filter by rating
const topRated = tools.filter(t => t.rating >= 5);

// Search by tag
const openSource = tools.filter(t => t.tags && t.tags.includes('open-source'));

// Get specific tool by ID
const langchain = tools.find(t => t.id === 'langchain');
```

### REST API (Coming Soon)

We're planning to provide a REST API for easier access:

```bash
# Get all tools
GET /api/v1/tools

# Get tools by category
GET /api/v1/tools?category=agentic-ai-development

# Get tool by ID
GET /api/v1/tools/langchain

# Search tools
GET /api/v1/tools/search?q=chatbot

# Get categories
GET /api/v1/categories
```

---

## Query Patterns

### Common Queries

#### 1. Get All Tools in a Category

**Python:**
```python
category_tools = [t for t in tools if t['category'] == 'Agentic AI Development & Frameworks']
```

**JavaScript:**
```javascript
const categoryTools = tools.filter(t => t.category === 'Agentic AI Development & Frameworks');
```

#### 2. Get Free Tools with Hebrew Support

**Python:**
```python
hebrew_free = [t for t in tools if t['hebrew_support'] and 'Free' in t['price']]
```

**JavaScript:**
```javascript
const hebrewFree = tools.filter(t => t.hebrew_support && t.price.includes('Free'));
```

#### 3. Get Top-Rated Open Source Tools

**Python:**
```python
top_open_source = [t for t in tools 
                   if t['rating'] >= 5 
                   and 'open-source' in t.get('tags', [])]
```

**JavaScript:**
```javascript
const topOpenSource = tools.filter(t => 
  t.rating >= 5 && t.tags && t.tags.includes('open-source')
);
```

#### 4. Search by Name (Case-Insensitive)

**Python:**
```python
query = 'langchain'
results = [t for t in tools if query.lower() in t['name'].lower()]
```

**JavaScript:**
```javascript
const query = 'langchain';
const results = tools.filter(t => t.name.toLowerCase().includes(query.toLowerCase()));
```

#### 5. Get Tools by Multiple Tags

**Python:**
```python
required_tags = ['agents', 'framework']
results = [t for t in tools 
           if all(tag in t.get('tags', []) for tag in required_tags)]
```

**JavaScript:**
```javascript
const requiredTags = ['agents', 'framework'];
const results = tools.filter(t => 
  t.tags && requiredTags.every(tag => t.tags.includes(tag))
);
```

---

## Data Files

### Main Files

- **`data/ai_tools.json`** - Complete database in JSON format
- **`data/ai_tools.yaml`** - Complete database in YAML format
- **`data/categories.json`** - Category definitions

### By-Category Files

Individual category files are available in `data/by-category/`:

- `writing.json` - Writing & Content Creation tools
- `chatbots.json` - AI Chatbots & Assistants
- `agentic-ai.json` - Agentic AI tools
- `cybersecurity.json` - Cybersecurity tools
- And more...

---

## Integration Examples

### Building a Web App

```javascript
// Express.js API example
const express = require('express');
const fs = require('fs');

const app = express();
const tools = JSON.parse(fs.readFileSync('data/ai_tools.json'));

app.get('/api/tools', (req, res) => {
  const { category, tag, rating } = req.query;
  
  let filtered = tools.tools;
  
  if (category) {
    filtered = filtered.filter(t => t.category === category);
  }
  
  if (tag) {
    filtered = filtered.filter(t => t.tags && t.tags.includes(tag));
  }
  
  if (rating) {
    filtered = filtered.filter(t => t.rating >= parseInt(rating));
  }
  
  res.json(filtered);
});

app.listen(3000);
```

### Building a CLI Tool

```python
#!/usr/bin/env python3
import json
import sys

def search_tools(query):
    with open('data/ai_tools.json') as f:
        data = json.load(f)
    
    results = [t for t in data['tools'] 
               if query.lower() in t['name'].lower() 
               or query.lower() in t['description'].lower()]
    
    for tool in results:
        print(f"{tool['name']} - {tool['url']}")
        print(f"  {tool['description']}")
        print()

if __name__ == '__main__':
    if len(sys.argv) > 1:
        search_tools(sys.argv[1])
```

---

## Data Updates

The library is updated regularly with new tools and information. Check the `metadata.last_updated` field for the latest update date.

To stay updated:
- Watch the GitHub repository
- Check the releases page
- Subscribe to notifications

---

## Contributing

To add or update tools:

1. Fork the repository
2. Edit `data/ai_tools.json`
3. Ensure your changes follow the schema
4. Submit a pull request

---

## Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/ai-tools-library/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/ai-tools-library/discussions)
