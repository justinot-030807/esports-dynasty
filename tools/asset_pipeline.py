import os
import json
from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageEnhance
import numpy as np

RAW_DIR = r"c:\Users\Hp\Downloads\ESPORTS DYNASTY\raw_assets"
OUT_DIR = r"c:\Users\Hp\Downloads\ESPORTS DYNASTY\assets\images"
os.makedirs(OUT_DIR, exist_ok=True)

manifest = {}
asset_list = []

def record_asset(logical_id, rel_path, category, status="HAVE", w=0, h=0, notes=""):
    manifest[logical_id] = {
        "file": rel_path.replace("\\", "/"),
        "width": w,
        "height": h,
        "category": category,
        "notes": notes
    }
    asset_list.append({
        "id": logical_id,
        "file": rel_path.replace("\\", "/"),
        "status": status,
        "category": category,
        "notes": notes
    })

def clean_magenta(im, tolerance=40):
    """If image has magenta background (#FF00FF), make transparent. Skip if already transparent."""
    im = im.convert("RGBA")
    alpha = np.array(im.getchannel("A"))
    if alpha.min() == 0 and alpha.max() > 0:
        # Already has transparency
        return im
    
    # Check for magenta
    arr = np.array(im)
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    
    # Magenta: high R, low G, high B
    is_magenta = (r > 200) & (b > 200) & (g < tolerance)
    if np.any(is_magenta):
        arr[is_magenta, 3] = 0
        return Image.fromarray(arr, "RGBA")
    return im

def process_branding():
    print("Processing branding...")
    os.makedirs(os.path.join(OUT_DIR, "branding"), exist_ok=True)
    
    # App icon
    im_icon = Image.open(os.path.join(RAW_DIR, "app icon.jpg")).convert("RGBA")
    icon_path = os.path.join(OUT_DIR, "branding", "app_icon.png")
    im_icon.save(icon_path, "PNG")
    record_asset("branding/app_icon", "assets/images/branding/app_icon.png", "branding", "HAVE", im_icon.width, im_icon.height, "App icon")

    # Logo
    im_logo = Image.open(os.path.join(RAW_DIR, "app logo.png")).convert("RGBA")
    logo_path = os.path.join(OUT_DIR, "branding", "logo.png")
    im_logo.save(logo_path, "PNG")
    record_asset("branding/logo", "assets/images/branding/logo.png", "branding", "HAVE", im_logo.width, im_logo.height, "Title logo")

    # Splash
    im_splash = Image.open(os.path.join(RAW_DIR, "splash screen.jpg")).convert("RGBA")
    splash_path = os.path.join(OUT_DIR, "branding", "splash.png")
    im_splash.save(splash_path, "PNG")
    record_asset("branding/splash", "assets/images/branding/splash.png", "branding", "HAVE", im_splash.width, im_splash.height, "Splash screen")

def process_characters():
    print("Processing characters...")
    os.makedirs(os.path.join(OUT_DIR, "characters", "gamer_m01"), exist_ok=True)
    
    char_files = [
        ("male idle.png", "gamer_m01_front_idle.png", "characters/gamer_m01/front_idle"),
        ("male foot left.png", "gamer_m01_front_step1.png", "characters/gamer_m01/front_step1"),
        ("male foot right.png", "gamer_m01_front_step2.png", "characters/gamer_m01/front_step2"),
    ]
    
    # Target character height ~48 on a 48x48 square canvas, anchored bottom-center
    CANVAS_SIZE = 48
    TARGET_H = 44  # leaves 2px top and 2px bottom cushion
    
    for raw_name, out_name, log_id in char_files:
        im = Image.open(os.path.join(RAW_DIR, raw_name)).convert("RGBA")
        # Trim transparent borders
        alpha = np.array(im)[:, :, 3]
        ys, xs = np.where(alpha > 20)
        crop = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
        
        # Scale nearest-neighbor
        orig_w, orig_h = crop.size
        scale = TARGET_H / orig_h
        new_w = max(1, int(round(orig_w * scale)))
        new_h = TARGET_H
        scaled = crop.resize((new_w, new_h), Image.Resampling.NEAREST)
        
        # Pad onto square canvas anchored bottom-center
        canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
        offset_x = (CANVAS_SIZE - new_w) // 2
        offset_y = CANVAS_SIZE - new_h - 2  # anchored bottom-center
        canvas.paste(scaled, (offset_x, offset_y), scaled)
        
        out_path = os.path.join(OUT_DIR, "characters", "gamer_m01", out_name)
        canvas.save(out_path, "PNG")
        rel_path = f"assets/images/characters/gamer_m01/{out_name}"
        record_asset(log_id, rel_path, "character", "HAVE", CANVAS_SIZE, CANVAS_SIZE, f"Gamer M01 {out_name}")

        # Also save high-res cropped version for high-DPI or portrait cards
        hi_out_name = out_name.replace(".png", "_hd.png")
        hi_path = os.path.join(OUT_DIR, "characters", "gamer_m01", hi_out_name)
        crop.save(hi_path, "PNG")
        record_asset(log_id + "_hd", f"assets/images/characters/gamer_m01/{hi_out_name}", "character", "HAVE", crop.width, crop.height, "HD trimmed")

def process_ui_and_buttons():
    print("Processing UI and buttons...")
    os.makedirs(os.path.join(OUT_DIR, "ui"), exist_ok=True)
    
    # UI Panel
    im_panel = Image.open(os.path.join(RAW_DIR, "UI panel.png")).convert("RGBA")
    panel_path = os.path.join(OUT_DIR, "ui", "panel.png")
    im_panel.save(panel_path, "PNG")
    record_asset("ui/panel", "assets/images/ui/panel.png", "ui", "HAVE", im_panel.width, im_panel.height, "Window panel nine-patch")

    # Buttons sheet: 3 buttons (green OK, red Cancel, yellow)
    im_btns = Image.open(os.path.join(RAW_DIR, "buttons crappoble.png")).convert("RGBA")
    # Detected boxes:
    # Box 0: x=[1..833], w=832, y=[1..603], h=602 (Green)
    # Box 1: x=[872..1704], w=832, y=[1..603], h=602 (Red)
    # Box 2: x=[1743..2576], w=833, y=[1..603], h=602 (Yellow)
    slices = [
        ((1, 1, 833, 603), "btn_green.png", "ui/btn_green", "Button Green OK"),
        ((872, 1, 1704, 603), "btn_red.png", "ui/btn_red", "Button Red Cancel"),
        ((1743, 1, 2576, 603), "btn_yellow.png", "ui/btn_yellow", "Button Yellow Option"),
    ]
    for bbox, fname, log_id, note in slices:
        btn_im = im_btns.crop(bbox)
        # Trim transparent edges
        a = np.array(btn_im)[:, :, 3]
        ys, xs = np.where(a > 20)
        btn_im = btn_im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
        out_path = os.path.join(OUT_DIR, "ui", fname)
        btn_im.save(out_path, "PNG")
        record_asset(log_id, f"assets/images/ui/{fname}", "ui", "HAVE", btn_im.width, btn_im.height, note)

def process_icons():
    print("Processing icons...")
    os.makedirs(os.path.join(OUT_DIR, "icons"), exist_ok=True)
    im_icons = Image.open(os.path.join(RAW_DIR, "icons croppable.png")).convert("RGBA")
    
    cols = [0, 426, 853, 1280]
    rows = [0, 411, 822, 1233]
    
    mapping = [
        ["icon_money.png", "icon_fans.png", "icon_fame.png"],
        ["icon_trophy.png", "icon_calendar.png", "icon_energy.png"],
        ["icon_mood.png", "icon_training.png", "icon_stream.png"]
    ]
    
    for r in range(3):
        for c in range(3):
            fname = mapping[r][c]
            log_id = "icons/" + fname.replace(".png", "")
            cell = im_icons.crop((cols[c], rows[r], cols[c+1], rows[r+1]))
            # Trim
            a = np.array(cell)[:, :, 3]
            ys, xs = np.where(a > 20)
            if len(xs) > 0:
                icon_im = cell.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
            else:
                icon_im = cell
            out_path = os.path.join(OUT_DIR, "icons", fname)
            icon_im.save(out_path, "PNG")
            record_asset(log_id, f"assets/images/icons/{fname}", "icons", "HAVE", icon_im.width, icon_im.height, f"Icon {fname}")

def process_banners():
    print("Processing banners...")
    os.makedirs(os.path.join(OUT_DIR, "banners"), exist_ok=True)
    im_banners = Image.open(os.path.join(RAW_DIR, "banners croppable.png")).convert("RGBA")
    
    # 5 banners sorted left to right:
    # 1: [1..450, 356..951] -> T1
    # 2: [499..976, 372..1014] -> T2
    # 3: [1006..1526, 265..1026] -> T3
    # 4: [1555..2081, 125..1151] -> T5
    # 5: [2100..2660, 2..1220] -> T7
    slices = [
        ((1, 350, 455, 960), "banner_t1.png", "banners/banner_t1", "T1 Internet Cafe Cup"),
        ((490, 360, 985, 1025), "banner_t2.png", "banners/banner_t2", "T2 Town League"),
        ((1000, 260, 1535, 1035), "banner_t3.png", "banners/banner_t3", "T3 Provincial Championship"),
        ((1550, 120, 2090, 1160), "banner_t5.png", "banners/banner_t5", "T5 National Pro League"),
        ((2095, 0, 2660, 1222), "banner_t7.png", "banners/banner_t7", "T7 World Championship"),
    ]
    
    saved_banners = {}
    for bbox, fname, log_id, note in slices:
        b_im = im_banners.crop(bbox)
        a = np.array(b_im)[:, :, 3]
        ys, xs = np.where(a > 20)
        if len(xs) > 0:
            b_im = b_im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
        out_path = os.path.join(OUT_DIR, "banners", fname)
        b_im.save(out_path, "PNG")
        saved_banners[fname] = b_im
        record_asset(log_id, f"assets/images/banners/{fname}", "banners", "HAVE", b_im.width, b_im.height, note)
    
    # Part A Section 4:
    # "For T4 and T6 make tinted copies of neighboring banners with a procedural label until real art exists."
    # T4: tinted copy of T3
    im_t3 = saved_banners["banner_t3.png"].copy()
    # Tint by shifting hue: convert to HSV, shift H, convert back
    t4_hsv = im_t3.convert("HSV")
    h, s, v = t4_hsv.split()
    h = h.point(lambda p: (p + 45) % 256)
    t4_tinted = Image.merge("HSV", (h, s, v)).convert("RGBA")
    t4_tinted.putalpha(im_t3.getchannel("A"))
    # Add procedural label "T4 REGIONAL"
    draw = ImageDraw.Draw(t4_tinted)
    draw.text((t4_tinted.width // 2 - 40, t4_tinted.height - 35), "T4 REGIONAL", fill=(255, 255, 255, 220))
    t4_path = os.path.join(OUT_DIR, "banners", "banner_t4.png")
    t4_tinted.save(t4_path, "PNG")
    record_asset("banners/banner_t4", "assets/images/banners/banner_t4.png", "banners", "HAVE", t4_tinted.width, t4_tinted.height, "T4 Regional (tinted fallback)")

    # T6: tinted copy of T5
    im_t5 = saved_banners["banner_t5.png"].copy()
    t6_hsv = im_t5.convert("HSV")
    h, s, v = t6_hsv.split()
    h = h.point(lambda p: (p + 80) % 256)
    t6_tinted = Image.merge("HSV", (h, s, v)).convert("RGBA")
    t6_tinted.putalpha(im_t5.getchannel("A"))
    draw = ImageDraw.Draw(t6_tinted)
    draw.text((t6_tinted.width // 2 - 50, t6_tinted.height - 35), "T6 APAC MASTERS", fill=(255, 255, 255, 220))
    t6_path = os.path.join(OUT_DIR, "banners", "banner_t6.png")
    t6_tinted.save(t6_path, "PNG")
    record_asset("banners/banner_t6", "assets/images/banners/banner_t6.png", "banners", "HAVE", t6_tinted.width, t6_tinted.height, "T6 APAC Masters (tinted fallback)")

def process_furniture_and_house():
    print("Processing furniture and house...")
    os.makedirs(os.path.join(OUT_DIR, "furniture"), exist_ok=True)
    os.makedirs(os.path.join(OUT_DIR, "house"), exist_ok=True)
    
    # Furniture
    furnitures = [
        ("PC SETUP.png", "pc_desk.png", "furniture/pc_desk", "Gaming PC Desk & Chair"),
        ("bunk bed.png", "bunk_bed.png", "furniture/bunk_bed", "Bunk Bed"),
        ("kitchen.png", "kitchen.png", "furniture/kitchen", "Kitchen"),
        ("shelve thropy.png", "trophy_shelf.png", "furniture/trophy_shelf", "Trophy Shelf"),
    ]
    
    for raw_name, out_name, log_id, note in furnitures:
        im = Image.open(os.path.join(RAW_DIR, raw_name)).convert("RGBA")
        a = np.array(im)[:, :, 3]
        ys, xs = np.where(a > 20)
        im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
        out_path = os.path.join(OUT_DIR, "furniture", out_name)
        im.save(out_path, "PNG")
        record_asset(log_id, f"assets/images/furniture/{out_name}", "furniture", "HAVE", im.width, im.height, note)
    
    # House / Floor
    im_floor = Image.open(os.path.join(RAW_DIR, "FLOOR.png")).convert("RGBA")
    # Save complete room background
    room_path = os.path.join(OUT_DIR, "house", "room_background.png")
    im_floor.save(room_path, "PNG")
    record_asset("house/room_background", "assets/images/house/room_background.png", "house", "HAVE", im_floor.width, im_floor.height, "Full isometric room background")
    
    # Sliced wall section (top half ~y 0..630)
    wall = im_floor.crop((0, 0, im_floor.width, 630))
    wall_path = os.path.join(OUT_DIR, "house", "wall_section.png")
    wall.save(wall_path, "PNG")
    record_asset("house/wall_section", "assets/images/house/wall_section.png", "house", "HAVE", wall.width, wall.height, "Wall section with window & poster")

    # Sliced floor tile (bottom half ~y 630..1276)
    floor = im_floor.crop((0, 630, im_floor.width, im_floor.height))
    floor_path = os.path.join(OUT_DIR, "house", "floor_tile.png")
    floor.save(floor_path, "PNG")
    record_asset("house/floor_tile", "assets/images/house/floor_tile.png", "house", "HAVE", floor.width, floor.height, "Isometric floor tile base")

def record_missing_assets():
    # Per Section 4 Missing Art
    missing = [
        ("characters/gamer_f01", "Female characters (use gamer_m01 recolor fallback)", "character"),
        ("characters/staff_coach", "Staff Coach character (use chibi fallback)", "character"),
        ("characters/staff_analyst", "Staff Analyst character (use chibi fallback)", "character"),
        ("characters/staff_manager", "Staff Manager character (use chibi fallback)", "character"),
        ("characters/staff_psych", "Staff Psychologist character (use chibi fallback)", "character"),
        ("characters/staff_cook", "Staff Cook (Kusinero) character (use chibi fallback)", "character"),
        ("characters/staff_streamer", "Staff Stream Producer character (use chibi fallback)", "character"),
        ("furniture/streaming_booth", "Streaming Booth (procedural / placeholder)", "furniture"),
        ("furniture/gym_corner", "Gym Corner (procedural / placeholder)", "furniture"),
        ("furniture/lounge_sofa", "Lounge Sofa & TV (procedural / placeholder)", "furniture"),
        ("furniture/meeting_table", "Meeting Table & Whiteboard (procedural / placeholder)", "furniture"),
        ("furniture/merch_corner", "Merch Corner (procedural / placeholder)", "furniture"),
        ("furniture/generator", "Generator (procedural / placeholder)", "furniture"),
        ("furniture/aircon", "Aircon (procedural / placeholder)", "furniture"),
    ]
    for mid, note, cat in missing:
        asset_list.append({
            "id": mid,
            "file": "FALLBACK",
            "status": "MISSING",
            "category": cat,
            "notes": note
        })

def generate_contact_sheet():
    print("Generating contact sheet...")
    # Assemble a nice visual grid of all HAVE assets
    have_items = [item for item in asset_list if item["status"] == "HAVE"]
    
    # Create thumbnail contact sheet
    CELL_W = 160
    CELL_H = 160
    COLS = 6
    ROWS = (len(have_items) + COLS - 1) // COLS
    
    sheet = Image.new("RGBA", (COLS * CELL_W, ROWS * CELL_H + 40), (27, 42, 73, 255))
    draw = ImageDraw.Draw(sheet)
    draw.text((20, 10), "ESPORTS DYNASTY - ASSET CONTACT SHEET", fill=(245, 183, 0))
    
    for idx, item in enumerate(have_items):
        r = idx // COLS
        c = idx % COLS
        x0 = c * CELL_W
        y0 = r * CELL_H + 40
        
        # Draw cell background border
        draw.rectangle([x0 + 4, y0 + 4, x0 + CELL_W - 4, y0 + CELL_H - 4], outline=(63, 167, 255, 120), fill=(35, 52, 88, 255))
        
        # Load image
        rel_path = item["file"]
        full_path = os.path.join(r"c:\Users\Hp\Downloads\ESPORTS DYNASTY", rel_path.replace("/", "\\"))
        try:
            im = Image.open(full_path).convert("RGBA")
            # Fit inside 120x100
            im.thumbnail((120, 100), Image.Resampling.NEAREST)
            im_x = x0 + (CELL_W - im.width) // 2
            im_y = y0 + 10 + (100 - im.height) // 2
            sheet.paste(im, (im_x, im_y), im)
        except Exception as e:
            print("Error thumbnailing", full_path, e)
        
        # Draw label
        short_id = item["id"].split("/")[-1]
        draw.text((x0 + 8, y0 + CELL_H - 24), short_id[:18], fill=(255, 255, 255, 230))
    
    contact_path = os.path.join(OUT_DIR, "contact_sheet.png")
    sheet.save(contact_path, "PNG")
    print(f"Contact sheet saved to {contact_path}")

def write_manifest_and_list():
    manifest_path = r"c:\Users\Hp\Downloads\ESPORTS DYNASTY\assets\assets_manifest.json"
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
    print(f"Wrote {manifest_path}")

    # Write ASSET_LIST.md
    list_path = r"c:\Users\Hp\Downloads\ESPORTS DYNASTY\ASSET_LIST.md"
    with open(list_path, "w", encoding="utf-8") as f:
        f.write("# ESPORTS DYNASTY - Asset Inventory\n\n")
        f.write("Generated by Asset Pipeline (Python + Pillow) per GAME_DESIGN.md Part A Section 4.\n\n")
        f.write("| Logical ID | Status | Category | Output File | Dimensions | Notes |\n")
        f.write("|---|---|---|---|---|---|\n")
        for item in asset_list:
            dims = f"{manifest.get(item['id'], {}).get('width', '-')}x{manifest.get(item['id'], {}).get('height', '-')}" if item["status"] == "HAVE" else "-"
            f.write(f"| `{item['id']}` | **{item['status']}** | {item['category']} | `{item['file']}` | {dims} | {item['notes']} |\n")
    print(f"Wrote {list_path}")

def main():
    process_branding()
    process_characters()
    process_ui_and_buttons()
    process_icons()
    process_banners()
    process_furniture_and_house()
    record_missing_assets()
    generate_contact_sheet()
    write_manifest_and_list()
    print("Asset pipeline completed successfully!")

if __name__ == "__main__":
    main()
