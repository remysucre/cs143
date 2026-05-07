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

7. Implement a map using a hash table. Ask 🤖 to determine what hash function to use.
    try out different methods for collision resolution, including chaining, 
    linear probing, and quadratic probing.

8. **Challenge** (🤖): compare the performance of the different collision resolution methods,
    by inserting and querying for a lot of values into a hash table.

9. **Challenge**: Implement the radix sort algorithm (covered on 5/11). Measure the performance
    over increasingly large inputs, and see if it scales linearly over input size.

10. **Challenge**: Implement a hash table based on Cuckoo hashing (covered on 5/11) 
    and compare its performance with the implementations above.
