---
title: Query Execution
author: Remy Wang
date: May 2026
---

Review how projection and filter work in relational algebra.

---

The first interesting operation is group by-aggregate.

We can implement it by first sorting, then summing over adjacent elements.

|x|y|
|-|-|
|1|1|
|1|2|
|1|3|
|2|1|
|2|2|

Because the table is sorted by x,
 each group is together, and we can sum over them.

---

A popular sorting algorithm is merge sort.
Let's review.
The key step in merge sort is merging two sorted lists.

---

A: **1**, 3, 5\
B: **2**, 4, 6\
out:

---

A: ~~1~~, **3**, 5\
B: **2**, 4, 6\
out: 1

---

A: ~~1~~, **3**, 5\
B: ~~2~~, **4**, 6\
out: 1, 2

---

A: ~~1~~, ~~3~~, **5**\
B: ~~2~~, **4**, 6\
out: 1, 2, 3

---

A: ~~1~~, ~~3~~, **5**\
B: ~~2~~, ~~4~~, **6**\
out: 1, 2, 3, 4

---

A: ~~1~~, ~~3~~, ~~5~~\
B: ~~2~~, ~~4~~, **6**\
out: 1, 2, 3, 4, 5

---

A: ~~1~~, ~~3~~, ~~5~~\
B: ~~2~~, ~~4~~, ~~6~~\
out: 1, 2, 3, 4, 5, 6

---

Using the merge operation, we can then implement sort recursively:

1. Break the input into two parts
2. Recursively sort each part
3. Merge them together

---

input:

[3, 1, 4, 1, 5, 9, 2, 6]

---

split:

[3, 1, 4, 1]&nbsp;&nbsp;[5, 9, 2, 6]

---

split:

[3, 1]&nbsp;[4, 1]&nbsp;&nbsp;[5, 9]&nbsp;[2, 6]

---

split:

[3]&nbsp;[1]&nbsp;[4]&nbsp;[1]&nbsp;&nbsp;[5]&nbsp;[9]&nbsp;[2]&nbsp;[6]

---

merge:

[1, 3]&nbsp;[1, 4]&nbsp;&nbsp;[5, 9]&nbsp;[2, 6]

---

merge:

[1, 1, 3, 4]&nbsp;&nbsp;[2, 5, 6, 9]

---

merge:

[1, 1, 2, 3, 4, 5, 6, 9]

---

Sorting can also be used to implement join.

---

A: **1**, 3, 5, 7\
B: **2**, 3, 5, 6\
out:

---

A: 1, **3**, 5, 7\
B: **2**, 3, 5, 6\
out:

---

A: 1, **3**, 5, 7\
B: 2, **3**, 5, 6\
out:

---

A: 1, 3, **5**, 7\
B: 2, 3, **5**, 6\
out: 3

---

A: 1, 3, 5, **7**\
B: 2, 3, 5, **6**\
out: 3, 5

---

A: 1, 3, 5, **7**\
B: 2, 3, 5, 6\
out: 3, 5

---

What if there are duplicates?

A: (3, a), (3, b), (5, c)\
B: (3, x), (3, y), (5, z)

(letters distinguish rows with the same key)

---

Naively advancing both pointers on a match:

out: (3, a, x), (3, b, y), (5, c, z)

But we want *all* matching pairs — there should be 5.

---

When keys match, output the cross product
of the *runs* of equal keys on both sides.

run in A: (3, a), (3, b)\
run in B: (3, x), (3, y)\
out: (3, a, x), (3, a, y), (3, b, x), (3, b, y)

Then advance past both runs.

---

A: (3, a), (3, b), **(5, c)**\
B: (3, x), (3, y), **(5, z)**\
out: ..., (5, c, z)

---

We can also implement group-by with a *map* (dictionary in Python).

For example, to group by `x` and sum over `y`:

```python

d = {}

for (x, y) in t:
  if x not in d:
    d[x] = y
  else:
    d[x] += y
```

---
