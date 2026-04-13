#!/usr/bin/env python3
import glob, os, re, subprocess, sys

total_blocks = 0
total_failures = 0

for md_path in sorted(glob.glob('*.md')):
    stem = md_path[:-3]
    setup_path = f'{stem}-setup.html'
    if not os.path.exists(setup_path):
        continue

    with open(setup_path) as f:
        html = f.read()

    setups = {}
    for m in re.finditer(r'<script id="([^"]+)" type="text/plain">\n(.*?)\n</script>', html, re.DOTALL):
        setups[m.group(1)] = m.group(2)

    with open(md_path) as f:
        md = f.read()

    blocks = list(re.finditer(r'```\{\.sql \.run template="#([^"]+)"\}\n(.*?)\n```', md, re.DOTALL))

    failures = 0
    for i, m in enumerate(blocks, 1):
        tid, sql = m.group(1), m.group(2)
        expect_error = 'AVG(age) > 10' in sql
        setup = setups.get(tid, '##CODE##')
        full_sql = setup.replace('##CODE##', sql)
        r = subprocess.run(['sqlite3'], input=full_sql, capture_output=True, text=True)
        failed = r.returncode != 0

        if failed and expect_error:
            print(f'[XFAIL] {stem} block {i:2d}  {tid}')
        elif not failed:
            print(f'[  OK ] {stem} block {i:2d}  {tid}')
        else:
            failures += 1
            label = sql.splitlines()[0].strip()
            print(f'[ FAIL] {stem} block {i:2d}  {tid}')
            print(f'        {label}')
            print(f'        {r.stderr.strip()}')

    total_blocks += len(blocks)
    total_failures += failures

print(f'\n{total_blocks - total_failures}/{total_blocks} passed')
sys.exit(1 if total_failures else 0)
