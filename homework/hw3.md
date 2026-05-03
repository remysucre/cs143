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

---

Implement a lock manager:
 write a Python function
 that takes in an action `(tx, op, x)`
 where `tx` is the tx ID (int),
 `op` is one of `R`, `W`, `ROLLBACK`, `COMMIT`,
 and `x` is a DB item (int).
A global variable `locks` is a [dictionary](https://docs.python.org/3/tutorial/datastructures.html#dictionaries)
 mapping each DB item to the tx holding the lock, if any.
Your function should implement strict 2PL:
 for each action,
 check if the item is already locked
 by the tx, and attempt to lock if not;
 the function should return `true` if the action can proceed,
 and `false` if it fails to acquire a lock.
All locks should be released at commit/rollback time (ignore the DB item for commit/rollback actions).

<details>
<summary>Solution</summary>

```python
locks = {}  # item -> tx holding the lock

def lock_manager(tx, op, x):
    if op in ('COMMIT', 'ROLLBACK'):
        to_release = [item for item, holder in locks.items() if holder == tx]
        for item in to_release:
            del locks[item]
        return True
    # R or W: need the lock on x
    if x not in locks:
        locks[x] = tx
        return True
    return locks[x] == tx  # True if we already hold it, False if another tx does
```

On COMMIT/ROLLBACK, release every lock held by this tx (strict 2PL: hold all locks until end).
On R/W, acquire the lock if free; succeed silently if we already hold it; fail if another tx holds it.

</details>

---

Make sure you understand the proof of why 2PL guarantees serializability.
You don't need to memorize it, but you should be able to explain it
 to someone else while looking at the slides.
A good excercise is to write down the proof in a more formal & detailed way
 and fill in the gaps.

<details>
<summary>Solution</summary>

First, we show that an edge $i \to j$ in the precedence graph
 implies $T_i$  unlocks an item $X$ before $T_j$ locks $X$.
If there's an edge $i \to j$, there must be a pair of conflicting
 actions $a_i \in T_i$ and $a_j \in T_j$ such that $a_i$
 occurs before $a_j$, and they act on the same DB item $X$.
When $a_i$ acts on $X$, $T_i$ must hold a lock on $X$; 
 but for $a_j$ to act on $X$, $T_j$ must have first locked $X$, 
 which can only happen *after* $T_i$ releases its lock.
Therefore, $T_i$ must unlock on $X$ before $T_j$ locks it.

Now, assume for the sake of contradiction that
 a schedule follows 2PL but is *not* serializable.
Then there must be a cycle in the precedence graph.
Without loss of generality suppose the cycle
 is $1 \to 2 \to \cdots \to k \to 1$.
Using the result we proved above, 
 there exists items $X_1, X_2, \ldots, X_k$
 such that: 

- $T_1$ unlocks $X_1$ before $T_2$ locks $X_1$
- $T_2$ unlocks $X_2$ before $T_3$ locks $X_2$
- ...
- $T_k$ unlocks $X_k$ before $T_1$ locks $X_k$

According to 2PL, all unlocks must happen *after* all locks within the same tx,
 i.e., $T_i$ unlocks $X$ after $T_i$ locks $X'$ for all $i$.
This means that we can put the events above in a strict sequential order:

$U_1(X_1) < L_2(X_1) < U_2(X_2) < L_3(X_2) < \cdots < U_k(X_k) < L_1(X_k)$

Where $U_i(X)$ and $L_i(X)$ denote the event of $T_i$ unlocking/locking $X$, respectively.
But this would require $T_1$ to lock $X_k$ *after* it unlocks $X_1$, which violates
 2PL -- contradiction!

</details>

---

The basic 2PL only has one kind of lock.
We can allow for even more concurrency using read/write locks:
 a read lock on X allows a tx to read X,
 and multiple read locks on the same item can coexist;
 a write lock on X allows writing,
 but if a tx holds a write lock on X,
 no other tx can hold any kind of lock.
Another name for read locks is "shared locks",
 and for write locks "exclusive locks".
Find an example where there would be more concurrency
 under read/write locks compared to just a single type of locks.

<details>
<summary>Solution</summary>

Any schedule where two transactions read the same item without writing it:

|T~1~|T~2~|
|-|-|
|R(A)|R(A)|
|W(B)|W(C)|

Under single-type (exclusive) locks, T~1~ and T~2~ cannot both hold the lock on $A$ at the same time — one must wait. Under read/write locks, both can hold shared locks on $A$ simultaneously (reads don't conflict), then proceed to write their respective items $B$ and $C$ in parallel. The single-type scheme serializes the reads unnecessarily; the r/w scheme does not.

</details>

---

Convince yourself that 2PL still guarantees serializability.
This involves carefully revisiting each step in the original proof,
 and showing the reasoning still holds up under read/write locks.

---

Under read/write locking, it's possible for there to be no deadlock,
 but a tx still gets blocked indefinitely,
 leading to what's known as *starvation*.
Can you come up with an example of this?
Hint: this can happen when you have lots of tx reading an item,
 while 1 other tx tries to write.

<details>
<summary>Solution</summary>

Starvation can happen if a tx wants to write, 
 but some other tx's hold a read lock,
 and new tx's keep arriving locking the item for reading:

|T~w~|T~1~|T~2~|T~3~|T~4~|...|
|-|-|-|-|-|-|
|~~X(A)~~|S(A)|S(A)||||
|~~X(A)~~||S(A)|S(A)|||
|~~X(A)~~|||S(A)|S(A)||
|~~X(A)~~||||S(A)|...|
|~~X(A)~~|||||...|

Here ~~X(A)~~ denotes a failed attempt to acquire an exclusive (write) lock on A,
 and S(A) denotes the corresponding tx is holding a shared (read) lock on A.
Because read locks do not conflict, the arriving tx's can keep
 getting new locks, making it impossible for the exclusive lock to succeed.
Imagine you're trying to fix a busy road: if the cars keep coming (read locks),
 you can't work on the road (write lock).
The solution is also similar:
 for roadwork, you stop letting people through once you want to start work;
 for transactions, block all incoming reads if you have a pending write.

</details>

---

Implement snapshot isolation (SI).
Use a global dictionary to map each DB item to its last-updated timestamp (`int`).
Write a function that checks if a given transaction should commit.
The function takes as arguments:

1. The transaction start time (`int`)
2. The set of DB items read
3. The set of DB items written
4. The commit time ("current" time) (`int`)

It should return `true` and update the global timestamps if the transaction
 should commit, otherwise return `false`.

<details>
<summary>Solution</summary>

```python
last_written = {}  # item -> commit time of the last tx that wrote it

def si_commit(start, read_set, write_set, commit):
    for x in write_set:
        if last_written.get(x, 0) > start:
            return False  # a concurrent tx already committed a write on x
    for x in write_set:
        last_written[x] = commit
    return True
```

</details>

---

Implement write-snapshot isolation (WSI) similarly.

<details>
<summary>Solution</summary>

```python
last_written = {}

def wsi_commit(start, read_set, write_set, commit):
    for x in read_set:
        if last_written.get(x, 0) > start:
            return False  # a concurrent tx wrote something we read
    for x in write_set:
        last_written[x] = commit
    return True
```

</details>

---

Find a serializable schedule that's forbidden under SI.
Find a non-serializable schedule that's allowd by SI.
Find a serializable schedule that's forbidden by WSI (Hint: check the [paper](https://arxiv.org/abs/2405.18393) 🤖).
Is it possible to find a non-serializable schedule that's allowed by WSI?

<details>
<summary>Solution</summary>

**Serializable, forbidden by SI** — concurrent blind writes to the same item:

|T~1~|T~2~|
|-|-|
|W(A)||
||W(A)|
||COMMIT|
|COMMIT||

**Non-serializable, allowed by SI**:

|T~1~ (start=1)|T~2~ (start=1)|
|-|-|
|R(A), R(B)|R(A), R(B)|
|W(A := 0)||
||W(B := 0)|
|COMMIT|COMMIT|

**Serializable, forbidden by WSI** — a "stale read" that's logically fine:

|T~1~ (start=1, commit=4)|T~2~ (start=2, commit=3)|
|-|-|
|R(X)||
||W(X)|
||COMMIT|
|W(Y), COMMIT||


**Non-serializable, allowed by WSI?** No — WSI is sufficient for serializability.

</details>

---

**Challenge**: (open problem):
The existence of serializable schedules forbidden by WSI shows WSI is not necessary for serializability.
However, the example in the paper violates *strict serializability*, which requires the comit order to be preserved.
Can you prove if WSI is necessary for strict serializability?

---

**Challenge**:
The full implementation of WSI actually includes an additional optimization:
 instead of reading from the DB snapshot,
 each read accesses the *live* value from the original DB directly.
This explains the "write" in WSI:
 unlike SI which reads from a snapshot, 
 WSI only "writes to the snapshot".
The motivation is that reading fresh values reduces aborts - do you see why?

<details>
<summary>Solution</summary>

WSI aborts T whenever `last_written[x] > start_T` for some $x \in R_T$ — i.e.,
 when a concurrent tx committed a write to something T read. The relevant
 "danger window" is between T's *read* of $x$ and T's commit: a write inside
 that window is a real anti-dependency, while a write that lands *before* T
 reads $x$ is harmless (T would just see the new value).

With snapshot reads, T can't tell the difference. The check uses `start_T` as a
 conservative proxy for the read time, so any write committed during
 `[start_T, commit_T]` triggers an abort — including writes that landed before
 T even got around to reading $x$, which would have been benign.

With live reads, T reads the fresh value at the moment it asks. Now any write
 committed before that read is automatically reflected in what T saw, so it
 *can't* be a conflict. The abort window shrinks from `[start_T, commit_T]`
 down to `[read_time(x), commit_T]`, which is strictly smaller. Fewer windows
 → fewer false-positive aborts → better throughput.

</details>
