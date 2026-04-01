---
title: "HW 1: SQL (*WIP*)"
---

You are encouraged to use AI for problems marked with 🤖.

🤖 Find out if you have sqlite installed on your computer.
If not, install it. If you don't want to install it, you can use [sqlime](https://sqlime.org).

🤖 Find out how to create tables in sqlite. 
Also, find out how to insert data into a table, as well as how to delete data.
How do you delete an entire table?

🤖 Run a few queries over the tables you just created.

Consider the query `SELECT * FROM R WHERE R.x < 3` (what does "`SELECT * `" mean?).
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query outputs fewer rows than `R`
- The query outputs more rows than `R`
- The query outputs the same numbere of rows as `R`

Consider the query `SELECT x + x FROM R` where `x` is a column in `R`.
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query outputs fewer rows than `R`
- The query outputs more rows than `R`
- The query outputs the same numbere of rows as `R`

There's a secret SQL feature I didn't tell you in class (thank goodness you are doing your homework!):
 guess what `SELECT DISTINCT x FROM R` does?
Run the query on different input `R` tables to confirm your guess (you can also ask 🤖 to be sure).
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query outputs fewer rows than `SELECT x, avg(y) FROM R GROUP BY x`
- The query outputs more rows than `SELECT x, avg(y) FROM R GROUP BY x`
- The query outputs the same number of rows as `SELECT x, avg(y) FROM R GROUP BY x`

Consider the query `SELECT * FROM R, S WHERE R.x = S.y`, and let `j` be its output size.
Let s be the size of S and r be the size of S.
Try creating tables `R` and `S` to satisfy the following conditions (is any of these impossible?)

- $j \leq r + s$
- $j \leq r * s$
- $j \geq \min(r, s)$
- $j \leq \max(r, s)$

Consider the same query above. Try creating tables `R` and `S` that *violate* each of the conditions above.
If some are not possible, why?

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

The dot product $a \cdot b$ is the sum over all entries of their point-wise product $a \odot b$:
 $a \cdot b = \sum_i a_i \times b_i$.
Implement the dot product in SQL.

The outer product $a \otimes b$ is the matrix $A$ such that $A_{ij} = a_i \times b_j$.
Implement the outer product in SQL.

**Challenge:** the matrix product $AB$ is defined as $C_{ik} = \sum_j A_{ij} \times B_{jk}$. Implement this in SQL.

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

**To be continued ...**
