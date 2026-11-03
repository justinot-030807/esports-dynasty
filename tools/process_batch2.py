import os
import json
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy.ndimage import label

BASE_DIR = r"C:\Users\Hp\Downloads\ESPORTS DYNASTY"
RAW_DIR = os.path.join(BASE_DIR, "raw_assets")
SHEET_DIR = os.path.join(RAW_DIR, "sheets")
OUT_IMG_DIR = os.path.join(BASE_DIR, "assets", "images")
CONTACT_DIR = os.path.join(OUT_IMG_DIR, "contact_sheets")
ARTIFACT_CONTACT_DIR = r"C:\Users\Hp\.gemini\antigravity\brain\4043e625-aa8d-4d55-b0c3-ca7e31a3323a\contact_sheets"

os.makedirs(CONTACT_DIR, exist_ok=True)
os.makedirs(ARTIFACT_CONTACT_DIR, exist_ok=True)

# Manifest tracking
manifest_path = os.path.join(BASE_DIR, "assets", "assets_manifest.json")
try:
    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)
except Exception:
    manifest = {}

new_assets_recorded = []

def record(logical_id, rel_path, category, w, h, notes=""):
    manifest[logical_id] = {
        "file": rel_path.replace("\\", "/"),
        "width": w,
        "height": h,
        "category": category,
        "notes": notes
    }
    new_assets_recorded.append({
        "id": logical_id,
        "file": rel_path.replace("\\", "/"),
        "category": category,
        "width": w,
        "height": h,
        "notes": notes
    })

def clean_magenta(im, r_min=170, b_min=170, g_max=105):
    arr = np.array(im.convert("RGBA"))
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    # Chroma key
    is_mag = (r > r_min) & (b > b_min) & (g < g_max)
    # Fringe
    diff_rb = np.abs(r - b)
    is_fringe = (r > 130) & (b > 130) & (g < 115) & (diff_rb < 45)
    arr[is_mag | is_fringe, 3] = 0
    return Image.fromarray(arr, "RGBA")

def clean_purple_chroma(im):
    # for station_active where bg is around (184, 0, 176)
    arr = np.array(im.convert("RGBA"))
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    is_mag = (r > 130) & (b > 120) & (g < 60)
    diff_rb = np.abs(r - b)
    is_fringe = (r > 110) & (b > 100) & (g < 80) & (diff_rb < 40)
    arr[is_mag | is_fringe, 3] = 0
    return Image.fromarray(arr, "RGBA")

def extract_main_object(cell_img):
    arr = np.array(cell_img)
    alpha = arr[:, :, 3]
    mask = alpha > 30
    if not np.any(mask):
        return cell_img
    labeled, num_features = label(mask)
    if num_features == 0:
        return cell_img
    sizes = [np.sum(labeled == i) for i in range(1, num_features + 1)]
    max_size = max(sizes)
    keep_mask = np.zeros_like(mask, dtype=bool)
    for i, s in enumerate(sizes, 1):
        if s >= max(80, int(max_size * 0.05)):
            keep_mask |= (labeled == i)
    if not np.any(keep_mask):
        keep_mask = (labeled == (sizes.index(max_size) + 1))
    ys, xs = np.where(keep_mask)
    cropped = arr[ys.min():ys.max()+1, xs.min():xs.max()+1].copy()
    crop_keep = keep_mask[ys.min():ys.max()+1, xs.min():xs.max()+1]
    cropped[~crop_keep, 3] = 0
    return Image.fromarray(cropped, "RGBA")

print("--- Starting Batch 2 Asset Processing ---")

# 1. match_fx.jpg (4x3)
fx_path = os.path.join(SHEET_DIR, "match_fx.jpg")
if os.path.exists(fx_path):
    print("Processing match_fx.jpg...")
    im = Image.open(fx_path)
    cw = im.width / 4
    ch = im.height / 3
    fx_names = [
        ["banner_kill", "banner_multi", "banner_ace", "banner_clutch"],
        ["fx_hit_spark", "fx_explosion", "fx_shockwave", "fx_beam"],
        ["icon_skull", "fx_shield", "badge_vs", "fx_lightsticks"]
    ]
    out_dir = os.path.join(OUT_IMG_DIR, "effects")
    os.makedirs(out_dir, exist_ok=True)
    for r in range(3):
        for c in range(4):
            name = fx_names[r][c]
            cell = im.crop((int(c * cw), int(r * ch), int((c + 1) * cw), int((r + 1) * ch)))
            cleaned = clean_magenta(cell)
            trimmed = extract_main_object(cleaned)
            save_path = os.path.join(out_dir, f"{name}.png")
            trimmed.save(save_path, "PNG")
            record(f"effects_{name}", f"assets/images/effects/{name}.png", "effects", trimmed.width, trimmed.height)
            print(f"  Saved {name}.png ({trimmed.size})")

# 2. casters.jpg (2x2)
casters_path = os.path.join(SHEET_DIR, "casters.jpg")
if os.path.exists(casters_path):
    print("Processing casters.jpg...")
    im = Image.open(casters_path)
    cw = im.width / 2
    ch = im.height / 2
    c_names = [
        ["tonyo_talk", "maya_talk"],
        ["tonyo_idle", "maya_idle"]
    ]
    out_dir = os.path.join(OUT_IMG_DIR, "characters")
    os.makedirs(out_dir, exist_ok=True)
    for r in range(2):
        for c in range(2):
            name = c_names[r][c]
            cell = im.crop((int(c * cw), int(r * ch), int((c + 1) * cw), int((r + 1) * ch)))
            cleaned = clean_magenta(cell)
            trimmed = extract_main_object(cleaned)
            save_path = os.path.join(out_dir, f"caster_{name}.png")
            trimmed.save(save_path, "PNG")
            record(f"caster_{name}", f"assets/images/characters/caster_{name}.png", "characters", trimmed.width, trimmed.height)
            print(f"  Saved caster_{name}.png ({trimmed.size})")

# 3. station_active.jpg (3x2)
sta_path = os.path.join(SHEET_DIR, "station_active.jpg")
if os.path.exists(sta_path):
    print("Processing station_active.jpg...")
    im = Image.open(sta_path)
    cw = im.width / 3
    ch = im.height / 2
    stations = ["streaming_booth", "gym_corner", "merch_corner"]
    furn_dir = os.path.join(OUT_IMG_DIR, "furniture")
    os.makedirs(furn_dir, exist_ok=True)
    
    # Static sprite sizes
    static_sizes = {}
    for st in stations:
        sp = os.path.join(furn_dir, f"{st}.png")
        if os.path.exists(sp):
            static_sizes[st] = Image.open(sp).size
        else:
            static_sizes[st] = (640, 640)
            
    for r in range(2):
        on_num = r + 1
        for c in range(3):
            st = stations[c]
            name = f"{st}_on{on_num}"
            cell = im.crop((int(c * cw), int(r * ch), int((c + 1) * cw), int((r + 1) * ch)))
            cleaned = clean_purple_chroma(cell)
            trimmed = extract_main_object(cleaned)
            
            # Pad onto exact canvas of static sprite, bottom-center anchored
            target_w, target_h = static_sizes[st]
            canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
            # scale trimmed if larger than canvas
            scale = min(1.0, (target_w * 0.95) / trimmed.width, (target_h * 0.95) / trimmed.height)
            if scale < 1.0:
                new_w = int(trimmed.width * scale)
                new_h = int(trimmed.height * scale)
                trimmed = trimmed.resize((new_w, new_h), Image.Resampling.NEAREST)
                
            paste_x = (target_w - trimmed.width) // 2
            paste_y = target_h - trimmed.height - 4
            canvas.paste(trimmed, (paste_x, paste_y), trimmed)
            
            save_path = os.path.join(furn_dir, f"{name}.png")
            canvas.save(save_path, "PNG")
            record(f"furniture_{name}", f"assets/images/furniture/{name}.png", "furniture", canvas.width, canvas.height)
            print(f"  Saved {name}.png ({canvas.size}) on {target_w}x{target_h} canvas")

# 4. banners_t4_t6.jpg (2x1)
ban_path = os.path.join(SHEET_DIR, "banners_t4_t6.jpg")
if os.path.exists(ban_path):
    print("Processing banners_t4_t6.jpg...")
    im = Image.open(ban_path)
    cw = im.width / 2
    b_names = ["banner_t4", "banner_t6"]
    ban_dir = os.path.join(OUT_IMG_DIR, "banners")
    os.makedirs(ban_dir, exist_ok=True)
    for c in range(2):
        name = b_names[c]
        cell = im.crop((int(c * cw), 0, int((c + 1) * cw), im.height))
        cleaned = clean_magenta(cell)
        trimmed = extract_main_object(cleaned)
        save_path = os.path.join(ban_dir, f"{name}.png")
        trimmed.save(save_path, "PNG")
        record(f"banners_{name}", f"assets/images/banners/{name}.png", "banners", trimmed.width, trimmed.height)
        print(f"  Saved {name}.png ({trimmed.size})")

# 5. match_seated.jpg (3x3 inside square)
seat_path = os.path.join(SHEET_DIR, "match_seated.jpg")
if os.path.exists(seat_path):
    print("Processing match_seated.jpg...")
    im = Image.open(seat_path)
    # Square region detection
    sq = im.crop((32, 492, 688, 1136))
    cw = sq.width / 3
    ch = sq.height / 3
    seat_names = [
        ["seated_blue_focus", "seated_blue_cheer", "seated_blue_slump"],
        ["seated_red_focus", "seated_red_cheer", "seated_red_slump"],
        ["seated_green_focus", "seated_yellow_focus", "seated_purple_focus"]
    ]
    out_dir = os.path.join(OUT_IMG_DIR, "characters", "match")
    os.makedirs(out_dir, exist_ok=True)
    for r in range(3):
        for c in range(3):
            name = seat_names[r][c]
            cell = sq.crop((int(c * cw), int(r * ch), int((c + 1) * cw), int((r + 1) * ch)))
            cleaned = clean_magenta(cell)
            trimmed = extract_main_object(cleaned)
            # Pad to 48x48 bottom-center anchored
            canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
            scale = min(1.0, 44.0 / trimmed.width, 44.0 / trimmed.height)
            if scale < 1.0 or trimmed.width > 44 or trimmed.height > 44:
                scale = min(42.0 / trimmed.width, 42.0 / trimmed.height)
                new_w = max(1, int(trimmed.width * scale))
                new_h = max(1, int(trimmed.height * scale))
                trimmed_scaled = trimmed.resize((new_w, new_h), Image.Resampling.NEAREST)
            else:
                trimmed_scaled = trimmed
            px = (48 - trimmed_scaled.width) // 2
            py = 48 - trimmed_scaled.height - 2
            canvas.paste(trimmed_scaled, (px, py), trimmed_scaled)
            save_path = os.path.join(out_dir, f"{name}.png")
            canvas.save(save_path, "PNG")
            record(f"match_{name}", f"assets/images/characters/match/{name}.png", "characters", 48, 48)
            print(f"  Saved {name}.png (48x48)")

# 6. ui_kit.jpg (4x3)
ui_path = os.path.join(SHEET_DIR, "ui_kit.jpg")
if os.path.exists(ui_path):
    print("Processing ui_kit.jpg...")
    im = Image.open(ui_path)
    cw = im.width / 4
    ch = im.height / 3
    ui_names = [
        ["ribbon", "bubble", "row_frame", "hud_chip"],
        ["ticker", "tab_on", "tab_off", "toggle_on"],
        ["toggle_off", "star_full", "star_half", "star_empty"]
    ]
    ui_dir = os.path.join(OUT_IMG_DIR, "ui")
    os.makedirs(ui_dir, exist_ok=True)
    for r in range(3):
        for c in range(4):
            name = ui_names[r][c]
            cell = im.crop((int(c * cw), int(r * ch), int((c + 1) * cw), int((r + 1) * ch)))
            cleaned = clean_magenta(cell)
            trimmed = extract_main_object(cleaned)
            save_path = os.path.join(ui_dir, f"{name}.png")
            trimmed.save(save_path, "PNG")
            record(f"ui_{name}", f"assets/images/ui/{name}.png", "ui", trimmed.width, trimmed.height)
            print(f"  Saved {name}.png ({trimmed.size})")

# 7. backgrounds (awards_stage & match_stage)
bg_dir = os.path.join(OUT_IMG_DIR, "backgrounds")
os.makedirs(bg_dir, exist_ok=True)

awards_path = os.path.join(SHEET_DIR, "awards_stage.jpg")
if os.path.exists(awards_path):
    im_awards = Image.open(awards_path)
    # scaled to portrait 720x1280
    scaled_awards = im_awards.resize((720, 1280), Image.Resampling.LANCZOS)
    awards_out = os.path.join(bg_dir, "awards_stage.png")
    scaled_awards.save(awards_out, "PNG")
    record("bg_awards_stage", "assets/images/backgrounds/awards_stage.png", "backgrounds", 720, 1280)
    print("  Saved awards_stage.png (720x1280)")

match_stage_path = os.path.join(SHEET_DIR, "match_stage.jpg")
if os.path.exists(match_stage_path):
    im_stage = Image.open(match_stage_path)
    scaled_stage = im_stage.resize((720, 1280), Image.Resampling.LANCZOS)
    # Save base arena
    stage_out = os.path.join(bg_dir, "match_stage.png")
    scaled_stage.save(stage_out, "PNG")
    record("bg_match_stage", "assets/images/backgrounds/match_stage.png", "backgrounds", 720, 1280)
    
    arena_out = os.path.join(bg_dir, "match_stage_arena.png")
    scaled_stage.save(arena_out, "PNG")
    record("bg_match_stage_arena", "assets/images/backgrounds/match_stage_arena.png", "backgrounds", 720, 1280)
    
    # Community stage (warm tone)
    arr_comm = np.array(scaled_stage).astype(float)
    arr_comm[:, :, 0] = np.clip(arr_comm[:, :, 0] * 1.05 + 10, 0, 255)
    arr_comm[:, :, 2] = np.clip(arr_comm[:, :, 2] * 0.90, 0, 255)
    comm_im = Image.fromarray(arr_comm.astype(np.uint8))
    comm_out = os.path.join(bg_dir, "match_stage_community.png")
    comm_im.save(comm_out, "PNG")
    record("bg_match_stage_community", "assets/images/backgrounds/match_stage_community.png", "backgrounds", 720, 1280)
    
    # World stage (gold/epic glow)
    arr_world = np.array(scaled_stage).astype(float)
    arr_world[:, :, 0] = np.clip(arr_world[:, :, 0] * 1.15 + 15, 0, 255)
    arr_world[:, :, 1] = np.clip(arr_world[:, :, 1] * 1.10 + 10, 0, 255)
    world_im = Image.fromarray(arr_world.astype(np.uint8))
    world_out = os.path.join(bg_dir, "match_stage_world.png")
    world_im.save(world_out, "PNG")
    record("bg_match_stage_world", "assets/images/backgrounds/match_stage_world.png", "backgrounds", 720, 1280)
    print("  Saved match stage backgrounds (community, arena, world)")

# 8. Roster Faces (crop top 45% of front_idle)
print("Processing Roster Faces...")
chars_dir = os.path.join(OUT_IMG_DIR, "characters")
face_count = 0
for d in os.listdir(chars_dir):
    cpath = os.path.join(chars_dir, d)
    if os.path.isdir(cpath) and d != "match":
        idle_file = os.path.join(cpath, f"{d}_front_idle.png")
        if os.path.exists(idle_file):
            im_char = Image.open(idle_file)
            cw, ch = im_char.size
            head_h = int(ch * 0.45)
            # Crop top 45%
            head = im_char.crop((0, 0, cw, head_h))
            # Save inside character dir
            head.save(os.path.join(cpath, f"{d}_face.png"), "PNG")
            # Also save directly in characters/
            head.save(os.path.join(chars_dir, f"{d}_face.png"), "PNG")
            record(f"face_{d}", f"assets/images/characters/{d}_face.png", "faces", head.width, head.height)
            face_count += 1
print(f"  Cropped and saved {face_count} character faces!")

# 9. App Launcher Icons
app_icon_src = os.path.join(RAW_DIR, "app icon.jpg")
if os.path.exists(app_icon_src):
    print("Generating Android Launcher App Icons...")
    icon_im = Image.open(app_icon_src)
    res_dir = os.path.join(BASE_DIR, "android", "app", "src", "main", "res")
    mipmap_sizes = {
        "mipmap-mdpi": (48, 48),
        "mipmap-hdpi": (72, 72),
        "mipmap-xhdpi": (96, 96),
        "mipmap-xxhdpi": (144, 144),
        "mipmap-xxxhdpi": (192, 192),
    }
    for folder, size in mipmap_sizes.items():
        fdir = os.path.join(res_dir, folder)
        os.makedirs(fdir, exist_ok=True)
        scaled_icon = icon_im.resize(size, Image.Resampling.LANCZOS)
        scaled_icon.save(os.path.join(fdir, "ic_launcher.png"), "PNG")
        print(f"  Saved {folder}/ic_launcher.png {size}")
        
    # Also save 512x512 app icon in assets/images/
    scaled_512 = icon_im.resize((512, 512), Image.Resampling.LANCZOS)
    scaled_512.save(os.path.join(OUT_IMG_DIR, "app_icon.png"), "PNG")
    record("app_icon", "assets/images/app_icon.png", "system", 512, 512)

# Save updated manifest
with open(manifest_path, "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2)
print("Updated assets_manifest.json with all new entries!")

# 10. Generate Contact Sheets
print("Generating Contact Sheets...")

def make_contact_sheet(image_paths, titles, out_path, cols=4, cell_size=(160, 160)):
    n = len(image_paths)
    if n == 0:
        return
    rows = (n + cols - 1) // cols
    sheet_w = cols * cell_size[0]
    sheet_h = rows * cell_size[1]
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (20, 30, 48, 255))
    draw = ImageDraw.Draw(sheet)
    
    for i, (path, title) in enumerate(zip(image_paths, titles)):
        r = i // cols
        c = i % cols
        x = c * cell_size[0]
        y = r * cell_size[1]
        
        # cell border
        draw.rectangle([x+2, y+2, x+cell_size[0]-2, y+cell_size[1]-2], outline=(44, 66, 100, 255), width=1)
        
        if os.path.exists(path):
            im = Image.open(path)
            # fit into box
            box_w = cell_size[0] - 16
            box_h = cell_size[1] - 32
            scale = min(box_w / im.width, box_h / im.height)
            tw = max(1, int(im.width * scale))
            th = max(1, int(im.height * scale))
            resized = im.resize((tw, th), Image.Resampling.NEAREST if scale >= 1 else Image.Resampling.LANCZOS)
            px = x + (cell_size[0] - tw) // 2
            py = y + (box_h - th) // 2 + 6
            if resized.mode == "RGBA":
                sheet.paste(resized, (px, py), resized)
            else:
                sheet.paste(resized, (px, py))
                
        # label
        draw.text((x + 8, y + cell_size[1] - 22), title[:18], fill=(245, 183, 0, 255))
        
    sheet.save(out_path, "PNG")
    # also copy to artifact dir
    art_path = os.path.join(ARTIFACT_CONTACT_DIR, os.path.basename(out_path))
    sheet.save(art_path, "PNG")
    print(f"  Created contact sheet: {os.path.basename(out_path)} ({n} items)")

# Contact sheet 1: Effects
fx_files = [os.path.join(OUT_IMG_DIR, "effects", f"{name}.png") for row in fx_names for name in row]
fx_titles = [name for row in fx_names for name in row]
make_contact_sheet(fx_files, fx_titles, os.path.join(CONTACT_DIR, "contact_effects_batch2.png"), cols=4)

# Contact sheet 2: Casters & Seated
c_files = [os.path.join(OUT_IMG_DIR, "characters", f"caster_{name}.png") for row in c_names for name in row]
c_titles = [f"caster_{name}" for row in c_names for name in row]
seat_files = [os.path.join(OUT_IMG_DIR, "characters", "match", f"{name}.png") for row in seat_names for name in row]
seat_titles = [name for row in seat_names for name in row]
make_contact_sheet(c_files + seat_files, c_titles + seat_titles, os.path.join(CONTACT_DIR, "contact_match_characters.png"), cols=4)

# Contact sheet 3: Active Stations & Furniture
furn_files = [os.path.join(furn_dir, f"{st}_on{on_num}.png") for on_num in [1, 2] for st in stations]
furn_titles = [f"{st}_on{on_num}" for on_num in [1, 2] for st in stations]
make_contact_sheet(furn_files, furn_titles, os.path.join(CONTACT_DIR, "contact_station_active.png"), cols=3)

# Contact sheet 4: UI Kit
ui_files = [os.path.join(ui_dir, f"{name}.png") for row in ui_names for name in row]
ui_titles = [name for row in ui_names for name in row]
make_contact_sheet(ui_files, ui_titles, os.path.join(CONTACT_DIR, "contact_ui_kit.png"), cols=4)

# Contact sheet 5: Banners & Backgrounds
bg_files = [
    os.path.join(ban_dir, "banner_t4.png"),
    os.path.join(ban_dir, "banner_t6.png"),
    os.path.join(bg_dir, "match_stage_community.png"),
    os.path.join(bg_dir, "match_stage_arena.png"),
    os.path.join(bg_dir, "match_stage_world.png"),
    os.path.join(bg_dir, "awards_stage.png")
]
bg_titles = ["banner_t4", "banner_t6", "stage_community", "stage_arena", "stage_world", "awards_stage"]
make_contact_sheet(bg_files, bg_titles, os.path.join(CONTACT_DIR, "contact_stages_banners.png"), cols=3)

# Contact sheet 6: Sample Faces
sample_faces = []
sample_titles = []
for d in os.listdir(chars_dir)[:16]:
    fp = os.path.join(chars_dir, d, f"{d}_face.png")
    if os.path.exists(fp):
        sample_faces.append(fp)
        sample_titles.append(d)
make_contact_sheet(sample_faces, sample_titles, os.path.join(CONTACT_DIR, "contact_roster_faces.png"), cols=4)

print("--- Batch 2 Processing Complete! ---")
