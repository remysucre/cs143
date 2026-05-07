---
title: "HW 4: Query Execution"
---

**1.** Implement the merge operation that takes in two sorted lists
 and merges them into one sorted output.

<details>
<summary>Solution</summary>

```python
def merge(a, b):
    out = []
    i = j = 0
    while i < len(a) and j < len(b):
        if a[i] <= b[j]:
            out.append(a[i]); i += 1
        else:
            out.append(b[j]); j += 1
    out.extend(a[i:])
    out.extend(b[j:])
    return out
```

</details>

---

**2.** Implement the merge sort algorithm using the merge operation.

<details>
<summary>Solution</summary>

```python
def merge_sort(xs):
    if len(xs) <= 1:
        return xs
    mid = len(xs) // 2
    return merge(merge_sort(xs[:mid]), merge_sort(xs[mid:]))
```

</details>

---

**3.** Implement the query `SELECT x, SUM(y) FROM t GROUP BY x`
 using sorting (the input table has 2 columns x and y).

<details>
<summary>Solution</summary>

```python
def group_sum_sort(t):
    s = sorted(t, key=lambda r: r[0])
    out = []
    cur_x, cur_sum = None, 0
    for x, y in s:
        if cur_x is None or x == cur_x:
            cur_x, cur_sum = x, cur_sum + y
        else:
            out.append((cur_x, cur_sum))
            cur_x, cur_sum = x, y
    if cur_x is not None:
        out.append((cur_x, cur_sum))
    return out
```

</details>

---

**4.** Implement the query `SELECT * FROM r, s WHERE r.y = s.y`
 using sort-merge join.
The table r has columns x, y, and s has columns y, z.
Make sure you handle duplicates correctly.

<details>
<summary>Solution</summary>

```python
def sort_merge_join(r, s):
    r = sorted(r, key=lambda t: t[1])  # by r.y
    s = sorted(s, key=lambda t: t[0])  # by s.y
    out = []
    i = j = 0
    while i < len(r) and j < len(s):
        if r[i][1] < s[j][0]:
            i += 1
        elif r[i][1] > s[j][0]:
            j += 1
        else:
            y = r[i][1]
            i_end = i
            while i_end < len(r) and r[i_end][1] == y:
                i_end += 1
            j_end = j
            while j_end < len(s) and s[j_end][0] == y:
                j_end += 1
            for a in range(i, i_end):
                for b in range(j, j_end):
                    out.append((r[a][0], y, s[b][1]))
            i, j = i_end, j_end
    return out
```

</details>

---

**5.** Implement the group by-aggregate query above using a map (dictionary) instead.

<details>
<summary>Solution</summary>

```python
def group_sum_map(t):
    d = {}
    for x, y in t:
        d[x] = d.get(x, 0) + y
    return list(d.items())
```

</details>

---

**6.** Implement the join query above using a map (dictionary) instead.

<details>
<summary>Solution</summary>

```python
def hash_join(r, s):
    idx = {}
    for x, y in r:
        idx.setdefault(y, []).append(x)
    out = []
    for y, z in s:
        for x in idx.get(y, []):
            out.append((x, y, z))
    return out
```

Build a hash index on `r.y` mapping to a list of `x` values (so duplicates are preserved), then probe with each row of `s`.

</details>

---

**7.** Implement a map using a hash table. Ask 🤖 to determine what hash function to use.
Try out different methods for collision resolution, including chaining,
linear probing, and quadratic probing.

<details>
<summary>Solution</summary>

Use Python's built-in `hash()` and reduce mod the table size. It's already a good general-purpose hash (SipHash for strings, bit-mixed identity for ints), so we don't need to roll our own.

**Chaining** — each bucket is a list of `(key, value)` pairs:

```python
def chain_new(n=16):
    return [[] for _ in range(n)]

def chain_put(t, k, v):
    b = t[hash(k) % len(t)]
    for i, (kk, _) in enumerate(b):
        if kk == k:
            b[i] = (k, v); return
    b.append((k, v))

def chain_get(t, k):
    for kk, v in t[hash(k) % len(t)]:
        if kk == k: return v
    raise KeyError(k)
```

**Linear probing** — on collision, try `h+1, h+2, ...`. Use `None` for empty slots:

```python
def linear_new(n=16):
    return [None] * n

def linear_put(t, k, v):
    n = len(t)
    i = hash(k) % n
    while t[i] is not None and t[i][0] != k:
        i = (i + 1) % n
    t[i] = (k, v)

def linear_get(t, k):
    n = len(t)
    i = hash(k) % n
    while t[i] is not None:
        if t[i][0] == k: return t[i][1]
        i = (i + 1) % n
    raise KeyError(k)
```

**Quadratic probing** — on collision, try `h+1², h+2², h+3², ...`:

```python
def quad_new(n=16):
    return [None] * n

def quad_put(t, k, v):
    n = len(t)
    h = hash(k) % n
    for j in range(n):
        i = (h + j*j) % n
        if t[i] is None or t[i][0] == k:
            t[i] = (k, v); return
    raise RuntimeError("table full")

def quad_get(t, k):
    n = len(t)
    h = hash(k) % n
    for j in range(n):
        i = (h + j*j) % n
        if t[i] is None: raise KeyError(k)
        if t[i][0] == k: return t[i][1]
    raise KeyError(k)
```

</details>

---

**8. Challenge** (🤖): compare the performance of the different collision resolution methods,
by inserting and querying for a lot of values into a hash table.

---

**9. Challenge**: Implement the radix sort algorithm (covered on 5/11). Measure the performance
over increasingly large inputs, and see if it scales linearly over input size.

---

**10. Challenge**: Implement a hash table based on Cuckoo hashing (covered on 5/11)
and compare its performance with the implementations above.
