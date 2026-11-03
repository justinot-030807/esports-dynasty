import json

with open('assets/data/tournaments.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for t in data:
    start = t.get('startWeek', 0)
    end = t.get('endWeek', 0)
    reg = t.get('regWeek', 0)
    fmt = t.get('format')
    div = t.get('division')
    tid = t.get('id')
    name = t.get('name')
    if (start <= 36 and end >= 33) or (reg >= 32 and reg <= 36):
        print(f"{tid} ({name}): reg={reg}, start={start}, end={end}, fmt={fmt}, div={div}")
