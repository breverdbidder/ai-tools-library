#!/usr/bin/env node
/**
 * Example: Search and filter AI tools using the library (JavaScript/Node.js)
 */

const fs = require('fs');
const path = require('path');

class AIToolsLibrary {
  constructor(dataPath = 'data/ai_tools.json') {
    const fullPath = path.join(__dirname, '../..', dataPath);
    const rawData = fs.readFileSync(fullPath, 'utf8');
    this.data = JSON.parse(rawData);
    this.tools = this.data.tools || [];
    this.categories = this.data.categories || [];
  }

  getAllTools() {
    return this.tools;
  }

  getByCategory(categoryName) {
    return this.tools.filter(tool => tool.category === categoryName);
  }

  getFreeTools() {
    return this.tools.filter(tool => 
      tool.price.toLowerCase().includes('free')
    );
  }

  getTopRated(minRating = 5) {
    return this.tools.filter(tool => tool.rating >= minRating);
  }

  getHebrewSupported() {
    return this.tools.filter(tool => tool.hebrew_support);
  }

  searchByName(query) {
    const lowerQuery = query.toLowerCase();
    return this.tools.filter(tool => 
      tool.name.toLowerCase().includes(lowerQuery)
    );
  }

  searchByTag(tag) {
    return this.tools.filter(tool => 
      tool.tags && tool.tags.includes(tag)
    );
  }

  getAgenticTools() {
    return this.tools.filter(tool => 
      tool.category.toLowerCase().includes('agentic')
    );
  }

  printTool(tool) {
    console.log('\n' + '='.repeat(60));
    console.log(`Name: ${tool.name}`);
    console.log(`URL: ${tool.url}`);
    console.log(`Category: ${tool.category}`);
    console.log(`Description: ${tool.description}`);
    console.log(`Price: ${tool.price}`);
    console.log(`Rating: ${'⭐'.repeat(tool.rating)}`);
    console.log(`Hebrew Support: ${tool.hebrew_support ? '✅' : '❌'}`);
    if (tool.tags && tool.tags.length > 0) {
      console.log(`Tags: ${tool.tags.join(', ')}`);
    }
    console.log('='.repeat(60));
  }
}

// Example usage
function main() {
  console.log('AI Tools Library - JavaScript Example\n');

  // Initialize library
  const lib = new AIToolsLibrary();

  console.log(`Total tools loaded: ${lib.tools.length}`);
  console.log(`Total categories: ${lib.categories.length}\n`);

  // Example 1: Get all agentic AI tools
  console.log('\n' + '='.repeat(60));
  console.log('Example 1: Agentic AI Tools');
  console.log('='.repeat(60));
  const agenticTools = lib.getAgenticTools();
  console.log(`Found ${agenticTools.length} agentic AI tools:`);
  agenticTools.slice(0, 3).forEach(tool => {
    console.log(`  - ${tool.name} (${tool.category})`);
  });

  // Example 2: Get free tools
  console.log('\n' + '='.repeat(60));
  console.log('Example 2: Free Tools');
  console.log('='.repeat(60));
  const freeTools = lib.getFreeTools();
  console.log(`Found ${freeTools.length} free tools:`);
  freeTools.slice(0, 3).forEach(tool => {
    console.log(`  - ${tool.name} - ${tool.price}`);
  });

  // Example 3: Get top-rated tools
  console.log('\n' + '='.repeat(60));
  console.log('Example 3: Top-Rated Tools (5 stars)');
  console.log('='.repeat(60));
  const topRated = lib.getTopRated(5);
  console.log(`Found ${topRated.length} 5-star tools:`);
  topRated.slice(0, 5).forEach(tool => {
    console.log(`  - ${tool.name}`);
  });

  // Example 4: Search by tag
  console.log('\n' + '='.repeat(60));
  console.log('Example 4: Tools with "open-source" tag');
  console.log('='.repeat(60));
  const openSource = lib.searchByTag('open-source');
  console.log(`Found ${openSource.length} open-source tools:`);
  openSource.forEach(tool => {
    console.log(`  - ${tool.name}`);
  });

  // Example 5: Get tools by category
  console.log('\n' + '='.repeat(60));
  console.log('Example 5: Competitive Intelligence Tools');
  console.log('='.repeat(60));
  const ciTools = lib.getByCategory('Competitive Intelligence & Reverse Engineering');
  console.log(`Found ${ciTools.length} competitive intelligence tools:`);
  ciTools.forEach(tool => {
    lib.printTool(tool);
  });

  // Example 6: Search by name
  console.log('\n' + '='.repeat(60));
  console.log('Example 6: Search for "LangChain"');
  console.log('='.repeat(60));
  const results = lib.searchByName('langchain');
  if (results.length > 0) {
    lib.printTool(results[0]);
  } else {
    console.log('No results found');
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = AIToolsLibrary;
