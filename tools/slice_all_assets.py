import os
import json
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy.ndimage import label

BASE_DIR = r"c:\Users\Hp\Downloads\ESPORTS DYNASTY"
SHEET_DIR = os.path.join(BASE_DIR, "raw_assets", "sheets")
OUT_IMG_DIR = os.path.join(BASE_DIR, "assets", "images")
CONTACT_DIR = os.path.join(BASE_DIR, "assets", "images", "contact_sheets")
BUILD_CONTACT_DIR = os.path.join(BASE_DIR, "build", "contact_sheets")

os.makedirs(CONTACT_DIR, exist_ok=True)
os.makedirs(BUILD_CONTACT_DIR, exist_ok=True)

# Manifest and Asset list tracking
manifest_path = os.path.join(BASE_DIR, "assets", "assets_manifest.json")
try:
    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)
except Exception:
    manifest = {}

asset_items = []

def record(logical_id, rel_path, category, w, h, notes=""):
    manifest[logical_id] = {
        "file": rel_path.replace("\\", "/"),
        "width": w,
        "height": h,
        "category": category,
        "notes": notes
    }
    asset_items.append({
        "id": logical_id,
        "file": rel_path.replace("\\", "/"),
        "status": "HAVE",
        "category": category,
        "width": w,
        "height": h,
        "notes": notes
    })

def clean_magenta(im):
    arr = np.array(im.convert("RGBA"))
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    # Magenta chroma key
    is_mag = (r > 175) & (b > 175) & (g < 95)
    # Edge fringe
    diff_rb = np.abs(r - b)
    is_mag_edge = (r > 140) & (b > 140) & (g < 110) & (diff_rb < 45)
    # Also purplish artifact edge cleanup
    is_fringe = (r > 120) & (b > 120) & (g < 80) & (diff_rb < 35)
    arr[is_mag | is_mag_edge | is_fringe, 3] = 0
    return Image.fromarray(arr, "RGBA")

def extract_main_object(cell_img, is_strategy_row2=False):
    """Connected component extraction to reject tick marks, border bleed, and labels."""
    arr = np.array(cell_img)
    alpha = arr[:, :, 3]
    mask = alpha > 30
    
    if not np.any(mask):
        return None
        
    labeled, num_features = label(mask)
    if num_features == 0:
        return None
        
    # Find sizes of components
    sizes = [np.sum(labeled == i) for i in range(1, num_features + 1)]
    max_size = max(sizes)
    
    # Keep components that are substantial (> 5% of max_size or > 100 pixels)
    # But if is_strategy_row2, ignore components in bottom 25% of height (text labels)
    h, w = mask.shape
    keep_mask = np.zeros_like(mask, dtype=bool)
    
    for i, s in enumerate(sizes, 1):
        if s >= max(100, int(max_size * 0.05)):
            comp_mask = (labeled == i)
            if is_strategy_row2:
                # check if this component is only in the bottom 25% of the cell
                ys = np.where(comp_mask)[0]
                if ys.min() > h * 0.72:
                    continue  # skip text label
            keep_mask |= comp_mask
            
    if not np.any(keep_mask):
        # fallback to largest component
        largest_comp = (labeled == (sizes.index(max_size) + 1))
        keep_mask = largest_comp
        
    ys, xs = np.where(keep_mask)
    cropped_arr = arr[ys.min():ys.max()+1, xs.min():xs.max()+1].copy()
    # Mask out non-kept pixels
    crop_keep = keep_mask[ys.min():ys.max()+1, xs.min():xs.max()+1]
    cropped_arr[~crop_keep, 3] = 0
    
    return Image.fromarray(cropped_arr, "RGBA")

def process_characters_sheet(fname, cols, rows, char_ids, folder_prefix, cat="character"):
    sheet_path = os.path.join(SHEET_DIR, fname)
    if not os.path.exists(sheet_path):
        print(f"Skipping {fname} (not found)")
        return []
    
    raw = Image.open(sheet_path).convert("RGBA")
    clean = clean_magenta(raw)
    w, h = clean.size
    cw = w / cols
    ch = h / rows
    
    saved_paths = []
    
    for idx, cid in enumerate(char_ids):
        r = idx // cols
        c = idx % cols
        x0 = int(c * cw)
        x1 = int((c + 1) * cw)
        y0 = int(r * ch)
        y1 = int((r + 1) * ch)
        
        cell = clean.crop((x0, y0, x1, y1))
        obj = extract_main_object(cell)
        if obj is None:
            print(f"Warning: {fname} cell {idx} ({cid}) is empty!")
            continue
            
        # Target dir
        char_dir = os.path.join(OUT_IMG_DIR, "characters", cid)
        os.makedirs(char_dir, exist_ok=True)
        
        # Save HD version
        hd_path = os.path.join(char_dir, f"{cid}_front_idle_hd.png")
        obj.save(hd_path, "PNG")
        record(f"characters/{cid}/front_idle_hd", f"assets/images/characters/{cid}/{cid}_front_idle_hd.png", cat, obj.width, obj.height, f"{cid} HD trimmed")
        
        # 48x48 pixel art canvas anchored bottom-center
        CANVAS_SIZE = 48
        TARGET_H = 44
        orig_w, orig_h = obj.size
        scale = TARGET_H / orig_h
        new_w = max(1, int(round(orig_w * scale)))
        new_h = TARGET_H
        scaled = obj.resize((new_w, new_h), Image.Resampling.NEAREST)
        
        canvas = Image.new("RGBA", (CANVAS_SIZE, CANVAS_SIZE), (0, 0, 0, 0))
        off_x = (CANVAS_SIZE - new_w) // 2
        off_y = CANVAS_SIZE - new_h - 2
        canvas.paste(scaled, (off_x, off_y), scaled)
        
        # Save standard {id}_front_idle.png
        idle_path = os.path.join(char_dir, f"{cid}_front_idle.png")
        canvas.save(idle_path, "PNG")
        record(f"characters/{cid}/front_idle", f"assets/images/characters/{cid}/{cid}_front_idle.png", cat, CANVAS_SIZE, CANVAS_SIZE, f"{cid} front idle")
        
        # Also save alias directly in characters/{cid}.png for easy lookup
        alias_path = os.path.join(OUT_IMG_DIR, "characters", f"{cid}.png")
        canvas.save(alias_path, "PNG")
        record(f"characters/{cid}", f"assets/images/characters/{cid}.png", cat, CANVAS_SIZE, CANVAS_SIZE, f"{cid} sprite")
        
        saved_paths.append((cid, idle_path))
        
    print(f"Processed characters sheet {fname}: {len(saved_paths)} sprites.")
    return saved_paths

def process_generic_sheet(fname, cols, rows, item_names, target_folder, cat, prefix=""):
    sheet_path = os.path.join(SHEET_DIR, fname)
    if not os.path.exists(sheet_path):
        print(f"Skipping {fname} (not found)")
        return []
    
    raw = Image.open(sheet_path).convert("RGBA")
    clean = clean_magenta(raw)
    w, h = clean.size
    cw = w / cols
    ch = h / rows
    
    dest_dir = os.path.join(OUT_IMG_DIR, target_folder)
    os.makedirs(dest_dir, exist_ok=True)
    
    saved = []
    
    for idx, iname in enumerate(item_names):
        r = idx // cols
        c = idx % cols
        x0 = int(c * cw)
        x1 = int((c + 1) * cw)
        y0 = int(r * ch)
        y1 = int((r + 1) * ch)
        
        cell = clean.crop((x0, y0, x1, y1))
        is_strat_r2 = (fname == "strategy_system.png" and r == 2)
        obj = extract_main_object(cell, is_strategy_row2=is_strat_r2)
        if obj is None:
            print(f"Warning: {fname} cell {idx} ({iname}) empty!")
            continue
            
        full_name = f"{prefix}{iname}"
        out_path = os.path.join(dest_dir, f"{full_name}.png")
        obj.save(out_path, "PNG")
        
        log_id = f"{target_folder}/{full_name}"
        record(log_id, f"assets/images/{target_folder}/{full_name}.png", cat, obj.width, obj.height, f"{full_name} sprite")
        saved.append((full_name, out_path))
        
    print(f"Processed {fname} -> {target_folder}: {len(saved)} items.")
    return saved

def generate_contact_sheet(title, items, out_filename, cols=6):
    """items: list of (label, file_path)"""
    if not items:
        return
    rows = (len(items) + cols - 1) // cols
    CELL_W = 160
    CELL_H = 160
    HEADER_H = 44
    
    sheet = Image.new("RGBA", (cols * CELL_W, rows * CELL_H + HEADER_H), (18, 26, 44, 255))
    draw = ImageDraw.Draw(sheet)
    draw.text((20, 14), title.upper(), fill=(245, 183, 0, 255))
    
    for idx, (label_text, fpath) in enumerate(items):
        r = idx // cols
        c = idx % cols
        x0 = c * CELL_W
        y0 = r * CELL_H + HEADER_H
        
        draw.rectangle([x0 + 4, y0 + 4, x0 + CELL_W - 4, y0 + CELL_H - 4], outline=(50, 80, 130, 200), fill=(28, 40, 68, 255))
        
        if os.path.exists(fpath):
            try:
                im = Image.open(fpath).convert("RGBA")
                thumb = im.copy()
                thumb.thumbnail((120, 100), Image.Resampling.NEAREST)
                tx = x0 + (CELL_W - thumb.width) // 2
                ty = y0 + 10 + (100 - thumb.height) // 2
                sheet.paste(thumb, (tx, ty), thumb)
            except Exception as e:
                print(f"Error loading {fpath} for contact sheet: {e}")
                
        draw.text((x0 + 8, y0 + CELL_H - 32), label_text[:18], fill=(255, 255, 255, 240))
        draw.text((x0 + 8, y0 + CELL_H - 18), f"{im.width}x{im.height}" if 'im' in locals() else "", fill=(170, 205, 250, 180))
        
    # Save to build/contact_sheets and assets/images/contact_sheets
    p1 = os.path.join(BUILD_CONTACT_DIR, out_filename)
    p2 = os.path.join(CONTACT_DIR, out_filename)
    sheet.save(p1, "PNG")
    sheet.save(p2, "PNG")
    print(f"Contact sheet saved: {p1}")

def main():
    characters_items = []
    furniture_items = []
    items_list = []
    food_items = []
    trophies_items = []
    venues_places_items = []
    icons_items = []
    effects_items = []
    emblems_items = []
    
    # 1. players_male 3x3 -> characters/gamer_m02..m10/{id}_front_idle.png
    male_ids = [f"gamer_m{i:02d}" for i in range(2, 11)]
    characters_items.extend(process_characters_sheet("players_male.png", 3, 3, male_ids, "characters"))
    
    # 2. players_female 3x3 -> characters/gamer_f01..f09/{id}_front_idle.png
    fem_ids = [f"gamer_f{i:02d}" for i in range(1, 10)]
    characters_items.extend(process_characters_sheet("players_female.png", 3, 3, fem_ids, "characters"))
    
    # 3. staff 3x3 -> characters/staff_{coach,analyst,manager,psychologist,cook,producer,mika,scout,guard}/
    staff_ids = [f"staff_{s}" for s in ["coach", "analyst", "manager", "psychologist", "cook", "producer", "mika", "scout", "guard"]]
    characters_items.extend(process_characters_sheet("staff.png", 3, 3, staff_ids, "characters", cat="staff"))
    
    # 4. rival_captains 3x3 -> characters/rival_{kidlat,bakal,dagat,mayon,tarsier,pawikan,agila,banaue,siargao}/
    rival_ids = [f"rival_{r}" for r in ["kidlat", "bakal", "dagat", "mayon", "tarsier", "pawikan", "agila", "banaue", "siargao"]]
    characters_items.extend(process_characters_sheet("rivals_captain.png", 3, 3, rival_ids, "characters", cat="rival"))
    
    # 5. fans_crowd 3x3 -> characters/fan_{kid,teen,auntie,lolo,student,cosplayer,mascot,vlogger,kagawad}/
    fan_ids = [f"fan_{f}" for f in ["kid", "teen", "auntie", "lolo", "student", "cosplayer", "mascot", "vlogger", "kagawad"]]
    characters_items.extend(process_characters_sheet("fans_crowd.png", 3, 3, fan_ids, "characters", cat="fan"))
    
    # 6. furniture_basic 4x3 -> furniture/{gaming_chair,ergo_chair,comfy_bed,dining_table,lounge_sofa,tv_stand,aircon,electric_fan,refrigerator,water_dispenser,wardrobe,shoe_rack}
    furn_basic = [
        "gaming_chair", "ergo_chair", "comfy_bed", "dining_table",
        "lounge_sofa", "tv_stand", "aircon", "electric_fan",
        "refrigerator", "water_dispenser", "wardrobe", "shoe_rack"
    ]
    furniture_items.extend(process_generic_sheet("furniture_basic.png", 4, 3, furn_basic, "furniture", "furniture"))
    
    # 7. stations 3x3 -> furniture/{pro_desk,elite_desk,streaming_booth,gym_corner,meeting_table,merch_corner,generator,fiber_router,trophy_case}
    stations = [
        "pro_desk", "elite_desk", "streaming_booth",
        "gym_corner", "meeting_table", "merch_corner",
        "generator", "fiber_router", "trophy_case"
    ]
    furniture_items.extend(process_generic_sheet("stations.png", 3, 3, stations, "furniture", "furniture"))
    
    # 8. decor 4x3 -> furniture/decor_{plant,cactus,poster,neon_sign,team_banner,parol,framed_photo,wall_clock,bookshelf,bean_bag,banig_rug,fish_tank}
    decor = [
        "plant", "cactus", "poster", "neon_sign",
        "team_banner", "parol", "framed_photo", "wall_clock",
        "bookshelf", "bean_bag", "banig_rug", "fish_tank"
    ]
    furniture_items.extend(process_generic_sheet("decor.png", 4, 3, decor, "furniture", "furniture", prefix="decor_"))
    
    # 9. gadgets 4x3 -> items/gadget_{headset,keyboard,mouse,monitor,laptop,phone,ring_light,microphone,webcam,router,power_strip,controller}
    gadgets = [
        "headset", "keyboard", "mouse", "monitor",
        "laptop", "phone", "ring_light", "microphone",
        "webcam", "router", "power_strip", "controller"
    ]
    items_list.extend(process_generic_sheet("gadgets.png", 4, 3, gadgets, "items", "items", prefix="gadget_"))
    
    # 10. meals 3x3 -> food/meal_{adobo,sinigang,tapsilog,sisig,lechon_kawali,kare_kare,pancit_canton,fried_chicken,tinola}
    meals = [
        "adobo", "sinigang", "tapsilog",
        "sisig", "lechon_kawali", "kare_kare",
        "pancit_canton", "fried_chicken", "tinola"
    ]
    food_items.extend(process_generic_sheet("meals.png", 3, 3, meals, "food", "food", prefix="meal_"))
    
    # 11. merienda_drinks 4x3 -> food/snack_{halo_halo,turon,banana_cue,fishball,kwek_kwek,taho,buko,sago_gulaman,pandesal,cup_noodles,coffee,energy_drink}
    merienda = [
        "halo_halo", "turon", "banana_cue", "fishball",
        "kwek_kwek", "taho", "buko", "sago_gulaman",
        "pandesal", "cup_noodles", "coffee", "energy_drink"
    ]
    food_items.extend(process_generic_sheet("merienda_drinks.png", 4, 3, merienda, "food", "food", prefix="snack_"))
    
    # 12. trophies_awards 4x3 -> trophies/{trophy_t1..t7,award_mvp,award_rookie,award_streamer,award_team,award_play}
    trophies = [
        "trophy_t1", "trophy_t2", "trophy_t3", "trophy_t4",
        "trophy_t5", "trophy_t6", "trophy_t7", "award_mvp",
        "award_rookie", "award_streamer", "award_team", "award_play"
    ]
    trophies_items.extend(process_generic_sheet("trophies_awards.png", 4, 3, trophies, "trophies", "trophies"))
    
    # 13. venues 3x3 -> venues/venue_{internet_cafe,school_gym,barangay_court,town_arena,provincial_hall,regional_arena,national_stadium,apac_arena,world_stadium}
    venues = [
        "internet_cafe", "school_gym", "barangay_court",
        "town_arena", "provincial_hall", "regional_arena",
        "national_stadium", "apac_arena", "world_stadium"
    ]
    venues_places_items.extend(process_generic_sheet("venues.png", 3, 3, venues, "venues", "venues", prefix="venue_"))
    
    # 14. pinoy_places 3x3 -> places/place_{sari_sari,jeepney,tricycle,barangay_hall,church,palengke,mall,airport,hotel}
    places = [
        "sari_sari", "jeepney", "tricycle",
        "barangay_hall", "church", "palengke",
        "mall", "airport", "hotel"
    ]
    venues_places_items.extend(process_generic_sheet("pinoy_places.png", 3, 3, places, "places", "places", prefix="place_"))
    
    # 15. roles_stats 4x3 -> icons/{role_carry,role_mid,role_roamer,role_tank,role_support,stat_aim,stat_reaction,stat_sense,stat_teamwork,stat_mental,stat_stamina,badge_captain}
    roles_stats = [
        "role_carry", "role_mid", "role_roamer", "role_tank",
        "role_support", "stat_aim", "stat_reaction", "stat_sense",
        "stat_teamwork", "stat_mental", "stat_stamina", "badge_captain"
    ]
    icons_items.extend(process_generic_sheet("roles_stats.png", 4, 3, roles_stats, "icons", "icons"))
    
    # 16. nav_speed 4x3 -> icons/{nav_team,nav_plan,nav_compete,nav_build,nav_more,speed_pause,speed_1x,speed_2x,speed_4x,sound_on,sound_off,music}
    nav_speed = [
        "nav_team", "nav_plan", "nav_compete", "nav_build",
        "nav_more", "speed_pause", "speed_1x", "speed_2x",
        "speed_4x", "sound_on", "sound_off", "music"
    ]
    icons_items.extend(process_generic_sheet("nav_speed.png", 4, 3, nav_speed, "icons", "icons"))
    
    # 17. faces_ranks 4x3 -> icons/{face_great,face_good,face_normal,face_tired,face_exhausted,rank_rookie,rank_amateur,rank_semipro,rank_pro,rank_star,rank_legend,level_up}
    faces_ranks = [
        "face_great", "face_good", "face_normal", "face_tired",
        "face_exhausted", "rank_rookie", "rank_amateur", "rank_semipro",
        "rank_pro", "rank_star", "rank_legend", "level_up"
    ]
    icons_items.extend(process_generic_sheet("faces_ranks.png", 4, 3, faces_ranks, "icons", "icons"))
    
    # 18. strategy_system 4x3 -> icons/{strat_rush,strat_teamfight,strat_scale,strat_split,ui_settings,ui_back,ui_close,ui_plus,ui_lock,ui_new,ui_check,ui_warning}
    strat_sys = [
        "strat_rush", "strat_teamfight", "strat_scale", "strat_split",
        "ui_settings", "ui_back", "ui_close", "ui_plus",
        "ui_lock", "ui_new", "ui_check", "ui_warning"
    ]
    icons_items.extend(process_generic_sheet("strategy_system.png", 4, 3, strat_sys, "icons", "icons"))
    
    # 19. emotes_effects 4x3 -> effects/{emote_zzz,emote_sweat,emote_heart,emote_sparkle,emote_angry,emote_music,emote_idea,emote_question,emote_exclaim,fx_coin,fx_confetti,fx_live_dot}
    emotes_effects = [
        "emote_zzz", "emote_sweat", "emote_heart", "emote_sparkle",
        "emote_angry", "emote_music", "emote_idea", "emote_question",
        "emote_exclaim", "fx_coin", "fx_confetti", "fx_live_dot"
    ]
    effects_items.extend(process_generic_sheet("emotes_effects.png", 4, 3, emotes_effects, "effects", "effects"))
    
    # 20. event_icons 4x3 -> icons/event_{brownout,typhoon,viral_clip,controversy,poaching,scam,bribe,burnout,pc_breakdown,patch_notes,fan_meetup,charity}
    event_icons = [
        "brownout", "typhoon", "viral_clip", "controversy",
        "poaching", "scam", "bribe", "burnout",
        "pc_breakdown", "patch_notes", "fan_meetup", "charity"
    ]
    icons_items.extend(process_generic_sheet("event_icons.png", 4, 3, event_icons, "icons", "icons", prefix="event_"))
    
    # 21. rival_emblems 3x3 -> emblems/rival_{kidlat,bakal,dagat,mayon,tarsier,pawikan,agila,banaue,siargao}
    rival_emblems = [
        "kidlat", "bakal", "dagat",
        "mayon", "tarsier", "pawikan",
        "agila", "banaue", "siargao"
    ]
    emblems_items.extend(process_generic_sheet("rival_emblems.png", 3, 3, rival_emblems, "emblems", "emblems", prefix="rival_"))
    
    # 22. my_team_emblems 4x3 -> emblems/my_01..my_12
    my_team = [f"my_{i:02d}" for i in range(1, 13)]
    emblems_items.extend(process_generic_sheet("my_team_emblems.png", 4, 3, my_team, "emblems", "emblems"))
    
    # 23. sponsor_logos 4x3 -> emblems/sponsor_{lakas,voltedge,silog,kapeko,byteburger,bayanihan,gising,tindanet,sulit,pixelpinoy,skylink,kuryente}
    sponsors = [
        "lakas", "voltedge", "silog", "kapeko",
        "byteburger", "bayanihan", "gising", "tindanet",
        "sulit", "pixelpinoy", "skylink", "kuryente"
    ]
    emblems_items.extend(process_generic_sheet("sponsor_logos.png", 4, 3, sponsors, "emblems", "emblems", prefix="sponsor_"))
    
    # Save Contact Sheets per folder
    generate_contact_sheet("Characters (Players, Staff, Rivals, Fans)", characters_items, "contact_characters.png", cols=9)
    generate_contact_sheet("Furniture & Stations & Decor", furniture_items, "contact_furniture.png", cols=6)
    generate_contact_sheet("Gadgets & Items", items_list, "contact_items.png", cols=4)
    generate_contact_sheet("Food & Snacks", food_items, "contact_food.png", cols=6)
    generate_contact_sheet("Trophies & Awards", trophies_items, "contact_trophies.png", cols=4)
    generate_contact_sheet("Venues & Places", venues_places_items, "contact_venues_places.png", cols=6)
    generate_contact_sheet("Icons & Events", icons_items, "contact_icons.png", cols=6)
    generate_contact_sheet("Effects & Emotes", effects_items, "contact_effects.png", cols=4)
    generate_contact_sheet("Emblems & Logos", emblems_items, "contact_emblems.png", cols=6)
    
    # Write manifest
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
    print(f"Updated {manifest_path} with {len(manifest)} assets.")
    
    # Update ASSET_LIST.md
    list_path = os.path.join(BASE_DIR, "ASSET_LIST.md")
    with open(list_path, "w", encoding="utf-8") as f:
        f.write("# ESPORTS DYNASTY - Asset Inventory\n\n")
        f.write("Generated by Asset Pipeline per GAME_DESIGN.md Part A Section 4 and Sheets Processing.\n\n")
        f.write("| Logical ID | Status | Category | Output File | Dimensions | Notes |\n")
        f.write("|---|---|---|---|---|---|\n")
        # Sort by logical id
        for k in sorted(manifest.keys()):
            item = manifest[k]
            dims = f"{item.get('width', '-')}x{item.get('height', '-')}"
            f.write(f"| `{k}` | **HAVE** | {item.get('category', '-')} | `{item.get('file', '-')}` | {dims} | {item.get('notes', '')} |\n")
    print(f"Updated {list_path}.")

if __name__ == "__main__":
    main()
