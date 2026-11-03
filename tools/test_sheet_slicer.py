import os
from PIL import Image, ImageDraw, ImageFont
import numpy as np

SHEET_DIR = os.path.join("raw_assets", "sheets")
DEBUG_DIR = os.path.join("build", "debug_sheets")
os.makedirs(DEBUG_DIR, exist_ok=True)

# Define configurations for each sheet
# (cols, rows, [expected_names])
SHEET_DEFS = {
    "players_male.png": (3, 3, [f"gamer_m{i:02d}" for i in range(2, 11)]),
    "players_female.png": (3, 3, [f"gamer_f{i:02d}" for i in range(1, 10)]),
    "staff.png": (3, 3, ["coach", "analyst", "manager", "psychologist", "cook", "producer", "mika", "scout", "guard"]),
    "rivals_captain.png": (3, 3, ["kidlat", "bakal", "dagat", "mayon", "tarsier", "pawikan", "agila", "banaue", "siargao"]),
    "fans_crowd.png": (3, 3, ["kid", "teen", "auntie", "lolo", "student", "cosplayer", "mascot", "vlogger", "kagawad"]),
    "furniture_basic.png": (4, 3, [
        "gaming_chair", "ergo_chair", "comfy_bed", "dining_table",
        "lounge_sofa", "tv_stand", "aircon", "electric_fan",
        "refrigerator", "water_dispenser", "wardrobe", "shoe_rack"
    ]),
    "stations.png": (3, 3, [
        "pro_desk", "elite_desk", "streaming_booth",
        "gym_corner", "meeting_table", "merch_corner",
        "generator", "fiber_router", "trophy_case"
    ]),
    "decor.png": (4, 3, [
        "plant", "cactus", "poster", "neon_sign",
        "team_banner", "parol", "framed_photo", "wall_clock",
        "bookshelf", "bean_bag", "banig_rug", "fish_tank"
    ]),
    "gadgets.png": (4, 3, [
        "headset", "keyboard", "mouse", "monitor",
        "laptop", "phone", "ring_light", "microphone",
        "webcam", "router", "power_strip", "controller"
    ]),
    "meals.png": (3, 3, [
        "adobo", "sinigang", "tapsilog",
        "sisig", "lechon_kawali", "kare_kare",
        "pancit_canton", "fried_chicken", "tinola"
    ]),
    "merienda_drinks.png": (4, 3, [
        "halo_halo", "turon", "banana_cue", "fishball",
        "kwek_kwek", "taho", "buko", "sago_gulaman",
        "pandesal", "cup_noodles", "coffee", "energy_drink"
    ]),
    "trophies_awards.png": (4, 3, [
        "trophy_t1", "trophy_t2", "trophy_t3", "trophy_t4",
        "trophy_t5", "trophy_t6", "trophy_t7", "award_mvp",
        "award_rookie", "award_streamer", "award_team", "award_play"
    ]),
    "venues.png": (3, 3, [
        "internet_cafe", "school_gym", "barangay_court",
        "town_arena", "provincial_hall", "regional_arena",
        "national_stadium", "apac_arena", "world_stadium"
    ]),
    "pinoy_places.png": (3, 3, [
        "sari_sari", "jeepney", "tricycle",
        "barangay_hall", "church", "palengke",
        "mall", "airport", "hotel"
    ]),
    "roles_stats.png": (4, 3, [
        "role_carry", "role_mid", "role_roamer", "role_tank",
        "role_support", "stat_aim", "stat_reaction", "stat_sense",
        "stat_teamwork", "stat_mental", "stat_stamina", "badge_captain"
    ]),
    "nav_speed.png": (4, 3, [
        "nav_team", "nav_plan", "nav_compete", "nav_build",
        "nav_more", "speed_pause", "speed_1x", "speed_2x",
        "speed_4x", "sound_on", "sound_off", "music"
    ]),
    "faces_ranks.png": (4, 3, [
        "face_great", "face_good", "face_normal", "face_tired",
        "face_exhausted", "rank_rookie", "rank_amateur", "rank_semipro",
        "rank_pro", "rank_star", "rank_legend", "level_up"
    ]),
    "strategy_system.png": (4, 3, [
        "strat_rush", "strat_teamfight", "strat_scale", "strat_split",
        "ui_settings", "ui_back", "ui_close", "ui_plus",
        "ui_lock", "ui_new", "ui_check", "ui_warning"
    ]),
    "emotes_effects.png": (4, 3, [
        "emote_zzz", "emote_sweat", "emote_heart", "emote_sparkle",
        "emote_angry", "emote_music", "emote_idea", "emote_question",
        "emote_exclaim", "fx_coin", "fx_confetti", "fx_live_dot"
    ]),
    "event_icons.png": (4, 3, [
        "brownout", "typhoon", "viral_clip", "controversy",
        "poaching", "scam", "bribe", "burnout",
        "pc_breakdown", "patch_notes", "fan_meetup", "charity"
    ]),
    "rival_emblems.png": (3, 3, [
        "kidlat", "bakal", "dagat",
        "mayon", "tarsier", "pawikan",
        "agila", "banaue", "siargao"
    ]),
    "my_team_emblems.png": (4, 3, [f"my_{i:02d}" for i in range(1, 13)]),
    "sponsor_logos.png": (4, 3, [
        "lakas", "voltedge", "silog", "kapeko",
        "byteburger", "bayanihan", "gising", "tindanet",
        "sulit", "pixelpinoy", "skylink", "kuryente"
    ]),
}

def clean_magenta(im):
    arr = np.array(im.convert("RGBA"))
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    # Magenta threshold: high R, high B, low G
    is_mag = (r > 175) & (b > 175) & (g < 95)
    # Also near-magenta anti-aliasing / edge spill
    diff_rb = np.abs(r - b)
    is_mag_edge = (r > 140) & (b > 140) & (g < 110) & (diff_rb < 45)
    arr[is_mag | is_mag_edge, 3] = 0
    return Image.fromarray(arr, "RGBA")

def create_debug_sheet(fname, cols, rows, names):
    sheet_path = os.path.join(SHEET_DIR, fname)
    raw_im = Image.open(sheet_path).convert("RGBA")
    clean_im = clean_magenta(raw_im)
    
    w, h = clean_im.size
    cell_w = w / cols
    cell_h = h / rows
    
    # Create verification grid image
    THUMB_W = 180
    THUMB_H = 180
    GRID_W = cols * THUMB_W
    GRID_H = rows * THUMB_H + 40
    
    dbg_img = Image.new("RGBA", (GRID_W, GRID_H), (20, 30, 50, 255))
    draw = ImageDraw.Draw(dbg_img)
    draw.text((10, 10), f"SHEET: {fname} ({cols}x{rows})", fill=(245, 183, 0, 255))
    
    non_mag_arr = np.array(clean_im)[:, :, 3] > 20
    
    idx = 0
    for r in range(rows):
        for c in range(cols):
            x0 = int(c * cell_w)
            x1 = int((c + 1) * cell_w)
            y0 = int(r * cell_h)
            y1 = int((r + 1) * cell_h)
            
            cell = clean_im.crop((x0, y0, x1, y1))
            mask = non_mag_arr[y0:y1, x0:x1]
            
            dx = c * THUMB_W
            dy = r * THUMB_H + 40
            
            # Draw cell box
            draw.rectangle([dx + 2, dy + 2, dx + THUMB_W - 2, dy + THUMB_H - 2], outline=(60, 90, 140, 255), fill=(30, 45, 75, 255))
            
            expected_name = names[idx] if idx < len(names) else f"extra_{idx}"
            
            if np.any(mask):
                ys, xs = np.where(mask)
                sprite_crop = cell.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
                
                # Fit thumbnail into 140x120
                thumb = sprite_crop.copy()
                thumb.thumbnail((140, 120), Image.Resampling.NEAREST)
                tx = dx + (THUMB_W - thumb.width) // 2
                ty = dy + 10 + (120 - thumb.height) // 2
                dbg_img.paste(thumb, (tx, ty), thumb)
                
                # Label
                draw.text((dx + 6, dy + THUMB_H - 34), f"[{idx}] {expected_name}", fill=(255, 255, 255, 255))
                draw.text((dx + 6, dy + THUMB_H - 18), f"{sprite_crop.width}x{sprite_crop.height}", fill=(180, 210, 255, 200))
            else:
                draw.text((dx + 6, dy + THUMB_H - 24), f"[{idx}] EMPTY", fill=(255, 100, 100, 255))
            
            idx += 1
            
    out_dbg = os.path.join(DEBUG_DIR, f"dbg_{fname}")
    dbg_img.save(out_dbg, "PNG")
    print(f"Generated debug sheet: {out_dbg}")

print("Creating debug sheets for all 23 sheets...")
for fname, (cols, rows, names) in SHEET_DEFS.items():
    create_debug_sheet(fname, cols, rows, names)
print("All debug sheets created successfully!")
