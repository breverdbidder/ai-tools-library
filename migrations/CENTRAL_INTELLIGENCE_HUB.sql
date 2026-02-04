-- ============================================================================
-- CENTRAL INTELLIGENCE HUB
-- Single source of truth for ALL organizational knowledge
-- ============================================================================

-- 1. MASTER INDEX - Everything in one table
CREATE TABLE IF NOT EXISTS master_index (
    id SERIAL PRIMARY KEY,
    
    -- What is it?
    item_type VARCHAR(50) NOT NULL, -- 'chat', 'document', 'repo', 'file', 'commit', 'milestone', 'decision'
    item_name VARCHAR(500) NOT NULL,
    item_description TEXT,
    
    -- Where is it?
    location_type VARCHAR(50) NOT NULL, -- 'github', 'supabase', 'claude_chat', 'local'
    location_path TEXT NOT NULL, -- Full URL or path
    
    -- Project context
    project VARCHAR(100), -- 'zonewise', 'biddeed', 'spd', 'life-os', 'michael-swimming'
    tags TEXT[], -- Array of searchable tags
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    item_date TIMESTAMPTZ, -- When the item itself was created (e.g., commit date)
    
    -- Content summary (for quick search)
    content_summary TEXT, -- Claude's summary of the content
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'archived', 'pending_review'
    reviewed_by VARCHAR(100),
    reviewed_at TIMESTAMPTZ,
    review_notes TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes for fast lookup
CREATE INDEX IF NOT EXISTS idx_master_item_type ON master_index(item_type);
CREATE INDEX IF NOT EXISTS idx_master_item_name ON master_index(item_name);
CREATE INDEX IF NOT EXISTS idx_master_project ON master_index(project);
CREATE INDEX IF NOT EXISTS idx_master_tags ON master_index USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_master_created ON master_index(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_master_item_date ON master_index(item_date DESC);
CREATE INDEX IF NOT EXISTS idx_master_fulltext ON master_index USING GIN(to_tsvector('english', item_name || ' ' || COALESCE(item_description, '') || ' ' || COALESCE(content_summary, '')));

-- 2. GITHUB REPOS REGISTRY
CREATE TABLE IF NOT EXISTS github_repos (
    id SERIAL PRIMARY KEY,
    repo_name VARCHAR(255) NOT NULL UNIQUE,
    repo_url TEXT NOT NULL,
    description TEXT,
    project VARCHAR(100),
    primary_language VARCHAR(50),
    last_commit_date TIMESTAMPTZ,
    last_commit_sha VARCHAR(40),
    last_commit_message TEXT,
    file_count INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- 3. CHAT SESSIONS LOG
CREATE TABLE IF NOT EXISTS chat_sessions (
    id SERIAL PRIMARY KEY,
    chat_id VARCHAR(100), -- Claude chat UUID if available
    chat_url TEXT,
    title VARCHAR(500),
    summary TEXT,
    projects TEXT[], -- Which projects discussed
    key_decisions TEXT[], -- Major decisions made
    documents_created TEXT[], -- Files/docs created in this chat
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- 4. DOCUMENTS REGISTRY (enhanced)
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    document_name VARCHAR(500) NOT NULL,
    document_type VARCHAR(50), -- 'report', 'spec', 'code', 'config', 'brand', 'analysis'
    
    -- Location
    repo VARCHAR(255), -- GitHub repo name
    file_path TEXT, -- Path within repo
    full_url TEXT,
    
    -- Context
    project VARCHAR(100),
    created_in_chat VARCHAR(100), -- Reference to chat_sessions
    
    -- Content
    content_summary TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Review tracking
    review_status VARCHAR(50) DEFAULT 'pending',
    review_notes TEXT,
    reviewed_at TIMESTAMPTZ,
    
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_docs_name ON documents(document_name);
CREATE INDEX IF NOT EXISTS idx_docs_project ON documents(project);
CREATE INDEX IF NOT EXISTS idx_docs_repo ON documents(repo);

-- 5. VIEW: Quick Search Everything
CREATE OR REPLACE VIEW v_search_all AS
SELECT 
    id,
    item_type,
    item_name,
    project,
    location_path,
    created_at,
    item_date,
    content_summary,
    tags
FROM master_index
WHERE status = 'active'
ORDER BY COALESCE(item_date, created_at) DESC;

-- Comments
COMMENT ON TABLE master_index IS 'Central hub - search everything from one place';
COMMENT ON TABLE github_repos IS 'All GitHub repositories with last commit info';
COMMENT ON TABLE chat_sessions IS 'Log of Claude chat sessions with summaries';
COMMENT ON TABLE documents IS 'All documents created or reviewed';
