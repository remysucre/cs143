You are encouraged to use AI for problems marked with 🤖.

🤖 Find out if you have sqlite installed on your computer.
If not, install it. If you don't want to install it, you can use [sqlime](https://sqlime.org)

🤖 Find out how to create tables in sqlite. 
Also, find out how to insert data into a table, as well as how to delete data.
How do you delete an entire table?

🤖 Run a few queries over the tables you just created.

Consider the query `SELECT * FROM R WHERE R.x < 3`.
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query output has fewer rows than `R`
- The query output has more rows than `R`
- The query output has the same numbere of rows as `R`

Consider the query `SELECT x FROM R` where `x` is a column in `R`.
Try creating a table `R` to satisfy the following conditions (some of them are impossible; why?):

- The query output has fewer rows than `R`
- The query output has more rows than `R`
- The query output has the same numbere of rows as `R`

There's a secret SQL feature I didn't tell you in class (thank goodness you are doing your homework!):
 guess what `SELECT DISTINCT x FROM R` does?
Run the query on different input `R` tables to confirm your guess.
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

Consider the same query above. Try creating tables `R` and `S` that *violate* the conditions above.
If not possible, why?

**To be continued...**
