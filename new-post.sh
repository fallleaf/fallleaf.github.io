#!/usr/bin/env bash
# new-post.sh - Create new Hugo blog post with interactive prompts
# Usage:
#   ./new-post.sh "Post Title"                    # Interactive mode
#   ./new-post.sh "Post Title" -t "tag1,tag2" -c "cat1" -d "Description" -s "custom-slug"  # Non-interactive
#   ./new-post.sh --help                          # Show help

set -euo pipefail

BLOG_ROOT="/home/fallleaf/blog.fallleaf.net"
CONTENT_DIR="$BLOG_ROOT/content/post"
ASSETS_DIR="$BLOG_ROOT/assets/images"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TITLE=""
TAGS_INPUT=""
CATS_INPUT=""
DESCRIPTION=""
CUSTOM_SLUG=""
INTERACTIVE=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            cat <<EOF
Usage: $0 [OPTIONS] "Post Title"

Options:
  -t, --tags TAGS         Comma-separated tags (e.g., "tech,life")
  -c, --categories CATS   Comma-separated categories (e.g., "programming")
  -d, --description DESC  SEO description
  -s, --slug SLUG         Custom URL slug (ASCII only)
  -y, --yes               Non-interactive mode (use defaults for missing options)
  -h, --help              Show this help

Examples:
  $0 "My First Post"
  $0 "My Post" -t "tech,go" -c "programming" -d "A post about Go"
  $0 "中文标题" -s "chinese-post-1" -y
EOF
            exit 0
            ;;
        -t|--tags)
            TAGS_INPUT="$2"
            shift 2
            ;;
        -c|--categories)
            CATS_INPUT="$2"
            shift 2
            ;;
        -d|--description)
            DESCRIPTION="$2"
            shift 2
            ;;
        -s|--slug)
            CUSTOM_SLUG="$2"
            shift 2
            ;;
        -y|--yes)
            INTERACTIVE=false
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            exit 1
            ;;
        *)
            if [[ -z "$TITLE" ]]; then
                TITLE="$1"
            else
                echo -e "${RED}Multiple titles provided${NC}" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Helper function for interactive input
read_interactive() {
    local prompt="$1"
    local var_name="$2"
    if [[ "$INTERACTIVE" == true ]]; then
        # Check if /dev/tty is writable
        if { true > /dev/tty; } 2>/dev/null; then
            # Has tty, use it
            echo -e "$prompt" > /dev/tty
            read -r "$var_name" < /dev/tty || true
        else
            # No tty available (e.g., piped input), read from stdin
            echo -e "$prompt"
            read -r "$var_name" || true
        fi
    fi
}

# Get title if not provided
if [[ -z "$TITLE" ]]; then
    if [[ "$INTERACTIVE" == true ]]; then
        read_interactive "${BLUE}Enter post title:${NC}" TITLE
    else
        echo -e "${RED}Error: Title is required${NC}" >&2
        exit 1
    fi
fi

if [[ -z "$TITLE" ]]; then
    echo -e "${RED}Error: Title cannot be empty${NC}" >&2
    exit 1
fi

# Generate slug from title
SLUG=$(echo "$TITLE" | perl -CSD -pe 's/[^\p{L}\p{N}]+/-/g; s/^-+|-+$//g; $_ = lc' | sed 's/--*/-/g')

# Check if slug contains non-ASCII or use custom slug
if [[ -n "$CUSTOM_SLUG" ]]; then
    SLUG="$CUSTOM_SLUG"
elif [[ "$SLUG" =~ [^a-z0-9-] ]] || [[ -z "$SLUG" ]]; then
    if [[ "$INTERACTIVE" == true ]]; then
        if { true > /dev/tty; } 2>/dev/null; then
            echo -e "${YELLOW}Title contains non-ASCII characters.${NC}" > /dev/tty
        else
            echo -e "${YELLOW}Title contains non-ASCII characters.${NC}"
        fi
        read_interactive "${BLUE}Enter custom slug (or press Enter for date-based: $(date '+%Y-%m-%d-%H%M')):${NC}" CUSTOM_SLUG
        if [[ -n "$CUSTOM_SLUG" ]]; then
            SLUG="$CUSTOM_SLUG"
        else
            SLUG=$(date '+%Y-%m-%d-%H%M')
        fi
    else
        SLUG=$(date '+%Y-%m-%d-%H%M')
    fi
fi

# Prompt for tags if not provided
if [[ -z "$TAGS_INPUT" && "$INTERACTIVE" == true ]]; then
    read_interactive "${BLUE}Enter tags (comma-separated, optional):${NC}" TAGS_INPUT
fi

# Prompt for categories if not provided
if [[ -z "$CATS_INPUT" && "$INTERACTIVE" == true ]]; then
    read_interactive "${BLUE}Enter categories (comma-separated, optional):${NC}" CATS_INPUT
fi

# Prompt for description if not provided
if [[ -z "$DESCRIPTION" && "$INTERACTIVE" == true ]]; then
    read_interactive "${BLUE}Enter description (optional, for SEO):${NC}" DESCRIPTION
fi

# Format tags and categories for TOML
TAGS=""
if [[ -n "$TAGS_INPUT" ]]; then
    IFS=',' read -ra TAG_ARRAY <<< "$TAGS_INPUT"
    TAGS=$(printf '"%s", ' "${TAG_ARRAY[@]}" | sed 's/, $//')
fi

CATEGORIES=""
if [[ -n "$CATS_INPUT" ]]; then
    IFS=',' read -ra CAT_ARRAY <<< "$CATS_INPUT"
    CATEGORIES=$(printf '"%s", ' "${CAT_ARRAY[@]}" | sed 's/, $//')
fi

# Current date in ISO format
DATE=$(date '+%Y-%m-%dT%H:%M:%S%z')

# Create post directory
POST_DIR="$CONTENT_DIR/$SLUG"
mkdir -p "$POST_DIR"

# Create assets directory for this post
POST_ASSETS_DIR="$ASSETS_DIR/$SLUG"
mkdir -p "$POST_ASSETS_DIR"

# Create placeholder cover image if not exists
COVER_PATH="$POST_ASSETS_DIR/cover.webp"
if [[ ! -f "$COVER_PATH" ]]; then
    # Create a simple placeholder using ImageMagick if available, otherwise copy default
    if command -v magick &> /dev/null; then
        magick -size 1200x630 xc:"#2c3e50" -fill white -gravity center -pointsize 48 -annotate +0+0 "$TITLE" "$COVER_PATH" 2>/dev/null || cp "$BLOG_ROOT/static/img/og-default.webp" "$COVER_PATH" 2>/dev/null || true
    elif command -v convert &> /dev/null; then
        convert -size 1200x630 xc:"#2c3e50" -fill white -gravity center -pointsize 48 -annotate +0+0 "$TITLE" "$COVER_PATH" 2>/dev/null || cp "$BLOG_ROOT/static/img/og-default.webp" "$COVER_PATH" 2>/dev/null || true
    else
        cp "$BLOG_ROOT/static/img/og-default.webp" "$COVER_PATH" 2>/dev/null || true
    fi
fi

# Create index.md with frontmatter
POST_FILE="$POST_DIR/index.md"
cat > "$POST_FILE" <<EOF
+++
title = '$TITLE'
date = '$DATE'
lastmod = '$DATE'
draft = true
tags = [$TAGS]
categories = [$CATEGORIES]
description = '$DESCRIPTION'
slug = '$SLUG'
image = 'images/$SLUG/cover.webp'
+++

<!--more-->

## 概述

<!-- 文章简介，显示在列表页和 SEO description -->

## 正文

### 小节

内容...

## 参考

- [链接标题](URL)
EOF

echo -e "${GREEN}✓ Post created: $POST_FILE${NC}"
echo -e "${GREEN}✓ Assets dir: $POST_ASSETS_DIR${NC}"
echo -e "${YELLOW}Cover image: $COVER_PATH (placeholder)${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Edit the post: ${YELLOW}\$EDITOR $POST_FILE${NC}"
echo "  2. Replace cover.webp with your own image (1200x630 recommended)"
echo "  3. Set draft = false when ready to publish"
echo "  4. Run ${YELLOW}hugo server -D${NC} to preview"

# Open in editor if set
if [[ -n "${EDITOR:-}" ]]; then
    "$EDITOR" "$POST_FILE"
else
    echo "  (Set EDITOR env var to auto-open, e.g., export EDITOR=vim)"
fi