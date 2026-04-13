---
title: "HW 1: SQL"
---

You are encouraged to use AI for problems marked with 🤖.

---

🤖 Find out if you have sqlite installed on your computer.
If not, install it. If you don't want to install it, you can use [sqlime](https://sqlime.org).

🤖 Find out how to create tables in sqlite. 
Also, find out how to insert data into a table, as well as how to delete data.
How do you delete an entire table?

🤖 Run a few queries over the tables you just created.

---

Consider the query `SELECT * FROM R WHERE R.x < 3` (what does "`SELECT * `" mean?).
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query outputs fewer rows than `R`
- The query outputs more rows than `R`
- The query outputs the same number of rows as `R`

<details>
<summary>Solution</summary>

`SELECT *` means "select all columns" — the output has the same columns as the input table.

- **Fewer rows than R**: Easy. Include at least one row where `x >= 3`. That row is filtered out by the `WHERE` clause.
  ```sql
  CREATE TABLE R (x INTEGER);
  INSERT INTO R VALUES (1), (5);
  SELECT * FROM R WHERE R.x < 3; -- outputs 1 row, R has 2
  ```
- **More rows than R**: **Impossible.** A `WHERE` clause can only filter rows — it never duplicates them. The output is always a *subset* of the input.
- **Same number of rows as R**: Make all rows satisfy `x < 3`.
  ```sql
  CREATE TABLE R (x INTEGER);
  INSERT INTO R VALUES (1), (2);
  SELECT * FROM R WHERE R.x < 3; -- outputs all 2 rows
  ```

</details>

Consider the query `SELECT x + x FROM R` where `x` is a column in `R`.
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query outputs fewer rows than `R`
- The query outputs more rows than `R`
- The query outputs the same numbere of rows as `R`

<details>
<summary>Solution</summary>

- **Fewer rows than R**: **Impossible.** There is no `WHERE` clause, so every row in `R` produces exactly one output row. The `SELECT` clause transforms values but never filters or duplicates rows.
- **More rows than R**: **Impossible.** Same reason — one input row always yields exactly one output row.
- **Same number of rows as R**: **Always true**, for any table `R`. The query is a pure projection.

The key insight: `SELECT` (without `DISTINCT`) is row-preserving — it maps each input row to exactly one output row.

</details>

There's a secret SQL feature I didn't tell you in class (thank goodness you are doing your homework!):
 guess what `SELECT DISTINCT x FROM R` does?
Run the query on different input `R` tables to confirm your guess (you can also ask 🤖 to be sure).
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query outputs fewer rows than `SELECT x, avg(y) FROM R GROUP BY x`
- The query outputs more rows than `SELECT x, avg(y) FROM R GROUP BY x`
- The query outputs the same number of rows as `SELECT x, avg(y) FROM R GROUP BY x`

<details>
<summary>Solution</summary>

`SELECT DISTINCT x FROM R` returns the unique values of `x` — it removes duplicate rows from the output.

Both `SELECT DISTINCT x FROM R` and `SELECT x, avg(y) FROM R GROUP BY x` produce exactly one output row per distinct value of `x`. So:

- **Fewer rows**: **Impossible.** Both queries group by distinct values of `x`, so they always produce the same count.
- **More rows**: **Impossible.** Same reason.
- **Same number of rows**: **Always true.** `GROUP BY x` partitions rows by distinct `x` values and outputs one row per group — identical to what `DISTINCT x` does.

This reveals a deep connection: `DISTINCT` is essentially `GROUP BY` without aggregation.

</details>

---

Consider the query `SELECT * FROM R, S WHERE R.x = S.y`, and let `j` be its output size.
Let s be the size of S and r be the size of R.
Try creating tables `R` and `S` to satisfy the following conditions (is any of these impossible?)

- $j \leq r + s$
- $j \leq r * s$
- $j \geq \min(r, s)$
- $j \leq \max(r, s)$

Consider the same query above. Try creating tables `R` and `S` that *violate* each of the conditions above.
If some are not possible, why?

<details>
<summary>Solution</summary>

The query `SELECT * FROM R, S WHERE R.x = S.y` is an equi-join. The output size $j$ depends on how many pairs $(r, s)$ satisfy `R.x = S.y`.

- **$j \leq r + s$**: Can be satisfied or violated.
  - Satisfied: If no rows match, $j = 0 \leq r + s$.
  - **Violated**: Let $R$ have 3 rows all with `x = 1`, and $S$ have 3 rows all with `y = 1`. Then $j = 9 > r + s = 6$.

- **$j \leq r * s$**: **Always true, cannot be violated.** The join is a subset of the full cross product $R \times S$, which has exactly $r \times s$ rows. You can never get more join results than the cross product.

- **$j \geq \min(r, s)$**: Can be satisfied or violated.
  - Satisfied: If every row of the smaller table matches at least one row of the other.
  - **Violated**: If `R.x` and `S.y` share no common values, $j = 0 < \min(r, s)$.

- **$j \leq \max(r, s)$**: Can be satisfied or violated.
  - Satisfied: If all rows have distinct join-key values, $j \leq \min(r, s) \leq \max(r, s)$.
  - **Violated**: Same example as above — 3 rows in R all `x=1`, 3 rows in S all `y=1` gives $j = 9 > \max(3, 3) = 3$.

**Summary:** Only $j \leq r * s$ is a guaranteed invariant. The others depend on the data.

</details>

---

Let's learn linear algebra! We can represent a vector $\mathbf{v} = [v_1, v_2, \ldots, v_k]$ with a 2-column table:

 i   v
--- ---
 1  $v_1$
 2  $v_2$
 3  $v_3$
... ...
 k  $v_k$

where the first column stores the index $i$, and the second column stores the value $\mathbf{v}[i]$.
Similarly, we can represent a matrix $A$ with a 3-column table

 i   j   A
--- --- ---
 1   1  $A_{11}$
 1   2  $A_{12}$
 1   3  $A_{13}$
... ... ...
 2   1  $A_{21}$
 2   2  $A_{22}$
 2   3  $A_{23}$
... ... ...
 k   k  $A_{kk}$

where the $i$ column stores the row index, $j$ stores the column index, and $A_{ij}$ stores the
 matrix entry at row $i$ column $j$.

The point-wise product of two vectors $[a_1, a_2, \ldots, a_k] \odot [b_1, b_2, \ldots, b_k]$
 is the vector $[a_1 \times b_1, a_2 \times b_2, \ldots, a_k \times b_k]$.
Write a SQL query that computes the point-wise product, where the input vectors are represented as tables.

<details>
<summary>Solution</summary>

Join the two vector tables on their index column, then multiply the values:

```sql
SELECT a.i, a.v * b.v AS v
FROM a, b
WHERE a.i = b.i;
```

The `WHERE a.i = b.i` ensures we multiply entries at the same position. The join pairs up $a_i$ with $b_i$ for each index $i$.

</details>

The dot product $a \cdot b$ is the sum over all entries of their point-wise product $a \odot b$:
 $a \cdot b = \sum_i a_i \times b_i$.
Implement the dot product in SQL.

<details>
<summary>Solution</summary>

Wrap the pointwise product in a `SUM` aggregation:

```sql
SELECT sum(a.v * b.v) AS dot_product
FROM a, b
WHERE a.i = b.i;
```

The join handles the element-wise pairing, and `SUM` collapses all products into a single scalar — exactly $\sum_i a_i \times b_i$.

</details>

The outer product $a \otimes b$ is the matrix $A$ such that $A_{ij} = a_i \times b_j$.
Implement the outer product in SQL.

<details>
<summary>Solution</summary>

The outer product pairs *every* entry of `a` with *every* entry of `b` — this is a cross product (no `WHERE` clause needed):

```sql
SELECT a.i, b.i AS j, a.v * b.v AS v
FROM a, b;
```

The result is a matrix table with columns `(i, j, v)` where `v = a[i] * b[j]`. The cross product naturally generates all index pairs $(i, j)$.

</details>

**Challenge:** the matrix product $AB$ is defined as $C_{ik} = \sum_j A_{ij} \times B_{jk}$. Implement this in SQL.

<details>
<summary>Solution</summary>

Join on the shared index $j$, multiply, then group by the output indices $(i, k)$ and sum:

```sql
SELECT A.i, B.j AS k, sum(A.v * B.v) AS v
FROM A, B
WHERE A.j = B.i
GROUP BY A.i, B.j;
```

Here, table `A` has columns `(i, j, v)` and table `B` has columns `(i, j, v)`. The condition `A.j = B.i` matches the column index of `A` with the row index of `B` (the shared summation index). The `GROUP BY` collapses the sum over $j$ for each output cell $(i, k)$.

</details>

The **sparse table** representation of a vector drops all zero entries of the vector.
For example, the vector $[2, 0, 2, 6]$ is represented with the table:

 i   v 
--- ---
 1   2
 3   2
 4   6

Note the missing entry for $i = 2$. 
One can also represent matrices this way, by dropping 0-entries.
Look at the SQL queries you wrote -- do you need to make any changes for them to work with sparse tables?

<details>
<summary>Solution</summary>

**No changes needed!** All the queries work correctly with sparse tables without modification.

Here's why: missing entries represent 0. In the pointwise product and dot product, a zero entry $a_i = 0$ contributes $0 \times b_i = 0$ to the result — which is the same as simply omitting that index pair. Since the join on `a.i = b.i` only produces rows for indices that appear in *both* tables, indices missing from either table are automatically excluded. This is equivalent to multiplying by zero and then dropping the zero result.

The outer product query produces every pair $(i, j)$ regardless — sparse inputs just mean fewer rows in the output (since zero-valued rows are absent from the input), which is correct sparse behavior.

The matrix product similarly benefits: indices where $A_{ij} = 0$ or $B_{jk} = 0$ simply don't appear in the join, so they contribute 0 to the sum without needing to be represented.

This is one of the elegant properties of SQL joins for sparse linear algebra: sparsity is handled for free.

</details>

---

You learned about the join $R \Join_p S$ in class. 
We say a row $r \in R$ *joins with* $S$, if there is at least one row
 $s \in S$ such that pairing $r$ and $s$ together satisfies the 
 join condition (`WHERE` clause) $p$.
A *semijoin* $R \ltimes S$ returns all rows in $R$ that join with $S$.
Write a SQL query computing the semijoin $R \ltimes S$, 
 with the join condition `R.y = S.y` (hint: use `EXISTS`).
What are the possible relationships between $|R \Join S|$ and $|R \ltimes S|$?

<details>
<summary>Solution</summary>

```sql
SELECT * FROM R
WHERE EXISTS (
    SELECT 1 FROM S WHERE R.y = S.y
);
```

`EXISTS` returns true if the subquery produces at least one row — exactly the definition of "joins with S". Each row of `R` is tested independently.

**Relationship between $|R \Join S|$ and $|R \ltimes S|$:**

- $|R \ltimes S| \leq |R|$ always (semijoin is a subset of R).
- $|R \Join S| \geq |R \ltimes S|$ always — every row counted by the semijoin appears at least once in the join. If a row $r$ joins with $k \geq 1$ rows in $S$, it contributes $k$ rows to the join but only 1 row to the semijoin.
- $|R \Join S| = |R \ltimes S|$ when every matching row in $R$ joins with *exactly one* row in $S$ — i.e., when `S.y` is a primary key of `S`.
- $|R \Join S|$ can be much larger: if all rows of $R$ share the same `y` value and all rows of $S$ share the same `y` value, the join has $r \times s$ rows while the semijoin has at most $r$ rows.

</details>

🤖 The join $R \Join S$ can be understood as looping over $R$,
 and for each $r \in R$, find all $s \in S$ that join with $r$.
A (left) outer join is like a join, but when a row $r \in R$ does not join
 with any $s \in S$, it pairs $r$ with `NULL`s.
Figure out the syntax for left outer join in SQLite, 
 and run a few queries to understand how it works.
If we replace a join with an outer join, do we get fewer outputs,
the same number of outputs, or more outputs?

<details>
<summary>Solution</summary>

```sql
SELECT * FROM R LEFT OUTER JOIN S ON R.y = S.y;
```

(`OUTER` is optional in SQLite — `LEFT JOIN` works too.)

**Replacing join with outer join gives the same or more outputs.** Specifically:

- For every row $r \in R$ that joins with at least one row in $S$: the output is the same as a regular join.
- For every row $r \in R$ that joins with *no* row in $S$: the regular join produces no output for that $r$, but the outer join produces one output row with `NULL`s for all columns of $S$.

So the outer join result always contains the inner join result, plus additional rows with `NULL`s for unmatched left-side rows. The output size is $\geq$ that of the regular join.

</details>

---

SQL will not output a row, if the `WHERE` clause evaluates to `UNKNOWN` on that clause.
But what if the `SELECT` clause evaluates to `NULL`?
Try out a few queries to find out what happens.

<details>
<summary>Solution</summary>

When a `SELECT` expression evaluates to `NULL`, SQL **still outputs the row** — the row appears in the result with a `NULL` value in that column.

```sql
CREATE TABLE R (x INTEGER);
INSERT INTO R VALUES (1), (NULL);

SELECT x + 1 FROM R;
-- Output:
-- 2
-- NULL   ← the row is included, but the value is NULL
```

This is the key asymmetry: `WHERE` suppresses rows when the condition is `UNKNOWN` (which `NULL` comparisons produce), but `SELECT` never suppresses rows — it just produces `NULL` output. The row always makes it through; only the computed value is null.

</details>

Practice how `NULL`s work in SQL by writing out a few examples involving
 data operators, predicates, and logical connectives and figure out
 what they should evaluate to.
Is it possible to *not* end up with `UNKNOWN` even if an input data value is `NULL`?

<details>
<summary>Solution</summary>

**Yes, you can avoid `UNKNOWN` even with `NULL` inputs**:

`SELECT * FROM r WHERE 1 < NULL OR 2 = 2`

</details>

---

We say a column $k$ is a *primary key* of a table, 
 if the value in that column uniquely identifies the row.
In other words, no two different rows share the same value in $k$.
Write a SQL query to check if a given column is a primary key
 (hint: one way to do this is with `GROUP BY` and `HAVING`;
 another way is to use `COUNT(DISTINCT ...)`.
 Make sure you know how to do it both ways.)

<details>
<summary>Solution</summary>

**Method 1: `GROUP BY` and `HAVING`**

Find any value of $k$ that appears more than once. If no such value exists, $k$ is a primary key:

```sql
SELECT k FROM R GROUP BY k HAVING COUNT(*) > 1;
-- If this returns no rows, k is a primary key.
```

**Method 2: `COUNT(DISTINCT ...)`**

Compare the total number of rows to the number of distinct values of $k$. They must be equal:

```sql
SELECT 'yes' FROM R HAVING COUNT(*) = COUNT(DISTINCT k);
-- If this returns empty, k is NOT a primary key.
```

Both approaches detect duplicates: the first finds them explicitly, the second checks whether the distinct count matches the total count.

</details>

Given a primary key $k$ in $R$, a column $f$ in $S$
 is a *foreign key* referencing $R.k$
 if every value of $S.f$ also appears in $R.k$.
Write a SQL query to check if a given column $S.f$
 can be a foreign key referencing $R.k$.

<details>
<summary>Solution</summary>

Return all rows in `S` whose `f` value has no match in `R.k`. If the result is empty, `S.f` is a valid foreign key:

```sql
SELECT * FROM S WHERE NOT EXISTS (SELECT * FROM R WHERE R.k = S.f);
-- If this returns empty, S.f IS a valid foreign key.
-- Any rows returned are "orphans" that violate the constraint.
```

`NOT EXISTS` checks, for each row in `S`, whether there is any row in `R` with a matching `k`. If no such row exists, the `S` row is included in the output.

</details>
