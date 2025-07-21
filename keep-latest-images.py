from collections import defaultdict

# Track the latest seen blob for each path
latest_blobs = defaultdict(lambda: None)

def blob_callback(blob, metadata):
    # Only care about image files
    if not blob.path.decode('utf-8').lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.webp')):
        return

    # Always store the latest blob we see for each path
    latest_blobs[blob.path] = blob.id

def commit_callback(commit):
    # Walk all files in the commit
    for file in commit.file_changes.values():
        path = file.path
        if path in latest_blobs and file.blob_id != latest_blobs[path]:
            # Older version: drop it from commit
            file.blob_id = None
