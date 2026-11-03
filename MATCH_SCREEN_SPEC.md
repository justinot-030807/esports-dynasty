# MATCH SCREEN SPEC (broadcast screen, GAME_DESIGN section 18)

Scope: the match broadcast screen only. It is a presentation layer: it DISPLAYS events from the existing match simulation and never changes who wins or any balance. If the simulation gives too few events, add cosmetic events derived from the same result. Keep the project compiling, touch no unrelated systems, and keep every number and timing in assets/data/match_presentation.json. Use my existing sprites and fall back to simple placeholders for anything missing. Build the arena with Flame (or CustomPaint) so it reuses the character animation system; text and buttons are Flutter widgets so they stay crisp.

## PART A - Readability, layout, cards, commentary

A1. Text rules (hard)
- Sizes in dp: scoreboard numbers 32, team names 16 bold, kill banners 22 to 28, current commentary line 16, history lines 14, nameplates 13, anything else 12 minimum. Nothing below 12.
- Light text with a 1 to 2 px dark navy outline or shadow over art, contrast at least 4.5:1, no thin grey text. Whole-number sizes only, bundled pixel font.
- Touch targets at least 48x48 dp. Create lib/ui/text_styles.dart with named styles and use them here. Report (do not fix yet) the other screens that still use text below 12 dp.

A2. Look
- Drop the dark neon dashboard. Use the game's blue-and-white pixel windows (ui/panel, ribbon, bubble, row_frame, buttons) and the palette from GAME_DESIGN section 3.

A3. Layout, portrait, top to bottom
- Scoreboard (12 percent): event and round on one line (12 dp, ellipsis), emblem + team name left and right, big kill score in the center with a KILLS label and the game timer, Bo3/Bo5 series pips as large gold stars, small tappable chips for patch and tactic.
- Arena (50 percent): stage background by tier (backgrounds/match_stage_community for T1-T2, match_stage_arena for T3-T6, match_stage_world for T7 and the T6 final; gradient and vignette fallback). Rival team seated in a row at the top, my team in a row at the bottom, each a chibi at a desk, at least 48 dp wide (use characters/match/seated_* if present, otherwise the character's sit or front_idle sprite on a desk sprite). Between the rows is the CLASH LANE (about 20 percent of the arena) for fight effects and the momentum bar.
- Momentum bar in the clash lane: tug-of-war bar in team colors, 14 dp tall, with a glowing marker that eases toward the team that is ahead, and the win chance as a number (14 dp). Show a MOMENTUM SHIFT banner when it swings 25 percent or more.
- Casters strip (14 percent): two chibi casters (characters/caster_* if present, otherwise colored placeholder portraits) and a speech bubble with the current commentary line (16 dp) typing out at 30 ms per character (tap to finish), plus the last 3 lines as history (14 dp).
- Control bar (10 percent): 1x, 2x, pause, Skip, and one big TIMEOUT button (at least 56 dp tall) with the remaining count, using the ui_kit button sprites.
- Ambient life, no dead air: crowd sways, spotlights sweep, monitors flicker, and at least one visible change every 2 seconds (an emote, a caster line, a crowd wave).

A4. Player cards (10)
- Name (13 dp), role icon (icons/role_*), condition face, a thick 8 dp FOCUS bar (blue) and a TILT bar (orange to red as it rises) with small icons instead of the text "PRESSURE / TILT".
- Use real names: rivals come from the rival team data, mine from my roster. Roles are only Carry, Mid, Roamer, Tank, Support (replace "Offlane" and "Roam"). No placeholders like "Player 2".
- States: idle (breathing and typing bob), attacking (lean forward and a glow outline in team color), hit (white flash 80 ms and a shake), dead (grey, slumped, skull icon and a respawn timer), hot streak (gold aura and a star after 3 kills), tilted (steam puff emote and a red tint). Emote bubbles above heads, at most 3 visible at once.

A5. Commentary engine
- assets/data/commentary.json with Taglish templates, at least 12 variants per event type (kill, multi-kill, clutch, comeback, throw, teamfight, momentum, start, end, tilt, perfect focus), using real names (never "Opponent Ace"). Tone examples: "Grabe! Pinabagsak ni {killer} si {victim}!", "Hala, {victim} nahuli sa gitna!", "Walang awa si {killer}, {n} kills na!", "Clutch ni {name}! Sabi ko na eh!". Never repeat a template within the last 8 lines.
- Two casters alternate (hype caster and analyst); the speaker's portrait does a talking animation (mouth open and closed at 6 fps) while the text types.

A6. Debug Menu: "Quick Match" starts a test match instantly with my current roster.

## PART B - Juice, Focus Meter, intro and outro, audio

B1. Events (every important event gets motion, sound and a number)
- Kill: a beam or projectile streak from the killer's desk to the victim (0.25 s), a hit spark and white flash on the victim, the victim slumps, a floating "+1" and the kill score pops (scale 1.0 to 1.4 and back with a team color flash), a banner slides in ("KIDLAT eliminated ACE", both names, 22 dp, 1.2 s), and a kill feed entry (3 max, with sprites).
- Multi-kill (2 within 5 s, 3, 5): bigger banners (DOUBLE KILL, TRIPLE KILL, ACE), screen shake of 2, 3 and 6 px for 150 to 300 ms, a hit-stop of 60 ms, and confetti for ACE.
- Team fights (about 40 and 85 percent of the game): crossed swords and shockwaves fill the clash lane, both rows shake, a camera zoom pulse of 1.05, music intensity up, and the Focus Meter appears (B2).
- Game won: slow motion 0.4x for 1 s with a zoom to 1.1x on the winning kill. Game lost: the screen desaturates. Series won: confetti, cheer frames for my team and a trophy popup.
- The timer turns red and pulses in the last 2 minutes, pips fill with a pop animation, and the crowd bounces and waves lightsticks (cheer for my kills, groan for theirs).
- Particles are pooled and capped at 150. Use sprites from assets/images/effects/ (banner_*, fx_*, icon_skull, badge_vs) if present, otherwise simple procedural shapes in the game palette.

B2. Focus Meter (Coach Mode only)
- At the two key moments of each game, a horizontal bar appears at the bottom of the clash lane (full width minus 24 dp, 28 dp tall) with a marker sweeping back and forth. Perfect zone gold (14 percent plus the captain's Mental bonus), Good zone green (30 percent), the rest red. A full-width pulsing TAP button, 64 dp tall, stops the marker.
- Result: PERFECT (gold, confetti, shake, HapticFeedback.mediumImpact), GOOD (green), MISS (grey). Auto mode skips the meter and shows a small "AUTO +1" tag. The match clock runs at 0.25x while the meter is active so it stays fair at 2x speed.

B3. Intro and outro
- Intro (2 s, tap to skip): a GAME N banner, both emblems slide in from the sides with names, then a 3-2-1-FIGHT countdown.
- Outro: a VICTORY or DEFEAT stamp, winners cheer and losers slump, the game MVP highlighted with a gold circle, then the existing result screen.

B4. Audio hooks (a missing file is a silent no-op)
- sfx_kill, sfx_multikill, sfx_clash, sfx_focus_perfect, sfx_focus_good, sfx_focus_miss, sfx_victory, sfx_defeat, sfx_crowd_cheer, sfx_crowd_groan, sfx_countdown, sfx_whistle (plus the existing sfx_tap, sfx_confirm, sfx_hit). bgm_match for normal games and bgm_finals for semifinals and finals, slightly louder during team fights.

B5. Performance and testing
- 60 fps on a low-end phone: reuse sprites, no per-frame allocations, pause animations when the app is in the background.
- Debug Menu "Match Presentation Test": replays a scripted sequence (kill, double kill, ace, team fight with the Focus Meter, momentum shift, game win) without playing a real match.