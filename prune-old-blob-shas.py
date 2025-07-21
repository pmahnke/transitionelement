from collections import defaultdict
import os

# Tracks the latest commit that referenced a given blob
latest_blob_shas = set()
blob_paths = defaultdict(set)
removed_log = []

def prepare(repo):
    head = repo.get_commit(repo.head)
    for path, fc in head.file_changes.items():
        latest_blob_shas.add(fc.blob_id)
        blob_paths[fc.blob_id].add(path)

def blob_callback(blob, metadata):
    # Keep all blobs for now — removals will happen in commit_callback
    pass

def commit_callback(commit):
    for path, fc in commit.file_changes.items():
        if fc.blob_id not in latest_blob_shas:
            removed_log.append({
                'path': path.decode('utf-8', errors='replace'),
                'blob': fc.blob_id.hex(),
                'commit': commit.original_id.hex()
            })
            fc.blob_id = None  # remove from this commit

def finish(repo):
    logfile = os.path.join(repo.directory.decode(), "filter-repo-removed-blobs.log")
    with open(logfile, "w") as f:
        for entry in removed_log:
            f.write(f"{entry['path']} | blob {entry['blob']} | from commit {entry['commit']}\n")
    print(f"Wrote removal log to {logfile}")
