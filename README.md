---
title: CS 143
---

## Why databases?

What's the most popular programming language?

How many databases are out there? (1 trillion sqlite DB)

How old is the oldest DB? (~3500 BC, 5k years old)

DB's fun:
- rite of passage of a systems hacker: write a compiler, write an OS, write a DB
- beautiful algorithms & theory

## Trying things out

SQL playground: https://sqlime.org

You might also have `sqlite` already installed on your computer.

If running in terminal, remember to add semicolon `;` at the end of each query.

First, `CREATE TABLE t (x int, y int)`

Add data by `INSERT INTO t VALUES (1, 5), (2, 4), (3, 3), (4, 2), (5, 1)`

Check with `SELECT * FROM t` (`*` = all the columns)

To remove rows, `DELETE FROM t WHERE x = 1 AND y = 5` (how do you delete all rows?)

To remove table, `DROP TABLE t`

## Basic SQL

What does the following queries return given input?

| x | y |
| - | - |
| 1 | 5 |
| 2 | 4 |
| 3 | 3 |
| 4 | 2 |
| 5 | 1 |

```{.sql .run template="#setup-basic"}
SELECT x
  FROM t
 WHERE x < 3
```

```{.sql .run template="#setup-basic"}
SELECT x, y
  FROM t
 WHERE y < 3
```

```{.sql .run template="#setup-basic"}
SELECT x
  FROM t
 WHERE y < 3
```

```{.sql .run template="#setup-basic"}
SELECT x+1
  FROM t
 WHERE y < 3
```

```{.sql .run template="#setup-basic"}
SELECT x+y
  FROM t
 WHERE y < 3
```

```{.sql .run template="#setup-basic"}
SELECT x+y
  FROM t
 WHERE NOT y < 3
```

```{.sql .run template="#setup-basic"}
SELECT x+y
  FROM t
 WHERE y < 3 AND x > 1
```

```{.sql .run template="#setup-basic"}
SELECT x+y
  FROM t
 WHERE y < 3 OR x > 1
```

General form:
```sql
SELECT e(x, y)
  FROM table
 WHERE cond(x, y)
```

Meaning:

```python
for (x, y) in table:
  if cond(x, y):
    print(e(x, y))
```

## Aggregates

```{.sql .run template="#setup-basic"}
SELECT SUM(x) FROM t
```

```{.sql .run template="#setup-basic"}
SELECT MIN(x) FROM t
```

```{.sql .run template="#setup-basic"}
SELECT MAX(x) FROM t
```

```{.sql .run template="#setup-basic"}
SELECT AVG(x) FROM t
```

```{.sql .run template="#setup-basic"}
SELECT COUNT(x) FROM t
```

Aggregate by groups:

| x | y |
| - | - |
| 1 | 5 |
| 2 | 4 |
| 3 | 3 |
| 1 | 2 |
| 2 | 1 |

```{.sql .run template="#setup-agg"}
  SELECT ...
    FROM t
GROUP BY x
```

| x | y |
| - | - |
| ? | ? |
| ? | ? |

| x | y |
| - | - |
| ? | ? |
| ? | ? |

| x | y |
| - | - |
| ? | ? |


```{.sql .run template="#setup-agg"}
  SELECT x, SUM/MIN/MAX/AVG/COUNT(y)
    FROM t
GROUP BY x
```

`GROUP BY` variable (`x`)  **must** be `SELECT`ed, `AGG` function applied per group.

Current general form:

```sql
4:   SELECT x, AGG(y)
1:     FROM t
2:    WHERE cond(x, y)
3: GROUP BY x
```

1. Where's the data `FROM`?
2. Check conditions
3. Group rows
4. Run aggregate & return

## Relational algebra

| Name | Notation | Meaning |
| - | - | - |
| selection | $\sigma_p(t)$ | filter by condition $p$ |
| projection | $\pi_{e(x, y)}(t)$ | evaluate an expression $e$ over $x, y$ and return |
| aggregation | $\gamma_{x, F(y)}(t)$ | group by $x$, aggregate over $y$ using $F$ |

Can you write out SQL query for each operation?
