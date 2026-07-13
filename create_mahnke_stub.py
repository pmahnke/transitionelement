#!/usr/bin/env python3
import os
import sys
import re
from datetime import datetime

# --- CONFIGURATION ---
PUBLIC_BASE_DIR = os.path.expanduser("~/src/transitionelement")
PERSONAL_BASE_DIR = os.path.expanduser("~/src/mahnke")
PUBLIC_URL_ROOT = "https://transitionelement.com"
MEDIA_URL_ROOT = "https://media.transitionelement.com"

def parse_front_matter(file_path):
    """Parses YAML front matter, handling block scalars like 'excerpt: |'."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if not match:
        return {}, ""
    
    yaml_text = match.group(1)
    body_text = content[match.end():].strip()
    
    metadata = {}
    current_key = None
    is_block_scalar = False
    block_lines = []

    for line in yaml_text.split('\n'):
        # If we are in a block scalar and the line is indented (or empty), capture it
        if is_block_scalar and (line.startswith(' ') or line.startswith('\t') or line.strip() == ''):
            block_lines.append(line.strip())
            continue
        elif is_block_scalar:
            # We hit a non-indented line, meaning the block scalar has ended
            metadata[current_key] = " ".join(block_lines).strip()
            is_block_scalar = False
            block_lines = []

        if ':' in line:
            key, val = line.split(':', 1)
            key = key.strip()
            val = val.strip().strip('"').strip("'")
            
            if val == '|' or val == '>':
                current_key = key
                is_block_scalar = True
            else:
                metadata[key] = val
                
    # Catch any dangling block scalar at the end of the YAML front matter
    if is_block_scalar and block_lines:
        metadata[current_key] = " ".join(block_lines).strip()

    return metadata, body_text

def main():
    if len(sys.argv) < 2:
        print("Usage: create_stub.py <path_to_post>")
        print("Example: create_stub.py _posts/2026/2026-03-15-singapore.md")
        sys.exit(1)
        
    # Strip any leading slashes
    partial_path = sys.argv[1].lstrip('/')
    
    # NEW: If the user included '_posts/' in the argument, strip it out 
    # to prevent double-nesting the path.
    if partial_path.startswith('_posts/'):
        partial_path = partial_path[7:] # 7 is the character length of '_posts/'
        
    public_post_path = os.path.join(PUBLIC_BASE_DIR, "_posts", partial_path)
    
    if not os.path.exists(public_post_path):
        print(f"[-] Error: Source post not found at {public_post_path}")
        sys.exit(1)
        
    # 1. Parse the public post
    metadata, body = parse_front_matter(public_post_path)
    title = metadata.get('title', 'Untitled Post')
    post_date = metadata.get('date', '')
    
    # fallback for excerpt if not explicitly set in front matter
    excerpt = metadata.get('excerpt')
    if not excerpt:
        # Take the first paragraph or first 200 chars of the body as fallback
        clean_body = re.sub(r'\{%.*?%\}|<!.*?>', '', body) # remove liquid/comments
        paragraphs = [p.strip() for p in clean_body.split('\n\n') if p.strip()]
        excerpt = paragraphs[0][:200] + "..." if paragraphs else "Click through to read the full post."

    # 2. Extract and format the image path
    raw_image = metadata.get('image', '')
    if raw_image:
        if raw_image.startswith('http'):
            image_url = raw_image
        else:
            # Strip leading slash to prevent double slashes when joining
            clean_image_path = raw_image.lstrip('/')
            image_url = f"{MEDIA_URL_ROOT}/{clean_image_path}"
    else:
        image_url = ""

    # 3. Calculate the target URL on the public blog
    filename = os.path.basename(public_post_path)
    
    # Check if the post defines an explicit permalink
    if 'permalink' in metadata:
        permalink_path = metadata['permalink'].lstrip('/')
        external_link = f"{PUBLIC_URL_ROOT}/{permalink_path}"
    else:
        # Fallback to Jekyll standard date pattern if no permalink is defined
        date_match = re.match(r'^(\d{4})-(\d{2})-(\d{2})-(.*)\.(md|markdown)$', filename)
        if date_match:
            year, month, day, slug, _ = date_match.groups()
            external_link = f"{PUBLIC_URL_ROOT}/{year}/{month}/{day}/{slug}.html"
        else:
            year = datetime.now().strftime("%Y")
            external_link = f"{PUBLIC_URL_ROOT}/{filename.replace('.md', '.html')}"

    # Calculate target naming conventions for the personal blog
    date_prefix_match = re.match(r'^(\d{4}-\d{2}-\d{2})-(.*)', filename)
    if date_prefix_match:
        date_str, slug_str = date_prefix_match.groups()
        target_filename = f"{date_str}-trans-{slug_str}"
        year = date_str.split('-')[0]
        # If the front matter didn't explicitly have a 'date', extract day from filename as a fallback
        if not post_date:
            post_date = date_str
    else:
        year = datetime.now().strftime("%Y")
        target_filename = f"trans_{filename}"
        if not post_date:
            post_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
    # Fixed: This is now safely outside the if/else blocks
    target_year_dir = os.path.join(PERSONAL_BASE_DIR, "_posts", year)

    # 4. Generate the stub content
    stub_content = f"""---
layout: post
title: "{title}"
date: {post_date}
external_url: "{external_link}"
image: "{image_url}"
excerpt: "{excerpt}"
---
"""

    # 5. Write to the personal blog directory
    os.makedirs(target_year_dir, exist_ok=True)
    target_full_path = os.path.join(target_year_dir, target_filename)
    
    with open(target_full_path, 'w', encoding='utf-8') as f:
        f.write(stub_content)
        
    print(f"[+] Successfully generated stub!")
    print(f"    Source: {public_post_path}")
    print(f"    Target: {target_full_path}")

if __name__ == "__main__":
    main()
