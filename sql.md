What does the following queries return given input?

| x | y |
| - | - |
| 1 | 5 |
| 2 | 4 |
| 3 | 3 |
| 4 | 2 |
| 5 | 1 |

```SQL
SELECT x 
  FROM t 
 WHERE x < 3

SELECT x, y 
  FROM t 
 WHERE y < 3

SELECT x 
  FROM t 
 WHERE y < 3

SELECT x+1 
  FROM t 
 WHERE y < 3

SELECT x+y 
  FROM t 
 WHERE y < 3

SELECT x+y 
  FROM t 
 WHERE NOT y < 3

SELECT x+y 
  FROM t 
 WHERE y < 3 AND x > 1

SELECT x+y 
  FROM t 
 WHERE y < 3 OR x > 1
```

General form: 
```SQL
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

Next, aggregates

```
SELECT SUM(x) FROM t
SELECT MIN(x) FROM t
SELECT MAX(x) FROM t
SELECT AVG(x) FROM t
SELECT COUNT(x) FROM t
```

Next, grouping


| x | y |
| - | - |
| 1 | 5 |
| 2 | 4 |
| 3 | 3 |
| 1 | 2 |
| 2 | 1 |

```
  SELECT ...
    FROM t
GROUP BY x
```

| x | y |
| - | - |
| ? | ? |
| ? | ? |
|   |   |
| ? | ? |
| ? | ? |
|   |   |
| ? | ? |


```
  SELECT x, SUM/MIN/MAX/AVG/COUNT(y)
    FROM t
GROUP BY x
```

`GROUP BY` variable (`x`)  **must** be `SELECT`ed, `AGG` function applied per group.

Current general form:

```SQL
4:   SELECT x, AGG(y)
1:     FROM t
2:    WHERE cond(x, y)
3: GROUP BY x
```

1. Where's the data `FROM`?
2. Check conditions
3. Group rows
4. Run aggregate & return
