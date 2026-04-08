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

SQL will not output a row, if the `WHERE` clause evaluates to `UNKNOWN` on that clause.
But what if the `SELECT` clause evaluates to `NULL`?
Try out a few queries to find out what happens.

---

You learned about the join $R \Join_p S$ in class. 
We say a row $r \in R$ *joins with* $S$, if there is at least one row
 $s \in S$ such that pairing $r$ and $s$ together satisfies the 
 join condition (`WHERE` clause) $p$.
A *semijoin* $R \ltimes S$ returns all rows in $R$ that join with $S$.
Write a SQL query computing the semijoin $R \ltimes S$, 
 with the join condition `R.y = S.y` (hint: use `EXISTS`).
What are the possible relationships between $|R \Join S|$ and $|R \ltimes S|$?

🤖 The join $R \Join S$ can be understood as looping over $R$,
 and for each $r \in R$, find all $s \in S$ that join with $r$.
A (left) outer join is like a join, but when a row $r \in R$ does not join
 with any $s \in S$, it pairs $r$ with `NULL`s.
Figure out the syntax for left outer join in SQLite, 
 and run a few queries to understand how it works.
If we replace a join with an outer join, do we get fewer outputs,
the same number of outputs, or more outputs?

Practice how `NULL`s work in SQL by writing out a few examples involving
 data operators, predicates, and logical connectives and figure out
 what they should evaluate to.
Is it possible to *not* end up with `UNKNOWN` even if an input data value is `NULL`?

---

We say a column $k$ is a *primary key* of a table, 
 if the value in that column uniquely identifies the row.
In other words, no two different rows share the same value in $k$.
Write a SQL query to check if a given column is a primary key
 (hint: one way to do this is with `GROUP BY` and `HAVING`;
 another way is to use `COUNT(DISTINCT ...)`.
 Make sure you know how to do it both ways.)

Given a primary key $k$ in $R$, a column $f$ in $S$
 is a *foreign key* referencing $R.k$
 if every value of $R.f$ also appears in $R.k$.
Write a SQL query to check if a given column $S.f$
 can be a foreign key referencing $R.k$.
