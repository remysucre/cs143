---
title: "HW 2: Dependencies"
---

*This homework involves coding to help you understand how the algorithms work. You should be able to run the algorithms by hand during the quiz.*

🤖 Find out how to create a [set](https://docs.python.org/3/tutorial/datastructures.html#sets) in Python.

🤖 Find out how to check if a set is contained in another set,
 and how to take the union of two sets in Python.

🤖 Find out how to compute the [power set](https://en.wikipedia.org/wiki/Power_set) of a set in Python
(my favorite way to do that is by [using a bit vector](https://stackoverflow.com/q/62336668/3694032)).

---

Implement the closure algorithm in Python:

```python
def closure(fds, xs):
  """Compute the closure of xs over fds

  Arguments:
  fds: the set of input fds
  xs: the set of attributes to take closure of
  """
```

Each FD $X \to Y$ is represented as a pair `(X, Y)`,
 where each of `X` and `Y` is a set of strings. 
For example, `({'x1', 'x2'}, {'y1', 'y2'})` represents the FD $\{x_1, x_2\} \to \{y_1, y_2\}$.
The argument `fds` is a list of such pairs, and the argument `xs` is a set of strings.

The algorithm in the slides/notes loops over all input FDs in each iteration.
An optimization is to discard an FD as soon as it successfully applies.
Why is this optimization correct?
In other words, why do we never have to apply the same FD twice?

**Challenge**: what is the asymptotic complexity of closure computation?
Can you find an input that will result in the worst case complexity?
What about the best case complexity?

---

Implement the algorithm to check if an FD $\varphi$ follows from a set of FDs $\Phi$:

```python
def check(fds, fd):
  """Check if fd follows from fds"""
```

where `fds` is a list of FDs represented as before, and `fd` is one single FD.

---

Run the `check` algorithm above by hand to prove the Armstrong axioms:

- $Y \subseteq X \implies X \to Y$
- $\{X \to Y\} \vdash X\cup Z \to Y\cup Z$
- $\{X \to Y, Y \to Z\} \vdash X \to Z$

---

Write a function to check if a given set of attributes $X$ is a superkey, i.e.,
 if $X \to \Sigma$ where $\Sigma$ is the set of all table attributes.
The function takes 3 arguments: the set $X$, the FDs $\Phi$ that hold over the table,
 and the set of all table attributes $\Sigma$.

---

The decomposition algorithm shown in class looks for nontrivial FDs $X \to Y$
 such that $X$ does not contain a key.
This is expensive to implement, as we would have to try each possible pair of $X$
 and $Y$, and there are $(2^n)^2 = 2^{2n}$ many such pairs.
Specifically, we would implement the following nested loop:

```python
for xs in powerset(sigma):
  for ys in powerset(sigma):
    if not contains(xs, ys) and not isKey(xs, fds, sigma):
      ...
```

Instead, we can just look for $X$ s.t. $X^+ \neq X$ and $X^+$ does not cover all table attributes:

```python
def decompose(R):
  S = attributes of R
  find X s.t. X+ != X & X+ != S
  if not found:
    return
  else:
    break R into X+, R2(S - (X+ - X))
    decompose(R1) 
    decompose(R2)
```

Prove this optimized algorithm also correctly decomposes the table.
Specifically, we can find a set $X$ satisfying the conditions above
 if and only if we can find an FD satisfying the conditions in the original algorithm.

Implement the optimized algorithm in Python:
 the function takes as inputs a set of table arguments `S`
 and a list of functional dependencies `fd`,
 and returns a list containing
 the attribute sets of the decomposed tables.

---

**Challenge**:
the decomposition algorithm is *nondeterministic*!
Its result depends on the order of which FDs get picked
 first to guide the decomposition.
Construct an example that would can produce
 different result tables after decomposition.
Hint: you need 2 FDs such that decomposing along one of them
 would "destroy" the other FD.
Another hint: for one of these FDs, try having multiple attributes
 on the left.

---

A decomposition is *lossless* if joining the decomposed tables produces exactly the original table.
Prove that decomposing with both functional dependencies and conditional independence are lossless.
Specifically, every time we break up a table along an FD, joining the resulting tables recovers the original,
 and similar for when we break up a table along an independence.

---

Consider the converse to the previous problem: given a table $t$ over attributes $x, y, z$,
 suppose we break it up into two tables $t_1$, $t_2$ as follows:

```sql
create table t1 as select distinct(x, y) from t;
create table t2 as select distinct(x, z) from t;
```

If $t_1 \Join_{t_1.x = t_2.x} t_2 = t$, does that imply either $x\to y$ or $x \to z$ must hold over $t$?
Or does that imply $y \perp z \mid x$?

---

Consider a table over attributes $x, a_1, a_2, \ldots, a_k$, where $x\to a_i$ for each $i$.
How many tables would we get if we decompose according to the FDs?
If every decomposed tables has $n$ rows, how many rows are there in the original table?

---

Consider a table over attributes $x, a_1, a_2, \ldots, a_k$, where $a_i$ are all conditionally independent given $x$.
How many tables would we get if we decompose according to independence?
If every decomposed tables has $n$ rows, how many rows are there in the original table?

---

**Challenge** (won't be on the quiz):
If a conditional independence $X \perp Y \mid Z$ holds over a table and $X \cup Y \cup Z$ cover all table attributes,
 we say there is a *multi-valued dependency* (MVD) $Z \twoheadrightarrow X$ (or $Z \twoheadrightarrow Y$).
Prove that MVD generalizes FD, i.e., $Z \to X$ implies $Z \twoheadrightarrow X$.
Do the Armstrong Axioms also hold for MVDs?
