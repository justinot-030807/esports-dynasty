import urllib.request
import re
import os
import sys

URL = "https://drive.google.com/drive/folders/1YnDrtuXvuMl2wY6y2slaKTpx2ydIuvkG"
OUT_DIR = os.path.join("raw_assets", "sheets")
os.makedirs(OUT_DIR, exist_ok=True)

print("Fetching folder page...")
req = urllib.request.Request(URL, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
html = urllib.request.urlopen(req).read().decode("utf-8", errors="ignore")

# Find patterns where filename.png appears with file ID
# In Google Drive folder HTML, entries look like:
# [[null,"FILE_ID"], ... ["filename.png", null, 1] ...
# or [["filename.png",null,1] ... [null,"FILE_ID"]

items = {}

# Match blocks
# Let's search for all .png filenames
png_matches = list(re.finditer(r'\"([\w\-]+\.png)\"', html))
print(f"Found {len(png_matches)} .png mentions in page")

for m in png_matches:
    fname = m.group(1)
    if fname.startswith("logo_") or fname.startswith("drive_") or fname.startswith("broken_"):
        continue
    # Search around this match (within 600 characters before or after) for a Drive file ID (28-35 alphanumeric chars)
    start = max(0, m.start() - 600)
    end = min(len(html), m.end() + 600)
    surrounding = html[start:end]
    
    id_matches = re.findall(r'\[null,\"([a-zA-Z0-9_\-]{28,35})\"\]', surrounding)
    if id_matches:
        items[fname] = id_matches[0]

print(f"Discovered {len(items)} sheet files:")
for k, v in sorted(items.items()):
    print(f"  {k} -> {v}")

# Now download each file
for fname, fid in items.items():
    dest = os.path.join(OUT_DIR, fname)
    if os.path.exists(dest) and os.path.getsize(dest) > 1000:
        print(f"Already exists: {fname} ({os.path.getsize(dest)} bytes)")
        continue
    
    print(f"Downloading {fname} (ID: {fid})...")
    # Google Drive export/download URL for public files:
    dl_url = f"https://drive.google.com/uc?export=download&id={fid}"
    try:
        dl_req = urllib.request.Request(dl_url, headers={"User-Agent": "Mozilla/5.0"})
        data = urllib.request.urlopen(dl_req).read()
        if len(data) < 1000 and b"<!DOCTYPE html" in data:
            # Might need confirm token or alternate direct URL:
            alt_url = f"https://drive.usercontent.google.com/download?id={fid}&export=download&confirm=t"
            data = urllib.request.urlopen(urllib.request.Request(alt_url, headers={"User-Agent": "Mozilla/5.0"})).read()
        
        with open(dest, "wb") as f:
            f.write(data)
        print(f"Saved {fname}: {len(data)} bytes")
    except Exception as e:
        print(f"Failed to download {fname}: {e}")

print("Fetch script completed.")
