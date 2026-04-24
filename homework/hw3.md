---
title: "HW 3: Transactions"
---

We'll represent a transaction schedule as a list of actions.
Each action is a tuple `(t, tx, op, item)` where:

- `t` is an integer, the timestamp
- `tx` is an integer, the id of the transaction
- `op` is a string, either `'R'` (read) or `'W'` (write)
- `item` is a string, the name of a DB item

For example, the schedule:

|T~1~|T~2~|
|-|-|
|R(A)|R(B)|
|W(A)|W(B)|

is represented as:

```python
[(1, 1, 'R', 'A'), (1, 2, 'R', 'B'), (2, 1, 'W', 'A'), (2, 2, 'W', 'B')]
```

---

Implement the algorithm to compute the precedence graph of a schedule:

```python
def precedence(schedule):
  """Compute the precedence graph of a schedule.

  Arguments:
  schedule: a list of actions (t, tx, op, item)

  Returns a set of edges (i, j) meaning tx i must precede tx j.
  """
```

Hint: you can implement a fast algorithm by sorting first.

<details>
<summary>Solution</summary>

```python
def precedence(schedule):
    edges = set()
    for (t_i, i, op_i, x) in schedule:
        for (t_j, j, op_j, y) in schedule:
            if t_i <= t_j and i != j and x == y and (op_i == 'W' or op_j == 'W'):
                edges.add((i, j))
    return edges
```

We loop over every pair of actions with $t_i <= t_j$ and add an edge if they conflict on the same item.

**Faster version**: sort the actions first (by timestamp), then the inner loop only needs to look at *later* items. This halves the comparisons and lets us drop the explicit `t_i <= t_j` check — it's guaranteed by the slice.

```python
def precedence(schedule):
    edges = set()
    s = sorted(schedule)
    for k, (_, i, op_i, x) in enumerate(s):
        for (_, j, op_j, y) in s[k+1:]:
            if i != j and x == y and (op_i == 'W' or op_j == 'W'):
                edges.add((i, j))
    return edges
```

</details>

---

Write a SQL query that computes the precedence graph edges. Assume the schedule is stored in a table:

```sql
create table action (
  t    int,   -- timestamp (ties allowed across tx)
  tx   int,   -- transaction id
  op   text,  -- 'R' or 'W'
  item text   -- DB item
);
```

Your query should return a table of `(i, j)` pairs: the edges of the precedence graph.

Hint: you'll need to join the action table with itself.

<details>
<summary>Solution</summary>

```sql
select distinct a.tx as i, b.tx as j
from action a, action b
where a.t <= b.t
  and a.tx != b.tx
  and a.item = b.item
  and (a.op = 'W' or b.op = 'W');
```

This is a self-join on `action` with the same conflict conditions as the Python version. `select distinct` removes duplicate edges (multiple conflicting pairs between the same two tx collapse to a single edge).

</details>

---

Run your `precedence` function by hand on the 3-tx schedule from the notes:

|T~1~|T~2~|T~3~|
|-|-|-|
|R(B)|R(A)||
||W(A)||
|W(B)||R(A)|
||R(B)||
||W(B)||

Verify you get the edges $T_1 \to T_2$, $T_2 \to T_3$, and no others.

---

Give a serializable, but not serial, schedule
 where only one action takes place at a time.

<details>
<summary>Solution</summary>

The "concurrent" version at the top of the homework (with tied timestamps) is serializable but not serial. To satisfy the extra constraint (unique timestamps — only one action at a time), just stagger the actions:

```python
[(1, 1, 'R', 'A'), (2, 2, 'R', 'B'), (3, 1, 'W', 'A'), (4, 2, 'W', 'B')]
```

|T~1~|T~2~|
|-|-|
|R(A)||
||R(B)|
|W(A)||
||W(B)|

Not serial: $T_1$'s actions aren't contiguous. Serializable: $T_1$ and $T_2$ touch different items, so the precedence graph is empty — equivalent to either serial order.

</details>

---

Make sure you understand the difference between 2PL and strict 2PL,
 and what problem the latter solves.

---

2PL is *sufficient* for serializability but not *necessary*.
Construct a 2-tx schedule with locks that is serializable but cannot follow 2PL.

<details>
<summary>Solution</summary>

Consider:

|T~1~|T~2~|
|-|-|
|L(A),R(A),U(A)||
||L(A),R(A),U(A)|
||L(B),W(B),U(B)|
|L(B),W(B),U(B)||

The schedule violates 2PL on both tx's, but is equivalent to
 the serial schedule where T~2~ runs before T~1~,
 since the R(A) action in T~1~ does not conflict
 with anything from T~2~.

</details>

---

Write a SQL query that computes the wait-for graph,
 given a table of currently-held locks and a table
 of upcoming actions (one per tx):

```sql
create table held (
  tx   int,
  item text   -- tx holds the lock on item
);

create table upcoming (
  tx   int,
  op   text,  -- 'R' or 'W'
  item text   -- the item to act on
);
```

Your query should return `(i, j)` pairs: tx $i$ is waiting on a lock held by tx $j$.

<details>
<summary>Solution</summary>

```sql
select distinct u.tx as i, h.tx as j
from upcoming u, held h
where u.item = h.item
  and u.tx != h.tx;
```

</details>

