---
title: "HW 4: Query Execution"
---

1. Implement the merge operation that takes in two sorted lists
     and merges them into one sorted output.

2. Implement the merge sort algorithm using the merge operation.

3. Implement the query `SELECT x, SUM(y) FROM t GROUP BY x`
    using sorting (the input table has 2 columns x and y).

4. Implement the query `SELECT * FROM r, s WHERE r.y = s.y`
    using sort-merge join.
    The table r has columns x, y, and s has columns y, z.
    Make sure you handle duplicates correctly.

5. Implement the group by-aggregate query above using a map (dictionary) instead.

6. Implement the join query above using a map (dictionary) instead.
