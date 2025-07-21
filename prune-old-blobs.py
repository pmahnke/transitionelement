from collections import defaultdict
import os

# Track latest blob per file path
latest_blobs = {}
removed_blobs_log = []

# Called before filtering starts
def prepare(repo):
    head = repo.get_commit(repo.head)
    for path, fc in head.file_changes.items():
        latest_blobs[path] = fc.blob_id

# No-op for blobs (we'll remove them via commit callback)
def blob_callback(blob, metadata):
    pass

# Called for each commit
def commit_callback(commit):
    for path, fc in commit.file_changes.items():
        latest_id = latest_blobs.get(path)
        if latest_id and fc.blob_id != latest_id:
            # Remove this outdated file version
            removed_blobs_log.append({
                'path': path.decode('utf-8', errors='replace'),
                'blob_id': fc.blob_id.hex(),
                'commit': commit.original_id.hex(),
            })
            fc.blob_id = None  # Remove from this commit

# Called after filtering ends
def finish(repo):
    logfile = os.path.join(repo.directory.decode(), "filter-repo-removed-blobs.log")
    with open(logfile, "w") as f:
        for entry in removed_blobs_log:
            f.write(f"{entry['path']} | blob {entry['blob_id']} | from commit {entry['commit']}\n")
    print(f"Wrote log of removed blobs to {logfile}")
