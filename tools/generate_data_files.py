import os
import json

DATA_DIR = r"c:\Users\Hp\Downloads\ESPORTS DYNASTY\assets\data"
os.makedirs(DATA_DIR, exist_ok=True)

# 1. balance.json
balance = {
    "version": "1.0.0",
    "canvas": {"width": 360, "height": 640},
    "grid": {"tile_size": 32},
    "starting": {
        "money": 50000,
        "fame": 0,
        "fans": 50,
        "house_tier": 0,
        "starting_players": 3
    },
    "time": {
        "weeks_per_month": 4,
        "months_per_year": 12,
        "weeks_per_year": 48,
        "total_years": 10,
        "total_weeks": 480,
        "speed_1x_seconds": 8.0,
        "speed_2x_seconds": 4.0,
        "speed_4x_seconds": 2.0
    },
    "salaries_weekly": {
        "Rookie": 400,
        "Amateur": 900,
        "Semi-Pro": 2500,
        "Pro": 7000,
        "Star": 20000,
        "Legend": 60000
    },
    "house_tiers": [
        {"id": "rented_room", "name": "Rented Room", "grid_w": 8, "grid_h": 6, "cost": 0, "fame_req": 0, "rent_monthly": 2000, "staff_slots": 1, "roster_cap": 6},
        {"id": "apartment", "name": "Apartment", "grid_w": 12, "grid_h": 8, "cost": 80000, "fame_req": 100, "rent_monthly": 8000, "staff_slots": 2, "roster_cap": 8},
        {"id": "small_house", "name": "Small House", "grid_w": 16, "grid_h": 10, "cost": 400000, "fame_req": 500, "rent_monthly": 30000, "staff_slots": 3, "roster_cap": 10},
        {"id": "pro_house", "name": "Pro Gaming House", "grid_w": 20, "grid_h": 14, "cost": 3000000, "fame_req": 2500, "rent_monthly": 150000, "staff_slots": 5, "roster_cap": 12},
        {"id": "esports_hq", "name": "Esports Arena HQ", "grid_w": 24, "grid_h": 16, "cost": 20000000, "fame_req": 9000, "rent_monthly": 800000, "staff_slots": 6, "roster_cap": 15}
    ],
    "fatigue_effects": {
        "train": 12,
        "scrim": 8,
        "stream": 5,
        "rest": -25,
        "free_time": -10,
        "tired_threshold": 60,
        "exhausted_threshold": 85
    },
    "ranks": [
        {"name": "Rookie", "min_ovr": 0, "max_ovr": 34},
        {"name": "Amateur", "min_ovr": 35, "max_ovr": 49},
        {"name": "Semi-Pro", "min_ovr": 50, "max_ovr": 64},
        {"name": "Pro", "min_ovr": 65, "max_ovr": 79},
        {"name": "Star", "min_ovr": 80, "max_ovr": 91},
        {"name": "Legend", "min_ovr": 92, "max_ovr": 100}
    ],
    "difficulty_multipliers": {
        "easy": {"income": 1.25, "ai_power": 0.95},
        "normal": {"income": 1.0, "ai_power": 1.0},
        "hard": {"income": 0.8, "ai_power": 1.1}
    }
}
with open(os.path.join(DATA_DIR, "balance.json"), "w", encoding="utf-8") as f:
    json.dump(balance, f, indent=2)

# 2. names.json
names = {
    "first_names_male": [
        "Mark", "John", "Joshua", "Christian", "Angelo", "Kyle", "Justin", "Paolo", "Carl", "Jerome",
        "Arjay", "Aldrin", "Bryan", "Carlo", "Danilo", "EJ", "Francis", "Gerald", "Harold", "Ian",
        "Jan", "Kenneth", "Louie", "Miguel", "Nico", "Oliver", "Patrick", "Rafael", "Stephen", "Tristan"
    ],
    "first_names_female": [
        "Mika", "Bea", "Camille", "Denise", "Ella", "Faith", "Gia", "Hannah", "Iris", "Joy",
        "Kaye", "Lexi", "Mia", "Nicole", "Patricia", "Queen", "Rhea", "Sam", "Tina", "Valerie"
    ],
    "last_names": [
        "Santos", "Reyes", "Cruz", "Bautista", "Ocampo", "Garcia", "Mendoza", "Torres", "Tomas", "Andrada",
        "Castillo", "Flores", "Villanueva", "Ramos", "Castro", "Rivera", "Aquino", "Navarro", "Salazar", "Mercado",
        "Dela Cruz", "Delos Santos", "Valdez", "Soriano", "Pascual", "Manalo", "Domingo", "Perez", "Marquez", "Gomez"
    ],
    "gamer_tags": [
        "Kidlat", "Bagsik", "Tsinelas", "Kupido", "Alon", "Suntok", "Amihan", "Datu", "Gilas", "Lodi",
        "Petmalu", "Kape", "PusongBato", "Agila", "Tala", "Bituin", "Kulog", "Mayon", "Banaue", "PinoyPride",
        "Hagis", "Sibat", "Talas", "Balisong", "KidlatBoy", "KuyaClutch", "AsoNiJuan", "SiopaoKing", "KantoSniper", "LabanPinoy",
        "Tikbalang", "Diwata", "Kapre", "Bathala", "Ginoo", "Bayani", "Tadhana", "Mahiwaga", "Asero", "LakasTae"
    ]
}
with open(os.path.join(DATA_DIR, "names.json"), "w", encoding="utf-8") as f:
    json.dump(names, f, indent=2)

# 3. teams.json (72 AI teams)
teams = {
    "flagship_rivals": [
        {"id": "kidlat", "name": "Kidlat Esports", "captain": "Mark 'Thunder' Santos", "catchphrase": "Kidlat sa bilis, walang kawala!", "colors": ["#1B2A49", "#F5B700"], "tier": 1},
        {"id": "bakal", "name": "Bakal Wolves", "captain": "Bryan 'Iron' Mendoza", "catchphrase": "Bakal ang puso namin!", "colors": ["#4A5568", "#E5484D"], "tier": 2},
        {"id": "dagat", "name": "Dagat Dragons", "captain": "Kyle 'Tide' Cruz", "catchphrase": "Lulubog kayo sa alon!", "colors": ["#1A365D", "#3FA7FF"], "tier": 2},
        {"id": "mayon", "name": "Mayon Flames", "captain": "Jerome 'Magma' Reyes", "catchphrase": "Sasabog ang galing!", "colors": ["#9B2C2C", "#F5B700"], "tier": 3},
        {"id": "tarsier", "name": "Tarsier Tactics", "captain": "Angelo 'Gimbal' Ramos", "catchphrase": "Maliliit pero matatalas!", "colors": ["#2C7A7B", "#3DBE5A"], "tier": 3},
        {"id": "pawikan", "name": "Pawikan Prime", "captain": "Patrick 'Shield' Torres", "catchphrase": "Tibay hanggang dulo!", "colors": ["#22543D", "#9B5DE5"], "tier": 4},
        {"id": "agila", "name": "Agila Ascend", "captain": "Christian 'Apex' Ocampo", "catchphrase": "Lilipad sa tugatog!", "colors": ["#744210", "#F5B700"], "tier": 5},
        {"id": "banaue", "name": "Banaue Bulls", "captain": "Francis 'Terra' Castro", "catchphrase": "Hagdan-hagdang tagumpay!", "colors": ["#276749", "#DD6B20"], "tier": 5}
    ],
    "ai_teams": []
}

team_names = [
    # T1 Local (20)
    ("Internet Cafe Kings", 1, "Manila", ["#2D3748", "#ECC94B"]),
    ("Barangay Busters", 1, "Quezon City", ["#E53E3E", "#FFFFFF"]),
    ("Sari-Sari Squad", 1, "Cavite", ["#DD6B20", "#3182CE"]),
    ("Tambay Titans", 1, "Cebu", ["#319795", "#D69E2E"]),
    ("Pisonet Prodigies", 1, "Davao", ["#805AD5", "#F6E05E"]),
    ("Kalye Crusaders", 1, "Bulacan", ["#D53F8C", "#4FD1C5"]),
    ("Tondo Torpedoes", 1, "Tondo", ["#C53030", "#ED8936"]),
    ("Quiapo Quickstrike", 1, "Quiapo", ["#2B6CB0", "#F6AD55"]),
    ("Pasig Panthers", 1, "Pasig", ["#2C7A7B", "#CBD5E0"]),
    ("Makati Matrix", 1, "Makati", ["#4C51BF", "#A0AEC0"]),
    ("Cubao Cobras", 1, "Cubao", ["#6B46C1", "#FAF089"]),
    ("Marikina Marksmen", 1, "Marikina", ["#975A16", "#ECC94B"]),
    ("Taguig Turbos", 1, "Taguig", ["#285E61", "#BEE3F8"]),
    ("Caloocan Comets", 1, "Caloocan", ["#7B341E", "#FEEBC8"]),
    ("Mandaluyong Mystics", 1, "Mandaluyong", ["#553C9A", "#E9D8FD"]),
    ("Pateros Prowlers", 1, "Pateros", ["#702459", "#FED7E2"]),
    ("Malabon Manta", 1, "Malabon", ["#234E52", "#E6FFFA"]),
    ("Navotas Navigators", 1, "Navotas", ["#2A4365", "#EBF8FF"]),
    ("Valenzuela Vipers", 1, "Valenzuela", ["#742A2A", "#FFF5F5"]),
    ("Paranaque Patriots", 1, "Paranaque", ["#22543D", "#F0FFF4"]),
    # T2 Town (10)
    ("Lipa Lancers", 2, "Batangas", ["#C05621", "#FEEBC8"]),
    ("Angeles Aces", 2, "Pampanga", ["#2C5282", "#E2E8F0"]),
    ("Naga Ninjas", 2, "Camarines Sur", ["#744210", "#FAF089"]),
    ("Iloilo Ironclads", 2, "Iloilo", ["#285E61", "#81E6D9"]),
    ("Bacolod Blades", 2, "Negros", ["#6B46C1", "#D6BCFA"]),
    ("Tacloban Typhoons", 2, "Leyte", ["#1A365D", "#90CDF4"]),
    ("Zamboanga Zephyrs", 2, "Zamboanga", ["#702459", "#FBB6CE"]),
    ("Cagayan Cyclones", 2, "Misamis", ["#1C4532", "#9AE6B4"]),
    ("General Santos Giants", 2, "South Cotabato", ["#742A2A", "#FEB2B2"]),
    ("Baguio Blizzards", 2, "Benguet", ["#2B6CB0", "#EBF8FF"]),
    # T3 Provincial (8)
    ("Batangas Barakos", 3, "Batangas", ["#7B341E", "#ED8936"]),
    ("Pampanga Parols", 3, "Pampanga", ["#975A16", "#F6E05E"]),
    ("Laguna Legends", 3, "Laguna", ["#2C7A7B", "#BEE3F8"]),
    ("Cebu Centurions", 3, "Cebu", ["#22543D", "#C6F6D5"]),
    ("Davao Destroyers", 3, "Davao", ["#4A5568", "#CBD5E0"]),
    ("Bicol Berserkers", 3, "Bicol", ["#9B2C2C", "#FEB2B2"]),
    ("Palawan Pearls", 3, "Palawan", ["#234E52", "#E6FFFA"]),
    ("Bohol Boars", 3, "Bohol", ["#744210", "#FAF089"]),
    # T4 Regional (8)
    ("Luzon Leviathans", 4, "North Luzon", ["#1A365D", "#63B3ED"]),
    ("Visayas Vanguards", 4, "Central Visayas", ["#276749", "#9AE6B4"]),
    ("Mindanao Monarchs", 4, "South Mindanao", ["#7B341E", "#F6AD55"]),
    ("NCR Nomads", 4, "Metro Manila", ["#553C9A", "#B794F4"]),
    ("Sierra Madre Sentinels", 4, "East Luzon", ["#22543D", "#68D391"]),
    ("Cordillera Crest", 4, "Highlands", ["#744210", "#ECC94B"]),
    ("Sulu Sea Sharks", 4, "Island South", ["#2C5282", "#76E4F7"]),
    ("Archipelago Apex", 4, "Islands", ["#285E61", "#E6FFFA"]),
    # T5 National Pro League (6)
    ("Manila Megastars", 5, "NPL", ["#2B6CB0", "#F6E05E"]),
    ("Gilas Gaming", 5, "NPL", ["#C53030", "#3182CE"]),
    ("Maharlika Movement", 5, "NPL", ["#D69E2E", "#1A202C"]),
    ("Pearl Phoenix", 5, "NPL", ["#E53E3E", "#FFFAF0"]),
    ("Katipunan Kings", 5, "NPL", ["#805AD5", "#EBF8FF"]),
    ("Archon Alliance", 5, "NPL", ["#319795", "#2D3748"]),
    # T6 APAC Masters (10)
    ("Seoul Slayers", 6, "South Korea", ["#2B6CB0", "#E53E3E"]),
    ("Tokyo Phantoms", 6, "Japan", ["#1A202C", "#E53E3E"]),
    ("Taipei Titans", 6, "Taiwan", ["#3182CE", "#FFFFFF"]),
    ("Bangkok Basilisks", 6, "Thailand", ["#D69E2E", "#2C5282"]),
    ("Jakarta Juggernauts", 6, "Indonesia", ["#C53030", "#FFFFFF"]),
    ("Hanoi Hydras", 6, "Vietnam", ["#E53E3E", "#ECC94B"]),
    ("Kuala Lumpur Krakens", 6, "Malaysia", ["#319795", "#F6E05E"]),
    ("Singapore Sovereigns", 6, "Singapore", ["#C53030", "#FFFFFF"]),
    ("Sydney Storm", 6, "Australia", ["#2C5282", "#F6AD55"]),
    ("Auckland Aurora", 6, "New Zealand", ["#1A202C", "#4FD1C5"]),
    # T7 World Championship (10)
    ("Berlin Blitz", 7, "Europe", ["#D69E2E", "#1A202C"]),
    ("Paris Paragon", 7, "Europe", ["#2B6CB0", "#E53E3E"]),
    ("London Legion", 7, "Europe", ["#C53030", "#2C5282"]),
    ("Nordic Nova", 7, "Scandinavia", ["#3182CE", "#E2E8F0"]),
    ("NA Dynasty", 7, "North America", ["#2B6CB0", "#E53E3E"]),
    ("Pacific Power", 7, "North America", ["#2C7A7B", "#FAF089"]),
    ("Sao Paulo Samurai", 7, "South America", ["#22543D", "#ECC94B"]),
    ("Buenos Aires Blades", 7, "South America", ["#63B3ED", "#FFFFFF"]),
    ("Beijing Behemoths", 7, "China", ["#C53030", "#ECC94B"]),
    ("Shanghai Shenlong", 7, "China", ["#9B2C2C", "#D69E2E"])
]

for idx, (tname, tier, reg, cols) in enumerate(team_names):
    teams["ai_teams"].append({
        "id": f"team_{idx+1}",
        "name": tname,
        "tier": tier,
        "region": reg,
        "colors": cols,
        "rating": 25 + (tier * 10) + (idx % 7),
        "styles": {"rush": 0.25, "teamfight": 0.25, "scale": 0.25, "split": 0.25}
    })

with open(os.path.join(DATA_DIR, "teams.json"), "w", encoding="utf-8") as f:
    json.dump(teams, f, indent=2)

# 4. tournaments.json (Seed calendar tournaments)
tournaments = [
    {
        "id": "T1-ICC1", "name": "Internet Cafe Cup: Spring", "tier": 1, "division": "arena_clash",
        "weeks": [5, 7], "registration": {"opens": -4, "closes": -1}, "fame": {"min": 0, "max": 499},
        "entry_fee": 500, "travel_cost": 0, "slots": 8, "qualify": [{"open": True}],
        "stages": [{"type": "single_elim", "teams": 8, "bo": 1, "grand_final_bo": 3}],
        "rewards": {"champion_prize": 10000, "fame": 50, "fans": 300, "circuit_points": 100, "trophy": "trophy_bronze_t1"},
        "reschedule": "typhoon_ok", "banner": "banner_t1"
    },
    {
        "id": "T1-CAMPUS", "name": "Campus Clash", "tier": 1, "division": "arena_clash",
        "weeks": [9, 13], "registration": {"opens": -4, "closes": -1}, "fame": {"min": 0, "max": 499},
        "entry_fee": 500, "travel_cost": 0, "slots": 8, "qualify": [{"open": True}],
        "stages": [{"type": "round_robin", "teams": 8, "bo": 1}, {"type": "single_elim", "teams": 4, "bo": 1, "grand_final_bo": 3}],
        "rewards": {"champion_prize": 15000, "fame": 75, "fans": 500, "circuit_points": 120, "trophy": "trophy_school"},
        "reschedule": "typhoon_ok", "banner": "banner_t1"
    },
    {
        "id": "T1-ICC2", "name": "Internet Cafe Cup: Summer", "tier": 1, "division": "arena_clash",
        "weeks": [21, 23], "registration": {"opens": -4, "closes": -1}, "fame": {"min": 0, "max": 499},
        "entry_fee": 500, "travel_cost": 0, "slots": 8, "qualify": [{"open": True}],
        "stages": [{"type": "single_elim", "teams": 8, "bo": 1, "grand_final_bo": 3}],
        "rewards": {"champion_prize": 10000, "fame": 50, "fans": 300, "circuit_points": 100, "trophy": "trophy_bronze_t1"},
        "reschedule": "typhoon_ok", "banner": "banner_t1"
    },
    {
        "id": "T2-TLS", "name": "Town League: Spring", "tier": 2, "division": "arena_clash",
        "weeks": [9, 15], "registration": {"opens": -4, "closes": -1}, "fame": {"min": 100, "max": 1499},
        "entry_fee": 1500, "travel_cost": 0, "slots": 6, "qualify": [{"open": True}],
        "stages": [{"type": "round_robin", "teams": 6, "bo": 3}, {"type": "single_elim", "teams": 4, "bo": 3, "grand_final_bo": 5}],
        "rewards": {"champion_prize": 60000, "fame": 150, "fans": 1500, "circuit_points": 300, "trophy": "trophy_silver_t2"},
        "reschedule": "typhoon_ok", "banner": "banner_t2"
    },
    {
        "id": "T3-PC", "name": "Provincial Championship", "tier": 3, "division": "arena_clash",
        "weeks": [29, 34], "registration": {"opens": -4, "closes": -1}, "fame": {"min": 400, "max": 3999},
        "entry_fee": 8000, "travel_cost": 10000, "slots": 16,
        "qualify": [{"from": "T2-TLS", "top": 3}, {"fill": "circuit_rank"}],
        "stages": [{"type": "double_elim", "teams": 16, "bo": 3, "grand_final_bo": 5, "gf_advantage": "upper"}],
        "rewards": {"champion_prize": 250000, "fame": 400, "fans": 5000, "circuit_points": 1000, "trophy": "trophy_gold_t3"},
        "reschedule": "typhoon_ok", "banner": "banner_t3"
    }
]
with open(os.path.join(DATA_DIR, "tournaments.json"), "w", encoding="utf-8") as f:
    json.dump(tournaments, f, indent=2)

# 5. items.json (Furniture & Decor)
items = [
    {"id": "pc_desk", "name": "Gaming PC Desk", "category": "pc", "size_x": 2, "size_y": 1, "price": 6000, "fame_req": 0, "station": "pc", "training_mult": 1.0, "desc": "Standard 1-station gaming desk."},
    {"id": "bunk_bed", "name": "Bunk Bed", "category": "bed", "size_x": 2, "size_y": 1, "price": 8000, "fame_req": 0, "station": "bed", "fatigue_recovery": 25, "sleep_capacity": 2, "desc": "Sleeps 2 players comfortably."},
    {"id": "kitchen", "name": "Kitchen", "category": "kitchen", "size_x": 2, "size_y": 2, "price": 10000, "fame_req": 0, "station": "kitchen", "morale_weekly": 4, "desc": "Nutritious meals give +4 morale per week."},
    {"id": "trophy_shelf", "name": "Trophy Shelf", "category": "decor", "size_x": 2, "size_y": 1, "price": 5000, "fame_req": 0, "station": "shelf", "style": 2, "capacity": 6, "desc": "Displays trophies and adds prestige."},
    {"id": "pro_desk", "name": "Pro Desk", "category": "pc", "size_x": 2, "size_y": 1, "price": 30000, "fame_req": 150, "station": "pc", "training_mult": 1.25, "desc": "High refresh monitors boost training x1.25."},
    {"id": "gaming_chair", "name": "Gaming Chair", "category": "chair", "size_x": 1, "size_y": 1, "price": 2500, "fame_req": 0, "station": "none", "fatigue_reduction": 0.10, "desc": "-10% fatigue gain while playing."},
    {"id": "streaming_booth", "name": "Streaming Booth", "category": "media", "size_x": 2, "size_y": 2, "price": 25000, "fame_req": 100, "station": "stream", "stream_slots": 2, "desc": "Acoustic panels for streaming content."},
    {"id": "generator", "name": "Generator", "category": "utility", "size_x": 1, "size_y": 1, "price": 40000, "fame_req": 200, "station": "none", "brownout_protection": True, "desc": "Prevents brownouts during storms."}
]
with open(os.path.join(DATA_DIR, "items.json"), "w", encoding="utf-8") as f:
    json.dump(items, f, indent=2)

# 6. events.json (Random events)
events = [
    {
        "id": "EVT_BROWNOUT", "title": "Brownout sa Barangay!", "category": "house",
        "text": "Biglang namatay ang kuryente sa buong subdivision habang nagpa-practice!",
        "choices": [
            {"text": "Paganahin ang generator", "condition": "has_generator", "outcome": {"morale": 2, "text": "Ligtas! Tuloy ang ensayo."}},
            {"text": "Magpahinga muna at magkuwentuhan", "outcome": {"morale": 5, "fatigue": -10, "text": "Masayang bonding sa dilim."}},
            {"text": "Pumunta sa internet cafe", "cost": 1500, "outcome": {"fatigue": 5, "text": "Nakatapos ng scrim pero pagod ang team."}}
        ]
    },
    {
        "id": "EVT_VIRAL_CLIP", "title": "Nag-Viral ang Clutch Play!", "category": "community",
        "text": "May nag-upload sa TikTok ng 1v3 outplay ng player mo kagabi. Umani ng 500k views!",
        "choices": [
            {"text": "I-share sa official team page", "outcome": {"fans": 120, "fame": 15, "text": "+120 Fans at trending ang team!"}},
            {"text": "Hayaan lang, humble muna", "outcome": {"morale": 3, "text": "Focus pa rin sa laro."}}
        ]
    },
    {
        "id": "EVT_SARI_SARI_SPONSOR", "title": "Aling Nena's Sari-Sari Sponsorship", "category": "business",
        "text": "Nag-alok si Aling Nena ng libreng meryenda at P2,000 basta may logo siya sa jersey!",
        "choices": [
            {"text": "Pumayag at isuot ang logo", "outcome": {"money": 2000, "morale": 4, "text": "May libreng bananacue tuwing hapon!"}},
            {"text": "Magalang na tanggihan", "outcome": {"text": "Naghintay ng mas malaking sponsor."}}
        ]
    }
]
with open(os.path.join(DATA_DIR, "events.json"), "w", encoding="utf-8") as f:
    json.dump(events, f, indent=2)

# 7. patches.json
patches = [
    {"version": "1.1", "name": "Midlane Roaming Meta", "changes": ["Carry power -2", "Mid power +3", "Rush strategy +2"]},
    {"version": "1.2", "name": "Tank Durability Update", "changes": ["Tank power +4", "Aim stats -1", "Scale strategy +3"]},
    {"version": "1.3", "name": "Speed & Vision Patch", "changes": ["Roamer power +3", "Reaction power +2", "Split strategy +3"]}
]
with open(os.path.join(DATA_DIR, "patches.json"), "w", encoding="utf-8") as f:
    json.dump(patches, f, indent=2)

# 8. staff.json
staff = [
    {"id": "coach", "name": "Head Coach", "levels": [{"level": 1, "salary": 2500, "train_bonus": 0.06}, {"level": 2, "salary": 5000, "train_bonus": 0.12}]},
    {"id": "analyst", "name": "Analyst", "levels": [{"level": 1, "salary": 2000, "scout_acc": 0.40, "prep_power": 0.5}, {"level": 2, "salary": 4500, "scout_acc": 0.55, "prep_power": 1.0}]},
    {"id": "cook", "name": "Cook (Kusinero)", "levels": [{"level": 1, "salary": 1800, "fatigue_rec": 0.08, "morale_meal": 3}]}
]
with open(os.path.join(DATA_DIR, "staff.json"), "w", encoding="utf-8") as f:
    json.dump(staff, f, indent=2)

# 9. sponsors.json
sponsors = [
    {"id": "lakas_telecom", "name": "Lakas Telecom", "tier": 1, "weekly_pay": 4500, "bonus_pay": 10000, "min_fame": 50, "goal": "Win 3 official matches", "contract_weeks": 12},
    {"id": "voltedge", "name": "VoltEdge Peripherals", "tier": 1, "weekly_pay": 3500, "bonus_pay": 8000, "min_fame": 30, "goal": "Gain 200 fans", "contract_weeks": 12},
    {"id": "mang_bertos", "name": "Mang Berto's Silog", "tier": 1, "weekly_pay": 2000, "bonus_pay": 5000, "min_fame": 0, "goal": "Reach Top 4 in any tournament", "contract_weeks": 12}
]
with open(os.path.join(DATA_DIR, "sponsors.json"), "w", encoding="utf-8") as f:
    json.dump(sponsors, f, indent=2)

# 10. achievements.json
achievements = [
    {"id": "first_win", "title": "Unang Panalo!", "desc": "Manalo sa iyong pinakaunang opisyal na laban.", "reward_money": 2000, "reward_fame": 10},
    {"id": "gaming_house_1", "name": "Upgrade: Apartment", "desc": "Lumipat sa Apartment house.", "reward_fame": 50},
    {"id": "fan_base_500", "title": "500 Fans", "desc": "Makaipon ng 500 loyal fans.", "reward_money": 5000}
]
with open(os.path.join(DATA_DIR, "achievements.json"), "w", encoding="utf-8") as f:
    json.dump(achievements, f, indent=2)

# 11. strings_taglish.json
strings = {
    "news_ticker": [
        "Bagong tournament season binuksan na sa Maynila!",
        "Lakas Telecom nag-alok ng bagong sponsorship packages para sa grassroots teams.",
        "Grabe ang laban kagabi sa Internet Cafe Cup, dikit hanggang Game 3!",
        "Kuya Kuryente nagbabala ng posibleng brownout dahil sa paparating na bagyo.",
        "Viral ngayon ang 1v5 clutch ng isang bagitong carry sa ranked match!",
        "Sari-sari store sa kanto nagpalagay ng esports banner para suportahan ang lokal na koponan.",
        "Team captain nahuling kumakain ng silog habang nag-scrim! Full morale boost!",
        "Pampanga naghahanap ng bagong esports talents para sa darating na Provincial Championship."
    ],
    "mika_dialogues": {
        "welcome": "Mabuhay Boss! Ako si Manang Mika, ang assistant manager mo. Handa na ba ang gaming house natin?",
        "month_report": "Eto na ang buwanang ulat Boss! Maganda ang takbo ng ating pondo at fans.",
        "match_day": "Boss, laban na natin ngayon! Ihanda ang lineup at pumili ng magandang estratehiya."
    }
}
with open(os.path.join(DATA_DIR, "strings_taglish.json"), "w", encoding="utf-8") as f:
    json.dump(strings, f, indent=2)

print("All 11 data files generated successfully!")
