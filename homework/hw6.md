---
title: "HW 6: Advanced Topics"
---

To practice on these problems, ask 🤖 to generate some random queries for you.

Make sure you know how to draw the *predicate graph* of a query:

- Make a node for every *table*
- If there is a predicate `R.blah = S.blah` in the `WHERE` clause, add an edge between `R` and `S`

Make sure you know how to check if two join queries are equivalent:

- For each distinct `R.x` table-attribute pair in the query, create a group containing just that pair
- For each predicate `R.x = S.y`, merge the group of `R.x` with that of `S.y`
- If the two queries end up with the same grouping at the end of this process, they are equivalent 

Make sure you know how to draw the *complete* predicate graph of a query:

- First, make the groups as above
- Then, for every pair `R.x, S.y` within the same group, add an edge `R, S` in the graph

Make sure you know how to check if a given query is acyclic:

- Draw the complete query graph as above
- Find any maximum spanning tree (MST) of the graph, where the weight on an edge is the number of distinct join predicates between them
- Create a new query Q' from the MST, creating $k$ predicates for each edge of weight $k$
- Check if Q' is equivalent to the original query Q using the method above

Make sure you know how to draw the *hypergraph* representing a query.

Make sure you know how to test acyclicity of the hypergraph by ear reduction.

Implement the instance-optimal join algorithm on the example shown in class, and compare its performance with an
 algorithm using pari-wise hash join.

**Challenge**: the general algorithm is called TreeTracker Join (TTJ), and works on any acyclic query.
Implement the TTJ algorithm from [this paper](https://dl.acm.org/doi/10.1145/3774325).
