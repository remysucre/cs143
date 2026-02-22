What does the following queries return given input?

| x | y |
| - | - |
| 1 | 5 |
| 2 | 4 |
| 3 | 3 |
| 4 | 2 |
| 5 | 1 |

```SQL
SELECT x FROM t WHERE x < 3
```

```SQL
SELECT x, y FROM t WHERE y < 3
```

```SQL
SELECT x FROM t WHERE y < 3
```

```SQL
SELECT x+1 FROM t WHERE y < 3
```

```SQL
SELECT x+y FROM t WHERE y < 3
```

General form: `SELECT e(x, y) FROM table WHERE cond(x, y)`

Meaning:

```python
for (x, y) in table:
  if cond(x, y):
    print(e(x, y))
```
