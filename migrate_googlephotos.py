import os
import re
import urllib.parse
import requests

# --- CONFIGURATION ---
POSTS_DIR = "./_posts"
DOWNLOAD_TARGET_DIR = "./migrated_media"
NEW_DOMAIN_PREFIX = "/assets/images/google_photos"

# Regex to catch URLs inside quotes (front matter) or parentheses (markdown images)
GOOGLE_URL_PATTERN = r'(https?://[^"\)\s]*googleusercontent\.com/[^"\)\s]*)'

# Ensure local download directory exists
os.makedirs(DOWNLOAD_TARGET_DIR, exist_ok=True)

def download_image(url, save_path):
    """Downloads an image from a URL and saves it locally."""
    try:
        response = requests.get(url, stream=True, timeout=10)
        if response.status_code == 200:
            with open(save_path, 'wb') as f:
                for chunk in response.iter_content(1024):
                    f.write(chunk)
            return True
        else:
            print(f"[-] Failed to download (Status {response.status_code}): {url}")
    except Exception as e:
        print(f"[-] Error downloading {url}: {e}")
    return False

def main():
    url_mapping = {}
    image_counter = 0

    print("[*] Phase 1: Scanning posts and downloading images...")
    
    # Walk through the _posts directory recursively
    for root, dirs, files in os.walk(POSTS_DIR):
        for file in files:
            if not file.endswith(".md"):
                continue
                
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Find all Google User Content URLs in this file
            found_urls = re.findall(GOOGLE_URL_PATTERN, content)
            
            if found_urls:
                for url in set(found_urls): # Use set to avoid processing duplicate URLs in same post
                    if url not in url_mapping:
                        image_counter += 1
                        
                        # Extract an ID from the URL or just use a clean counter name
                        # This generates names like: img_001.jpg (adjust extension if known, or leave generic)
                        file_extension = ".jpg" # Default fallback
                        if ".png" in url.lower(): file_extension = ".png"
                        elif ".gif" in url.lower(): file_extension = ".gif"
                        
                        filename = f"img_{image_counter:03d}{file_extension}"
                        local_save_path = os.path.join(DOWNLOAD_TARGET_DIR, filename)
                        
                        print(f"[+] Downloading: {url} -> {filename}")
                        if download_image(url, local_save_path):
                            # Map old URL to the new remote URL path
                            url_mapping[url] = f"{NEW_DOMAIN_PREFIX}{filename}"

    print(f"\n[*] Phase 2: Updating Markdown files with new asset paths...")
    
    # Run through the files again to update the strings in place
    for root, dirs, files in os.walk(POSTS_DIR):
        for file in files:
            if not file.endswith(".md"):
                continue
                
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            file_updated = False
            for old_url, new_url in url_mapping.items():
                if old_url in content:
                    content = content.replace(old_url, new_url)
                    file_updated = True
            
            if file_updated:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"[#] Updated paths in: {file_path}")

    print("\n[+] Migration Complete! Images are gathered in ./migrated_media")

if __name__ == "__main__":
    main()
