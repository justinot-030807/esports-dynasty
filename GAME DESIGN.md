GAME_DESIGN.md - PART A of B (paste Part B directly below, in the same file)

ESPORTS DYNASTY (working title)
Portrait Android management sim built with Flutter + Flame. Offline, no ads. You own an e-sports
team in the Philippines and grow it from a rented room to World Champions within 10 years.
Inspired by the pocket management sim genre (Game Dev Story, Boxing Gym Story): cute pixel chibi
characters, a living base, weekly planning, tournaments, big satisfying numbers.
Original IP only: fictional games, teams, sponsors and names. Never copy another game's art or text.
No emojis in the game UI. Currency is the Philippine peso: show the peso sign if the font supports it,
otherwise the letter P. This file writes amounts with P.

=== 0. RULES FOR THE AI AGENT ===
- This file is the single source of truth. Read ALL of it (Part A and Part B) before writing code.
  Also read docs/PROGRESS.md and docs/DECISIONS.md if they exist.
- Work phase by phase (see PHASES at the end of Part B). Do ONLY the phase I ask for, then STOP and
  report: what you built, how to run it, a test checklist, known issues, what the next phase does.
- Update docs/PROGRESS.md after every phase so any developer or AI tool can continue from it.
- Ask me only if truly blocked. Otherwise choose a sensible default and log it in docs/DECISIONS.md.
- The project must compile (dart analyze clean) and run on Android at the end of every phase.
- Nothing tunable is hard-coded. Numbers, prices, events, tournaments, patches and text live in JSON
  files under assets/data/ and load through typed Dart classes.
- My laptop is low-spec (about 4 GB RAM): no build_runner or code generation, hand-written
  toJson/fromJson, files under about 400 lines, few dependencies, memory limits in
  android/gradle.properties. Give me a fast debug build command and a release APK command.
- Add a hidden Debug Menu (tap the logo 7 times): skip week, add money, add fame, unlock all tiers,
  unlock all furniture, force an event, jump to next match day, run a headless 10-year simulation.

=== 1. PILLARS ===
1. A living, cozy gaming house full of chibi characters.
2. The "one more week" loop: every week brings a result, a reward or something to look forward to.
3. Numbers that matter: stats, chemistry, patches, strategies, furniture combos.
4. The climb: 7 tournament tiers, from an internet cafe cup to the World Championship.
5. Pinoy flavor: brownouts, typhoons, fiestas, sari-sari store sponsors, Taglish jokes.

=== 2. THE POCKET-SIM FEEL (every screen must follow this) ===
- The main screen IS the house. Characters walk, sit at PCs, eat, sleep and cheer. Time keeps
  flowing except during popups.
- Everything is bars, stars, icons and numbers. Floating "+P1,200" and "+15 Fans" text rises from
  the source of the gain and fades.
- Assistant character Manang Mika (assistant manager) appears in popups with a speech bubble for
  tips, warnings and event choices.
- Constant small rewards: promotion fanfares, "NEW!" tags, sparkles on stars, count-up numbers.
- Unlock ladder: furniture, staff, sponsors, tournaments and house sizes unlock by Fame
  milestones. The shop always shows the next unlocks with a lock icon and the requirement.
- COMBO bonuses with a visible flourish: role pairs, trait pairs, furniture adjacency, staff.
- Yearly rhythm: patch days, transfer windows, tournaments, Awards Night, annual report with graphs.
- Short sessions: autosave every week; 5 to 10 minutes of play advances 1 to 2 months.
- Funny Taglish text everywhere: news ticker, popups, match commentary.
- Pixel-perfect look (Style Bible below). No smooth vector art for characters or furniture.

=== 3. STYLE BIBLE AND SCREEN LAYOUT ===
Rendering
- Logical canvas 360x640 portrait, scaled by integer factors only, letterboxed if needed.
- FilterQuality.none everywhere. Tile 32x32. Characters about 32x48, depth-sorted by y.
- Thick dark navy outlines (#1B2A49), bright flat colors, soft oval shadow under characters.
Colors
- Positive #3DBE5A, negative #E5484D, money gold #F5B700, fame purple #9B5DE5, fans pink #FF6FA5,
  energy blue #3FA7FF, text navy #1B2A49 on light panels.
UI
- Every window uses my ui/panel as a nine-patch with a title ribbon. Rows are 48 px high. Buttons use
  my button sprites, minimum 44x44 dp, with pressed (squish 4 px) and disabled (desaturated) states.
  List rows show a chibi face, name, role icon and mini stat bars.
- Stat bars: 6 px pixel bars with 1 px outline, colored by value: 0-29 grey, 30-49 green, 50-69 blue,
  70-84 yellow, 85+ orange with sparkle. Stars are gold pixel stars with half stars.
- Font: bundle an OFL pixel font (Pixelify Sans or Silkscreen) in assets/fonts with its license.
  Numbers use thousand separators; big values shorten to 12.5K, 3.2M.
Motion
- Windows pop in (scale 0.85 to 1.0 with small overshoot, 140 ms). Numbers count up. Buttons squish.
  Screen shake on big hits, confetti on titles, day/night tint cycle during the week.
Main hub layout (portrait)
- Top bar: team name, date "Y1 M2 W3", speed buttons (pause, 1x, 2x, 4x). Second row: Money, Fame,
  Fans with my icons. Below: scrolling news ticker.
- Middle: the house scene (drag to pan, pinch to zoom in integer steps).
- A floating "Next match" banner appears when a series is within 2 weeks.
- Bottom nav: Team, Plan, Compete, Build, More (Finance, Sponsors, Staff, Rankings, Hall of Fame,
  Achievements, Settings).
Audio
- AudioManager with named events: tap, confirm, cancel, coin, promotion, win, lose, popup, hit,
  week_tick, bgm_title, bgm_house, bgm_match, bgm_finals. Use CC0 chiptune placeholders if available,
  otherwise silent no-ops. Credits in CREDITS.md. Settings toggles for music and sound effects.

=== 4. ASSETS AND ANIMATION ===
My finished art is in raw_assets/ (original names, some with typos or spaces). Open and LOOK at every
image to confirm what it is, then organize into assets/images/ with clean snake_case names:
- "male idle", "male foot left", "male foot right" -> characters/gamer_m01/gamer_m01_front_idle,
  _front_step1 (left foot forward), _front_step2 (right foot forward)
- "app icon", "app logo", "splash screen" -> branding/app_icon, logo, splash
- "UI panel" -> ui/panel (nine-patch). "buttons crappoble" (sheet: green OK, red Cancel, yellow)
  -> ui/btn_*
- "icons croppable" (3x3 sheet: money, fans, fame, trophy, calendar, energy, mood, training, stream)
  -> icons/icon_*
- "banners croppable" (5 banners, expected order: Internet Cafe Cup, Town League, Provincial
  Championship, National Pro League, World Championship; verify by looking) -> banners/banner_t1,
  t2, t3, t5, t7. For T4 and T6 make tinted copies of neighboring banners with a procedural label
  until real art exists.
- "FLOOR" (plain background, floor tile plus wall section with poster and window) -> house/floor_tile,
  house/wall_section
- "PC SETUP" -> furniture/pc_desk (and furniture/gaming_chair if a chair is included).
  "bunk bed", "kitchen", "shelve thropy" -> furniture/bunk_bed, kitchen, trophy_shelf
Tooling (Python + Pillow, or Dart with the image package if Python is unavailable):
(1) make the magenta background (#FF00FF, with tolerance) transparent and remove 1 px of magenta
fringe, skipping images that are already transparent; (2) slice sheets by detecting connected
components (dilate slightly so detached parts stay together), order them in reading order, name them
from a mapping list, and if the detected count differs from expected, STOP and print a report with a
debug image of numbered boxes instead of guessing; (3) trim, scale only with nearest-neighbor, and
pad characters onto one square canvas anchored bottom-center. Show me a contact sheet.
Create assets_manifest.json (logical id -> file, frame data) so art can be swapped without code
changes, and ASSET_LIST.md listing every needed asset as HAVE or MISSING.
Missing art (use fallbacks, log a warning, never crash): female characters, staff characters, side
and back walk frames, activity sprites, emote bubbles, other furniture and decor.
- More characters: generate variants of gamer_m01 at load time by recoloring only the jersey (blue
  range), hair (dark range) and a few skin tones. Never a global hue shift. Cache the textures.
- Side and back directions: use front frames, flip horizontally when moving left or right, add a
  slight lean toward the movement direction.
- Missing activity sprite: idle sprite plus a code effect and an emote shape (Zzz, sweat drop,
  sparkle, heart).
- Team emblems for 70+ teams: procedurally drawn flat pixel shields (2 team colors, a symbol, 1-2
  letters). Procedural is allowed for emblems and effects only.
- Anything else missing: labeled colored placeholder box.
Naming convention for future art: {characterId}_{front|back|side}_{idle|step1|step2}.png,
{characterId}_{activity}_{frame}.png, {characterId}_sit.png.
Animation
- Walk cycle: step1, idle, step2, idle at about 8 fps total, 1-2 px bounce per step, anchor
  bottom-center so feet never jitter.
- Idle breathing: sine wave, scaleY 1.00 to 1.03 and scaleX 1.00 to 0.99, one cycle about 2.8 s,
  random phase and plus or minus 10 percent speed per character. Slower and deeper when fatigue is
  high, slightly faster when morale is high. Breathing only while idle; blend smoothly between
  states. Constants in one file.
- Activities (train, sleep, win, lose, tired, eat, stream, play_pc): the character walks to the
  matching station, plays the activity, then returns. Code effects: floating Zzz, sweat drops,
  sparkles and confetti, a pulsing LIVE dot, keystroke bob.
- Must stay smooth with 30+ characters on a low-end phone (cap pathfinding work per frame).

=== 5. TIME AND LOOP ===
- 1 year = 12 months x 4 weeks = 48 weeks. Date shows "Y1 M2 W3". The run lasts 10 years (480 weeks),
  then Final Evaluation, then Endless mode.
- Each week has 7 day pips. Official series are played on Day 5. Showmatches on Day 7. Days 1-4 are
  practice.
- Pace at 1x: about 8 seconds per week (2x = 4 s, 4x = 2 s, plus Pause). Characters act out the plan
  in real time with a day/night tint.
- The game repeats last week's plan automatically and pauses only when something needs me: match day,
  event popup, registration opening or closing soon, contract expiry, patch notes, monthly report,
  new unlock.
- End of week: apply training, fatigue and morale; pay income and expenses; advance the AI world; add
  news items; autosave.
- End of month: monthly report window (income, expenses, profit, fans, fame) with one tip from Mika.
- End of year (W48): annual report with graphs, Awards Night, contract expiry, Legacy points.

=== 6. WEEKLY PLAN ===
- Team focus (choose 1): Balanced, Scrim Block, VOD Review, Bootcamp (big gains, big fatigue), Rest
  Week, Stream Marathon (income and fans, morale cost).
- Per player (choose 1): Train [stat], Scrim, Study Role, Stream, Solo Queue, Rest, Free Time.
- The Plan screen shows each player as a card with predicted gains, fatigue after the week and
  warnings. Buttons: Auto Plan (AI picks by needs and the next match), Repeat Last Week.
- Station rules: each activity needs a matching station (PC desk, streaming booth, bed, kitchen, gym,
  meeting table). If none is free, effectiveness is -30% and the character visibly queues.
- Training gain per week = 2.0 x coach x desk x trait x (0.5 + 0.5 x (1 - stat/cap)) x condition,
  keep fractions as carry. Fatigue per week: train +12, scrim +8, stream +5, rest -25, free time -10.
- Condition faces from fatigue and morale: Great, Good, Normal, Tired (fatigue 60+), Exhausted (85+).

=== 7. PLAYERS ===
Game: "Arena Clash" (fictional 5v5 team game). Stats 0-100: Aim, Reaction, Game Sense, Teamwork,
Mental, Stamina. Roles and OVR weights in percent:
 Carry:   Aim 30, Reaction 25, Game Sense 15, Mental 15, Stamina 10, Teamwork 5
 Mid:     Game Sense 30, Aim 20, Reaction 15, Mental 15, Teamwork 10, Stamina 10
 Roamer:  Game Sense 25, Teamwork 25, Reaction 20, Mental 10, Aim 10, Stamina 10
 Tank:    Mental 25, Stamina 20, Teamwork 20, Reaction 15, Game Sense 10, Aim 10
 Support: Teamwork 30, Game Sense 25, Mental 15, Reaction 10, Stamina 10, Aim 10
- OVR = weighted sum for the player's role. Rank titles: Rookie 0-34, Amateur 35-49, Semi-Pro 50-64,
  Pro 65-79, Star 80-91, Legend 92+. A rank-up triggers a "PROMOTION!" fanfare.
- Potential 1-5 stars caps stats at 55, 68, 80, 91, 99 (+8 for the role's top 2 stats). Shown as "?"
  until scouted; Analyst and scouting reveal it gradually.
- Role Mastery 0-100 per role grows through scrims and Study Role. Off-role costs -10% at mastery 0,
  0% at 50+.
- Traits (1-2 per player): Clutch (Focus zone +15%, +3 power when behind), Tilt-prone (-4 power after
  a loss unless Psychologist lv2+), Team Player (+chemistry), Lone Wolf (+3 power, slower chemistry),
  Workaholic (+20% training, +20% fatigue), Lazy Genius (-20% training, starts with high Reaction),
  Stream Natural (+40% stream income), Fan Favorite (+25% fans from wins), Homesick (-1 morale per
  week unless Comfort 4+), Veteran Leader (captain bonus doubled, +10% training for rookies), Prodigy
  (+1 hidden potential star, grows faster until 20), Big Game Player (Mental +30% in finals), Penny
  Wise (-15% salary demand).
- Age 16-30. Under 20 trains +20% faster. From 27, Aim and Reaction slowly decline. Retirement at
  29-33 with a ceremony. Retired Legends enter the Hall of Fame and can be hired as Coach or Analyst
  with a bonus.
- Chemistry 0-100: +25 if all 5 roles are covered, +1 per 4 weeks together (max +25), duo synergies
  up to +20 (pairs grow through scrims, show hearts), captain with Veteran Leader +10, Comfort up to
  +10, lounge and kitchen combos. Team power bonus = Chemistry/100 x 6.
- Morale 0-100 moves with results, rest, Comfort, Cook, overwork and events. Below 25 for 4 weeks, a
  player may ask to leave.
- Contracts: weekly salary, 24/48/96 weeks. A renewal popup appears 8 weeks before expiry (raise
  demand by OVR and morale). Release costs 8 weeks of salary.
- Starting roster: 3 rookies (OVR 30-40). The tutorial gets me to 5 players by W3.

=== 8. RECRUITMENT AND TRANSFERS ===
1. Scouting board: 6 free agents, refreshes weekly, quality grows with Fame and the Manager.
2. Open Tryouts (every 4th week from W3): pay to see 10 candidates with hidden potential.
3. Trial: sign a candidate for 2 weeks to reveal true potential before the contract.
4. Transfer market: poach players from AI teams during windows (W1-W2, W25-W26). Fee = weekly salary
   x 20 x rank factor. Rivals can poach mine too.
5. Academy (unlocks with Pro Gaming House): produces a prospect every 12 weeks.
6. Campus Clash scholarship: the T1 school event reveals 3 young prospects.
Roster cap by house tier: 6, 8, 10, 12, 15. Five start, the rest are subs. Swap before any match.

=== 9. STAFF ===
Hire from a job board (level 1-5, 2 specialties, weekly salary). Staff visibly work at stations.
- Head Coach: training gains +6% per level; unlocks Strategy Library tiers.
- Analyst: opponent scouting accuracy 40/55/70/80/90%; match prep +0.5 power per level.
- Manager: sponsor pay +8% per level; transfer fees -4% per level.
- Psychologist: morale recovery +10% per level; fewer tilt and burnout events.
- Cook (Kusinero): fatigue recovery +8% per level; meals give morale.
- Stream Producer: stream income +10% per level; fans +5% per level.
Staff slots by house tier: 1, 2, 3, 5, 6. Staff level up with money and time.

=== 10. GAMING HOUSE AND BUILD MODE ===
Orthogonal grid, 3/4 view sprites. Tiers (cost, Fame required):
 Rented Room 8x6 (start) | Apartment 12x8 (P80,000, Fame 100) | Small House 16x10 (P400,000, Fame 500)
 | Pro Gaming House 20x14 (P3,000,000, Fame 2,500) | Esports Arena HQ 24x16 (P20,000,000, Fame 9,000).
 An upgrade takes 1 week of visible construction.
Start: 3 PC desks, 2 bunk beds, 1 kitchen, 1 trophy shelf, P50,000, 50 Fans, Fame 0.
Catalog (size, price, effect). Use my art for desk, bunk bed, kitchen, trophy shelf and floor; the
rest are placeholders until art exists:
 Gaming PC Desk 2x1, P6,000: 1 station, training x1.0. Pro Desk P30,000 (Fame 150) x1.25. Elite Desk
  P150,000 (Fame 800) x1.5 (recolor plus star overlay).
 Gaming Chair 1x1, P2,500: -10% fatigue gain. Ergo Chair P12,000: -20%.
 Bunk Bed 2x1, P8,000: sleeps 2, recovers 25 fatigue per week. Comfy Bed P20,000: sleeps 1, x1.5.
 Kitchen 2x2, P10,000: meals give +4 morale per week; enables the Cook. Dining Table 2x1, P3,000:
  next to the kitchen gives COMBO "Kainan" +3 morale.
 Trophy Shelf 2x1, P5,000: holds 6 trophies, +1 Fame per week per 2 trophies, Style +2.
 Streaming Booth 2x2, P25,000 (Fame 100): enables Stream, 2 streamers at once.
 Gym Corner 2x2, P15,000: Stamina and Mental training x1.25.
 Lounge Sofa and TV 2x1, P7,000: +3 morale and +1 chemistry per week for users.
 Meeting Table and Whiteboard 2x1, P9,000: VOD Review and Study Role x1.3; the Analyst works here.
 Merch Corner 2x1, P18,000 (Fame 300): passive income Fans x 0.03 per week.
 Generator 1x1, P40,000: prevents brownout events. Fiber Router (wall) P25,000: removes online lag.
 Aircon (wall) P12,000: -5% fatigue house-wide, higher electricity bill.
 Decor: Plant P500 (+1 Style), Poster P800 (+1), Neon Sign P6,000 (+3), Team Banner P3,000 (+2),
  Parol P1,500 (+3, December only).
COMBO: 5 or more PC desks in one room = "Scrim Room" (scrim gains +15%, chemistry +1 per week).
Comfort rating 1-5 stars from Style, beds, lounge and aircon relative to house size. Comfort sets
baseline morale and sponsor attraction.
Build mode: drag to place, tap to rotate or flip, green/red ghost preview, sell for 70%, "NEW!" tag
on newly unlocked items.

=== 11. ECONOMY AND SPONSORS ===
- Income: prizes, sponsors (weekly), streaming (per streamer P150 + Fans x 0.08 per week, times
  traits, Producer and booth), merch, fan meets. Expenses: salaries and staff (weekly), rent and
  electricity (monthly), entry fees and travel, scouting, bootcamps, upgrades.
- Salary per player per week by rank: Rookie P400, Amateur P900, Semi-Pro P2,500, Pro P7,000,
  Star P20,000, Legend P60,000. Monthly rent by house tier: P2,000, P8,000, P30,000, P150,000, P800,000.
- Bankruptcy: money below 0 for 4 weeks triggers a final warning with options (sell furniture, accept
  a bailout sponsor with strict goals, sell a player). If it still fails: Game Over with Retry from
  the last autosave.
- Sponsors: offers appear every 4 weeks when a slot is free. Slots = 1 + floor(Fame/800), max 6.
  Contracts of 12/24/48 weeks: weekly pay plus bonus for goals ("reach quarterfinals in Town League",
  "gain 500 fans", "win 10 matches"). Failing goals costs a penalty or Fame.
- Fictional sponsors (add more): Lakas Telecom, VoltEdge Peripherals, Mang Berto's Silog, KapeKo
  Coffee, ByteBurger, Bayanihan Bank, Gising Energy Drink, TindaNet Load, Sulit Mobile Shop,
  PixelPinoy Games, SkyLink Fiber, Kuya Kuryente Power (lowers the electricity bill).
- Difficulty at New Game: Easy (income x1.25, AI -5%), Normal, Hard (income x0.8, AI +10%).

=== 12. EVENTS, PATCHES, TUTORIAL ===
Random events (events.json, at least 40, weighted, with cooldowns and conditions on Fame, month and
flags). Each has id, category, text, 2-3 choices, outcomes (money, fame, fans, morale, fatigue,
chemistry, stat, trait, flag) and optional follow-up chains. Categories: Player life, Team,
Business, House, Competition, Community. Include: Brownout (if no Generator), Typhoon (W25-W40, a
tournament round is postponed, house leak), Viral clip, Toxic chat controversy (apologize / ignore /
clap back), Rival poaching, Scam sponsor, Match-fixing bribe (accept = money plus big scandal risk,
refuse = Fame and morale), Burnout, Homesick, Fan meetup, School visit, Charity event, PC breakdown,
Rival trash talk, Coach conflict, Streamer collab, Leaked patch notes.
Patches: every 12 weeks (W1, W13, W25, W37) a Patch popup lists 3 changes (buff or nerf for roles or
strategies, +/-3 power). patches.json has 16 patches, then random generation. The Analyst warns 1 week
early.
Tutorial: Manang Mika guides W1-W4 (recruit up to 5 players, place a desk, set a plan, register for
the first cup, play the first match). Skippable. Later, contextual "NEW!" hints.

=== 13. WORLD, AWARDS, ENDING ===
- 8 flagship rival teams with named chibi captains and catchphrases recur across tiers. Rival
  showdown popups trigger before facing them.
- Awards Night (W48 Day 7): Team of the Year, Player MVP, Rookie of the Year, Streamer of the Year,
  Best Fan Base, Play of the Year. Winners get Fame, trophies and items. Cutscene with confetti.
- Hall of Fame: World Champions by year, MVPs, retired Legends (my retired players keep their stats).
- Achievements: 50 badges with small rewards.
- Ending: after Year 10, a Final Evaluation score from titles, trophies, Fame, Fans, revenue and
  Legends developed. Ranks: Garage Owner, Local Hero, Provincial Pride, National Treasure, Asia's
  Finest, World Dynasty. Then Endless mode.
- Legacy (New Game+): Legacy points unlock more starting money, extra furniture, new emblems and a
  Legend coach start.
  GAME_DESIGN.md - PART B of B (COMPETITION, TECH, PHASES)

=== 14. COMPETITION OVERVIEW ===
7 tiers: T1 Community, T2 Town, T3 Provincial, T4 Regional, T5 National Pro League, T6 Asia Pacific
Masters, T7 World Championship. Team Level = highest tier whose min Fame the team has reached.
Tier defaults (events can override):
 T1: Fame 0-499        | entry P500     | travel P0         | champion P10,000     | Fame +50    | Fans +300     | circuit x1
 T2: Fame 100-1,499    | entry P1,500   | travel P0         | champion P60,000     | Fame +150   | Fans +1,500   | circuit x3
 T3: Fame 400-3,999    | entry P8,000   | travel P10,000    | champion P250,000    | Fame +400   | Fans +5,000   | circuit x10
 T4: Fame 1,200-7,999  | entry P30,000  | travel P40,000    | champion P800,000    | Fame +900   | Fans +15,000  | circuit x25
 T5: Fame 3,000-19,999 | entry P100,000 | travel P150,000   | champion P3,000,000  | Fame +2,200 | Fans +50,000  | circuit x60
 T6: Fame 6,000+ and qualification | entry P300,000 | travel P800,000 | champion P10,000,000 | Fame +5,000 | Fans +150,000 | circuit x150
 T7: qualification only | entry P0 | travel P3,000,000 | champion P40,000,000 | Fame +12,000 | Fans +500,000 | circuit x400
Placement rewards as a percent of the champion values: Fame and Fans 100/55/30/15/5 (champion,
runner-up, semifinalist, quarterfinalist, participant). Prize money 100/55/30/12/0. Circuit points =
100 x tier multiplier x (100/60/35/18/8/3 percent for champion, runner-up, semis, quarters, round of
16, participant). Cups pay 60% of tier values, invitationals 40%, exhibitions pay no prize, only fans.
Fame ranges stop strong teams from farming low tiers.
Registration rules: Fame range, qualification, 5 healthy starters (no Exhausted), entry plus travel
money, no schedule conflict (one official series per week). Registration opens 4 weeks before the first
match and closes 1 week before. Invite-only events notify me. Withdraw before start: 50% refund.
No-show: forfeit, Fame -20% of the event reward, sponsor warning.

=== 15. YEARLY CALENDAR (seed data, repeats every year, 48 weeks) ===
Global: Patches W1, W13, W25, W37. Transfer windows W1-W2 and W25-W26. Open Tryouts every 4th week
from W3. Contracts expire at the end of W48. Awards Night W48 Day 7. Typhoon rule: in W25-W40, each
week has a 10% chance that a LAN event round is postponed by 1 week (the engine shifts later rounds).
Specials (Day 7, do not block the weekly series but add fatigue): New Year Showmatch W4, Charity Cup
W16 (4-team exhibition, prize donated for a Fame bonus), Barangay Fiesta Showmatch W30 (Bo3 vs a local
favorite, big fans), All-Star Weekend W32 (fan vote). Shop events: Sponsor Summit W10 (extra sponsor
offers), Gadget Expo W20 (20% off furniture for 1 week).

TIER 1 - COMMUNITY
 T1-ICC1  Internet Cafe Cup: Spring | W5-W7 | single elim 8, Bo1, final Bo3 | open
 T1-CAMPUS Campus Clash (inter-school) | W9-W13 | 8 school teams, 2 groups of 4 round robin Bo1
   (W9-W11), semis Bo1 (W12), final Bo3 (W13) | open | bonus: scholarship scouting
 T1-ICC2  Internet Cafe Cup: Summer | W21-W23 | same as Spring
 T1-ICC3  Internet Cafe Cup: Autumn | W37-W40 | double elim 8, Bo1, grand final Bo3
TIER 2 - TOWN
 T2-TLS   Town League: Spring | W9-W15 | round robin 6 teams, Bo3 (5 matchdays W9-W13); top 4
   playoffs: semis Bo3 (W14), final Bo5 (W15) | open
 T2-TC    Town Cup (cup) | W25-W28 | single elim 16: R16 Bo1, QF Bo1, SF Bo3, final Bo3 | open
 T2-TLF   Town League: Fall | W33-W41 | round robin 8 teams, Bo3 (7 matchdays W33-W39); top 4
   playoffs: semis Bo3 (W40), final Bo5 (W41) | open
TIER 3 - PROVINCIAL
 T3-PQ    Provincial Qualifier | W16-W19 | single elim 16, Bo1, final Bo3 | top 2 qualify for T3-PC
 T3-PC    Provincial Championship | W29-W34 | double elim 16, Bo3, grand final Bo5 (upper finalist
   starts 1-0) | qualify: T2-TLS top 3, T3-PQ top 2, T2-TC champion, rest by circuit rank
 T3-PWC   Provincial Winter Cup (cup) | W42-W44 | single elim 8, Bo3 | invite: top 8 circuit rank
TIER 4 - REGIONAL
 T4-RQ    Regional Qualifiers | W17-W22 | 16 teams in 4 GSL groups (W17-W19); top 2 per group go to
   single elim 8: QF Bo3 (W20), SF Bo3 (W21), final Bo5 (W22) | qualify: T3-PC top 4, rest by rank
 T4-RS    Regional Showdown (cup) | W25-W28 | single elim 16, Bo3, final Bo5 | open to tier
 T4-RF    Regional Finals | W37-W41 | double elim 8, Bo3, grand final Bo5 | qualify: T4-RQ top 4,
   T4-RS top 2, rest by circuit rank
TIER 5 - NATIONAL PRO LEAGUE
 T5-NPLS  NPL Spring Split | W3-W14 | 10 teams, single round robin Bo3 (9 matchdays W3-W11); top 6
   playoffs, seeds 1-2 get byes: QF Bo3 (W12, 3v6 and 4v5), SF Bo5 (W13), final Bo5 (W14)
   | qualify: T4-RF top 2, promotion by circuit rank
 T5-NPLU  NPL Summer Split | W17-W28 | same format (RR W17-W25, QF W26, SF W27, final W28)
 T5-NC    National Cup (cup) | W33-W36 | single elim 16, Bo3, final Bo5
 T5-NF    National Finals | W41-W44 | top 8 by NPL circuit points; W41 is seeding week; single elim:
   QF Bo5 (W42), SF Bo5 (W43), final Bo5 (W44)
TIER 6 - ASIA PACIFIC MASTERS
 T6-APQ   APAC Pre-Qualifier | W25-W29 | single elim 32, Bo1, final Bo3 | top 2 qualify for T6-APM
   | min Fame 5,000
 T6-APM   APAC Masters | W33-W40 | 16 teams: Swiss stage (5 rounds, W33-W37), then top 8 single elim:
   QF Bo3 (W38), SF Bo5 (W39), final Bo5 (W40) | qualify: NPL Spring and Summer champions, T5-NF
   champion and runner-up, T6-APQ top 2, rest by circuit rank
 T6-APW   APAC Winter Invitational (invitational) | W43-W45 | single elim 8, Bo3 | invite by rank
TIER 7 - WORLD CHAMPIONSHIP
 T7-WPI   World Play-ins | W41-W42 | 8 teams single elim Bo3; both semifinal winners advance
 T7-WG    World Championship: Groups | W43-W45 | 16 teams (14 direct + 2 from play-ins), 4 groups of
   4, single round robin Bo1 (3 matchdays), top 2 advance | direct: APAC Masters champion and
   runner-up, T5-NF champion, then best world circuit rank
 T7-WP    World Championship: Playoffs | W46-W48 | single elim 8: QF Bo3 (W46), SF Bo5 (W47), final
   Bo5 (W48 Day 5), then Awards Night
Qualification always reads the MOST RECENT finished edition of the feeder event (can be last year's)
or the circuit rank. AI teams fill every empty slot.

=== 16. TOURNAMENT ENGINE ===
- Every event is a TournamentDef (tournaments.json) made of one or more stages. Stage types:
  single_elim, double_elim, round_robin, groups, gsl_group, swiss.
- Build every bracket as a GRAPH of Match nodes: id, round, week, day, slotA, slotB, bestOf, result.
  A slot is either a seed ("seed 3") or a reference ("winner of M12", "loser of M7"). The UI lays
  out nodes from this graph. No per-format UI code except tables.
- Scheduling: spread rounds across the stage's weeks so no team plays two official series in one
  week. Series are on Day 5. Postponements shift the remaining rounds.
- Seeding: by circuit rank (rolling 48 weeks), ties random. Standard order for 16: 1v16, 8v9, 4v13,
  5v12, 2v15, 7v10, 3v14, 6v11 (generate recursively for any size). If the field is not a power of
  two, top seeds get byes.
- single_elim: no third-place match; losing semifinalists share 3rd-4th.
- double_elim (8 or 16): standard upper and lower brackets; no bracket reset, the upper-bracket
  finalist starts the Bo5 grand final 1-0 ahead.
- round_robin: circle method so every team plays once per matchday (odd counts get a bye). Points: Bo1
  win = 3; Bo3 2-0 = 3/0, 2-1 = 2/1. Tiebreakers: points, head-to-head, game difference, games won,
  then a sudden-death series if it decides a playoff spot, else coin flip.
- groups: snake seeding; each group runs its own sub-format; top K advance; crossover seeding in the
  playoffs (A1 vs B2, B1 vs A2, ...).
- gsl_group (4 teams): opening matches 1v4 and 2v3; winners match; losers match; decider between the
  winners-match loser and the losers-match winner. The winners-match winner and the decider winner advance.
- swiss (16 teams): play until 3 wins (advance) or 3 losses (eliminated), max 5 rounds. Pair teams with
  the same record, top seed vs bottom seed, avoid rematches (backtrack if needed). Bo1 in rounds that do
  not decide advancement or elimination, Bo3 in the ones that do.
- AI-vs-AI series resolve when their round's week ends, with believable game scores, and are stored.
- A finished event writes: placements, prize money, Fame, Fans, circuit points, trophy for the shelf
  (champion), news headline, and a history entry for the Hall of Fame.

=== 17. BRACKET AND SCHEDULE SCREENS ===
Compete tab sub-screens:
a) Calendar: year timeline with 12 rows (months) x 4 columns (weeks). Event chips colored by tier;
   icons for patch, transfer window, awards; green dot = registration open; my registered events have
   a yellow outline; today marker. Tap a cell for details. Below it, a "Next 8 weeks" list with
   countdowns. Popups 4 weeks and 1 week before registration deadlines.
b) Tournament hub (tap an event): tabs Overview (banner, format summary, rewards, entry cost,
   requirement checklist with green/red marks, Register/Withdraw), Bracket, Schedule, Standings,
   History (past champions for up to 10 years).
c) Bracket view: pannable and pinch-zoomable tree, one column per round with round headings. Each match
   node shows 2 rows (seed, emblem, name, score). Winner bold green, loser grey, my team highlighted
   yellow, upcoming shows "W13 D5 Bo5". Pixel connector lines. Tap a node for match info (format,
   head-to-head, preview). Auto-scroll to my next match. A "Where am I?" button recenters.
   Double elim: upper bracket on top, lower below, with drop arrows. Swiss: columns by record (3-0, 2-1,
   1-2, 0-3 ...). Groups: tabs A/B/C/D.
   Sketch:
     QUARTERFINALS          SEMIFINALS           FINAL
     [1 Kidlat Esports   2]-+
     [8 Bakal Wolves     0]-+-[Kidlat Esports  2]-+
     [4 Dagat Dragons    1]-+ [YOUR TEAM       1] |
     [5 YOUR TEAM        2]-+                     +-[  ?  ]
     [2 Mayon Flames     2]-+                     | [  ?  ]
     [7 Pawikan Prime    1]-+-[Mayon Flames    ?]-+
     [3 Tarsier Tactics  0]-+ [Agila Ascend    ?]
     [6 Agila Ascend     2]-+
d) Schedule: list by week, e.g. "W14 D5  Semifinal  Kidlat vs YOU  Bo3", with status chips (Upcoming,
   LIVE, Final), filter "My matches".
e) Standings (round robin, groups, Swiss): table with W-L, game diff, points, last-5 form dots, and a
   colored line marking the qualification zone.
f) Rankings: Top 100 by circuit points with tier badges and movement arrows; my team highlighted;
   filter by tier.

=== 18. MATCH DAY, SIMULATION, TAP MECHANIC ===
Match day (Day 5): the game pauses with a banner "MATCH DAY: event, round, opponent".
Prep screen: both rosters (OVR, role icons, condition faces), head-to-head, last 5 results, opponent
 style hint (accuracy by Analyst level), lineup (5 starters + subs, warnings for Tired and Exhausted),
 strategy (Rush, Teamfight, Scale, Split), mode toggle Coach Mode or Auto. Coach Mode is on by default
 for finals, semifinals, Bo5 and rival matches. Skip is always available.
Strategy cycle: Rush beats Scale, Scale beats Split, Split beats Teamfight, Teamfight beats Rush
 (+4 power vs the countered, -4 vs the counter, mirror 0). AI teams have style weights.
Power model (OVR-equivalent units):
 PlayerPerf = RoleOVR + condition (Great +3, Good +1, Normal 0, Tired -4, Exhausted -10)
   + morale ((morale - 50) / 12.5) + off-role penalty + trait effects
   + pressure ((Mental - 50) / 10 in semifinals and finals; doubled at LAN events, T4 and above)
 TeamPower = average(PlayerPerf of the 5) + Chemistry/100 x 6 + staff (Analyst 0.5 and Coach 0.4 per
   level, max 4) + strategy counter (+/-4) + patch meta (+/-3) + Focus bonus (0 to 6)
 Game win chance p = 1 / (1 + exp(-(PowerA - PowerB) / 12)). A 10-point gap is about 70%, 20 about 84%.
 Series: play games until someone reaches the needed wins; seeded RNG per match; +1 momentum power
 after a game win.
Focus Meter (Coach Mode): 2 key moments per game (about 40% and 85% of the game). A marker sweeps
 across a bar. Perfect zone (width 14% + up to 8% from the captain's Mental) = +3 power, Good zone
 (30%) = +1.5, Miss = 0. Max +6 per game. Auto mode assumes +1.
Timeouts: 2 per series. Pep Talk (+morale next game), Adjust Strategy (change strategy for the next
 game), Substitute (swap a player).
Broadcast screen (portrait): top scoreboard (emblems, names, series score pips, game timer); center
 arena view with two rows of chibi players at gaming desks facing each other, pressure bars and small
 highlight popups; bottom Taglish commentary ticker ("Grabe ang clutch ni [player]!"); speed buttons
 1x, 2x, Skip; win animations and confetti on a series win.
Result screen: score by game with fake stats (kills, towers, duration), MVP, stat and fatigue changes,
 prize, Fame, Fans, circuit points, mini bracket showing the next opponent and date, news headline.
 Back at the house, characters play win or lose animations.

=== 19. AI WORLD AND RANKINGS ===
- 72 AI teams: 20 local (T1-T2), 16 provincial and regional (T3-T4), 12 national (T5), 24 international
  (T6-T7). Fictional names, regions, colors and emblem seeds; avoid real e-sports team names. Seed
  names: Kidlat Esports, Bakal Wolves, Dagat Dragons, Mayon Flames, Tarsier Tactics, Pawikan Prime,
  Agila Ascend, Banaue Bulls, Siargao Surge.
- Average OVR by tier: T1 25-45, T2 40-55, T3 50-62, T4 58-70, T5 66-80, T6 75-90, T7 82-96.
- Each AI team has rating, style weights (Rush, Teamfight, Scale, Split), fans, fame, circuit points,
  finances. Yearly: rating drifts with results, strong teams move up by circuit rank, prospects appear.
  8 flagship rivals have captains and catchphrases and scale with my progress.
- AI series use the same win formula from rating difference. Simulate the world only when a round ends,
  under 50 ms per week on a low-end phone. Keep 5 years of detailed history, then summaries.

=== 20. DATA FILES ===
assets/data/: balance.json, names.json (Filipino name pools), teams.json, tournaments.json, events.json,
patches.json, items.json, staff.json, sponsors.json, achievements.json, strings_taglish.json.
Example tournament entry (plain JSON, shown without code fences):
 {"id": "T3-PC", "name": "Provincial Championship", "tier": 3, "division": "arena_clash",
  "weeks": [29, 34], "registration": {"opens": -4, "closes": -1},
  "fame": {"min": 400, "max": 3999}, "entry_fee": 8000, "travel_cost": 10000, "slots": 16,
  "qualify": [{"from": "T2-TLS", "top": 3}, {"from": "T3-PQ", "top": 2}, {"from": "T2-TC", "top": 1},
              {"fill": "circuit_rank"}],
  "stages": [{"type": "double_elim", "teams": 16, "bo": 3, "grand_final_bo": 5, "gf_advantage": "upper"}],
  "rewards": {"champion_prize": 250000, "fame": 400, "fans": 5000, "circuit_points": 1000,
              "trophy": "trophy_gold_t3"},
  "reschedule": "typhoon_ok", "banner": "banner_t3"}

=== 21. TESTS ===
- Unit tests for the bracket engine: sizes 2 to 32 including byes, exactly one champion per event, no
  team plays twice in a week, Swiss never repeats a rematch, tiebreakers, double elim drop-downs.
- Save/load round trip with a version number and migration hook.
- Economy invariants (no NaN, no negative stats, fractions carried correctly).
- Headless 10-year simulation with a simple bot: must finish without crashes in under 60 seconds and
  print a balance report (money, Fame and tier reached by year). Targets on Normal: most runs reach T3 by
  Year 3, T5 by Year 6 and avoid bankruptcy if the bot plays sensibly.

=== PHASES (do one at a time, then STOP) ===
Phase 0 - Foundation: project, folder structure, JSON loaders, asset pipeline with contact sheet,
  ASSET_LIST.md, assets_manifest.json, docs/PROGRESS.md and docs/DECISIONS.md.
Phase 1 - Living House slice: splash, title, New Game (team name, color, owner name, emblem), hub screen
  with my floor, wall and furniture on the grid, characters walking and breathing, HUD, time with speed
  controls, news ticker, weekly autosave, save/load, Debug Menu.
  Done when: I can start a game, watch 3 characters walk between stations, advance weeks, save, reload.
Phase 2 - Management core: players, stats, roles, Plan screen, training, fatigue, morale, condition faces,
  staff, finance (salary, rent, monthly report), Build mode and shop with unlock ladder, scouting board
  and tryouts, tutorial W1-W4, Manang Mika popups.
Phase 3 - Competition core: Calendar, tournament engine for single_elim and round_robin, bracket,
  schedule and standings screens, registration flow, AI world with weekly sim, circuit rankings, all T1
  and T2 events, auto-sim matches with result screens and rewards.
Phase 4 - Match depth: broadcast screen, commentary, strategy cycle, Focus Meter, timeouts, substitutions,
  patch meta, rival showdowns.
Phase 5 - Full circuit: double_elim, gsl_group, groups, swiss; all T3-T7 events and qualification chains;
  typhoon postponement; Awards Night, Hall of Fame, annual report, yearly rollover, AI evolution.
Phase 6 - Depth and content: sponsors, 40+ random events, traits, contracts and transfers, retirement,
  Academy, achievements, staff leveling, Comfort and combos, difficulty modes.
Phase 7 - Balance and release: headless bot simulations and tuning of balance.json, performance pass for
  low-end phones, audio, settings, Legacy (New Game+), final release APK.
Phase 8 (stretch): Division 2 "Strike Zone" and Division 3 "Last Island" with their own rosters and
  events, reusing the same engine.
Every phase ends with: it compiles, it runs, the Debug Menu works, docs are updated.