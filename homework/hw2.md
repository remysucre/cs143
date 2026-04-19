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

<details>
<summary>Solution</summary>

```python
def closure(fds, xs):
    result = set(xs)  # copy so we don't mutate the caller's set
    remaining = fds
    changed = True
    while changed:
        changed = False
        next_remaining = []
        for (x, y) in remaining:
            if x.issubset(result):
                new_attrs = y - result
                if new_attrs:
                    result |= new_attrs
                    changed = True
                # discard: FD already fully applied, will never add new attrs
            else:
                next_remaining.append((x, y))
        remaining = next_remaining
    return result
```

**Why the optimization is correct**: The closure $X^+$ only grows monotonically — once an attribute is added, it is never removed. If $X \to Y$ fires (because $X \subseteq X^+$), then $Y$ is added to $X^+$. The FD can only add attributes from $Y$, and those are now already in $X^+$. So applying it again can never add anything new. It is safe to discard it.

**Asymptotic complexity**: Let $n = |\Sigma|$ be the number of attributes and $m$ be the number of FDs. Each iteration of the while loop adds at least one new attribute to `result`, so it runs at most $n$ times. Each iteration scans up to $m$ FDs, and each subset check costs $O(n)$. Total: $O(mn^2)$.

**Worst case**: Use $n$ attributes $a_0, \ldots, a_{n-1}$ plus one extra attribute $p$ never added to `result`.
$n/2$ "chain" FDs use a sliding window: FD$_i = \{a_i, \ldots, a_{i+n/2-1}\} \to \{a_{i+n/2}\}$, listed in reverse so only one fires per round. Add $m - n/2$ dummy FDs each with LHS of size $n/2$ containing $p$ (so they never fire but are checked every round).
Overall, the algorithms needs to run for $n/2$ rounds, checking $O(m)$ FDs per round, with each check taking $O(n)$ time.

**Best case**: If all FDs has a singleton LHS and none of them apply, then the algorithm terminates in one round in $O(m)$ time.

</details>

---

Implement the algorithm to check if an FD $\varphi$ follows from a set of FDs $\Phi$:

```python
def check(fds, fd):
  """Check if fd follows from fds"""
```

where `fds` is a list of FDs represented as before, and `fd` is one single FD.

<details>
<summary>Solution</summary>

An FD $X \to Y$ follows from $\Phi$ if and only if $Y \subseteq X^+$ (the closure of $X$ under $\Phi$):

```python
def check(fds, fd):
    x, y = fd
    return y.issubset(closure(fds, x))
```

If $Y \subseteq X^+$, then starting from $X$ we can derive $Y$ using the FDs in $\Phi$, so $X \to Y$ holds in every table satisfying $\Phi$.

</details>

---

Run the `check` algorithm above by hand to prove the Armstrong axioms:

- $Y \subseteq X \implies X \to Y$
- $\{X \to Y\} \vdash X\cup Z \to Y\cup Z$
- $\{X \to Y, Y \to Z\} \vdash X \to Z$

<details>
<summary>Solution</summary>

**Reflexivity** ($Y \subseteq X \implies X \to Y$):

`check([], (X, Y))` computes `closure([], X) = X`. Since $Y \subseteq X$, `Y.issubset(X)` is `True`. ✓

**Augmentation** ($\{X \to Y\} \vdash X \cup Z \to Y \cup Z$):

`check([(X, Y)], (X∪Z, Y∪Z))` computes `closure([(X, Y)], X∪Z)`:
- Start: $X \cup Z$.
- $X \to Y$ fires (since $X \subseteq X \cup Z$), adding $Y$. Result: $X \cup Y \cup Z$.
- No more FDs fire.

Since $Y \cup Z \subseteq X \cup Y \cup Z$, returns `True`. ✓

**Transitivity** ($\{X \to Y, Y \to Z\} \vdash X \to Z$):

`check([(X,Y),(Y,Z)], (X, Z))` computes `closure([(X,Y),(Y,Z)], X)`:
- Start: $X$.
- $X \to Y$ fires, adding $Y$. Result: $X \cup Y$.
- $Y \to Z$ fires, adding $Z$. Result: $X \cup Y \cup Z$.

Since $Z \subseteq X \cup Y \cup Z$, returns `True`. ✓

</details>

---

Write a function to check if a given set of attributes $X$ is a superkey, i.e.,
 if $X \to \Sigma$ where $\Sigma$ is the set of all table attributes.
The function takes 3 arguments: the set $X$, the FDs $\Phi$ that hold over the table,
 and the set of all table attributes $\Sigma$.

<details>
<summary>Solution</summary>

$X$ is a superkey if and only if $\Sigma = X^+$:

```python
def is_superkey(xs, fds, sigma):
    return closure(fds, xs) == sigma
```

</details>

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

<details>
<summary>Solution</summary>

**Proof of equivalence**:

We want to show: there exists a nontrivial FD $X \to Y$ with $X$ not a superkey $\iff$ there exists $X$ with $X^+ \neq X$ and $X^+ \neq \Sigma$.

($\Rightarrow$) Suppose $X \to Y$ is nontrivial ($Y \not\subseteq X$) and $X$ is not a superkey ($X^+ \neq \Sigma$). Then $X^+$ contains $Y \not\subseteq X$, so $X^+ \neq X$. And $X^+ \neq \Sigma$ by assumption. So $X$ satisfies the conditions.

($\Leftarrow$) Suppose $X^+ \neq X$ and $X^+ \neq \Sigma$. Let $Y = X^+ \setminus X$. Then $X \to Y$ follows from the FDs (by definition of closure), $Y \not\subseteq X$ (nontrivial), and $X^+ \neq \Sigma$ means $X$ is not a superkey.

The two conditions are equivalent, so the optimized algorithm finds a violating $X$ exactly when the original finds a violating FD. ∎

**Implementation**:

```python
from itertools import combinations

def powerset(s):
    lst = list(s)
    return [frozenset(c) for r in range(len(lst) + 1) for c in combinations(lst, r)]

def decompose(S, fds):
    for X in powerset(S):
        Xplus = closure(fds, X) & S  # restrict closure to current schema
        if Xplus != X and not S.issubset(Xplus):
            R1 = Xplus
            R2 = S - (Xplus - X)
            return decompose(R1, fds) + decompose(R2, fds)
    return [S]
```

</details>

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

<details>
<summary>Solution</summary>

Let $R(A, B, C, D)$ with FDs: $\{A \to B,\ BC \to D\}$.

**Key analysis**: $A^+ = \{A, B\}$. $(AC)^+ = \{A, B, C, D\} = \Sigma$, so $AC$ is a key. Both $A \to B$ and $BC \to D$ are violations (neither $A$ nor $BC$ is a superkey).

**Path 1** — decompose along $A \to B$:

- $A^+ = \{A, B\}$, so $R_1 = \{A, B\}$, $R_2 = \Sigma - (\{A,B\} - \{A\}) = \{A, C, D\}$.
- In $R_2 = \{A, C, D\}$: $BC \to D$ no longer applies ($B \notin R_2$). No violations.
- **Result**: $[\{A,B\},\ \{A,C,D\}]$

**Path 2** — decompose along $BC \to D$:

- $(BC)^+ = \{B, C, D\}$, so $R_1 = \{B, C, D\}$, $R_2 = \Sigma - (\{B,C,D\} - \{B,C\}) = \{A, B, C\}$.
- In $R_2 = \{A, B, C\}$: $A \to B$ applies. $A^+ = \{A, B\} \neq R_2$. Decompose: $R_{21} = \{A, B\}$, $R_{22} = \{A, C\}$.
- **Result**: $[\{B,C,D\},\ \{A,B\},\ \{A,C\}]$

The two paths produce genuinely different tables. Notice that $BC \to D$ is "lost" in Path 1 — it does not hold within $\{A,B\}$ or $\{A,C,D\}$.

</details>

---

A decomposition is *lossless* if joining the decomposed tables produces exactly the original table.
Prove that decomposing with both functional dependencies and conditional independence are lossless.
Specifically, every time we break up a table along an FD, joining the resulting tables recovers the original,
 and similar for when we break up a table along an independence.

<details>
<summary>Solution</summary>

**Note**: these are tricky proofs. For the quiz, you only need to understand what lossless decomposition means, and that both decomposing along FDs and indepdence are lossless. 
The best way to gain intuition is to try out a few examples, decompose them, and join the results back together (🤖).

**FD case**: Suppose $X \to Y$ holds in $R$ over schema $\Sigma$. Decompose into $R_1 = \pi_{XY}(R)$ and $R_2 = \pi_{X(\Sigma \setminus Y)}(R)$. We show $R_1 \Join R_2 = R$.

- $R \subseteq R_1 \Join R_2$: For any $t \in R$, $t[XY]$ denotes the projection of $t$ onto attributes $X \cup Y$ (the tuple-level analogue of `SELECT X, Y`). So $t[XY] \in R_1$ and $t[X(\Sigma \setminus Y)] \in R_2$, so $t \in R_1 \Join R_2$.

- $R_1 \Join R_2 \subseteq R$: Take any $u \in R_1 \Join R_2$. Then there exist $t_1, t_2 \in R$ with $t_1[XY] = u[XY]$ and $t_2[X(\Sigma \setminus Y)] = u[X(\Sigma \setminus Y)]$, and $t_1[X] = t_2[X]$. By the FD $X \to Y$: since $t_2[X] = t_1[X]$, we have $t_2[Y] = t_1[Y] = u[Y]$. So $t_2$ agrees with $u$ on all of $\Sigma$, meaning $u = t_2 \in R$. ∎

**CI case**: Suppose $Y \perp Z \mid X$ holds in $R$ (where $\Sigma = XYZ$). Decompose into $R_1 = \pi_{XY}(R)$ and $R_2 = \pi_{XZ}(R)$. We show $R_1 \Join R_2 = R$.

- $R \subseteq R_1 \Join R_2$: Same argument as above.

- $R_1 \Join R_2 \subseteq R$: Take any $u \in R_1 \Join R_2$. Then there exist $t_1, t_2 \in R$ with $t_1[XY] = u[XY]$ and $t_2[XZ] = u[XZ]$, and $t_1[X] = t_2[X] = u[X]$. By $Y \perp Z \mid X$: for the value $x = u[X]$, the set of $(y,z)$ pairs in $R$ is exactly $Y_x \times Z_x$ (all combinations). Since $t_1[Y] = u[Y] \in Y_x$ and $t_2[Z] = u[Z] \in Z_x$, the pair $(u[Y], u[Z])$ is in $Y_x \times Z_x$, so there exists $t \in R$ with $t[X] = u[X]$, $t[Y] = u[Y]$, $t[Z] = u[Z]$. Thus $u \in R$. ∎

</details>

---

Consider the converse to the previous problem: given a table $t$ over attributes $x, y, z$,
 suppose we break it up into two tables $t_1$, $t_2$ as follows:

```sql
create table t1 as select distinct(x, y) from t;
create table t2 as select distinct(x, z) from t;
```

If $t_1 \Join_{t_1.x = t_2.x} t_2 = t$, does that imply either $x\to y$ or $x \to z$ must hold over $t$?
Or does that imply $y \perp z \mid x$?

<details>
<summary>Solution</summary>

The lossless join **does** imply $y \perp z \mid x$, but does **not** necessarily imply $x \to y$ or $x \to z$.

**Proof that lossless join implies $y \perp z \mid x$**:

The join produces every tuple $(x, y, z)$ such that $(x, y) \in t_1$ and $(x, z) \in t_2$, i.e., every $(x, y, z)$ where $y$ appears with $x$ in $t$ and $z$ appears with $x$ in $t$. For the join to equal $t$ (no spurious tuples), it must be that for every $x$-value, if $y \in Y_x$ and $z \in Z_x$ then $(x, y, z) \in t$. This means the set of $(y, z)$ pairs for each $x$ is exactly $Y_x \times Z_x$ — which is precisely $y \perp z \mid x$.

**Counterexample showing $x \to y$ need not hold**:

$$t = \{(1, 1, 1),\ (1, 2, 1),\ (1, 1, 2),\ (1, 2, 2)\}$$

Here $x = 1$ has two $y$-values and two $z$-values, so $x \to y$ and $x \to z$ both fail. But $Y_1 \times Z_1 = \{1,2\} \times \{1,2\}$ equals the set of $(y,z)$ pairs in $t$, so $y \perp z \mid x$ holds and the join is lossless.

**Summary**: Lossless join $\iff$ $y \perp z \mid x$. FDs are a special case where $|Y_x| = 1$ (for $x \to y$) or $|Z_x| = 1$ (for $x \to z$).

</details>

---

Consider a table over attributes $x, a_1, a_2, \ldots, a_k$, where $x\to a_i$ for each $i$.
How many tables would we get if we decompose according to the FDs?
If every decomposed tables has $n$ rows, how many rows are there in the original table?

<details>
<summary>Solution</summary>

Since $x \to a_i$ for each $i$, the closure $x^+ = \{x, a_1, \ldots, a_k\} = \Sigma$. So $x$ is already a superkey — the table is in BCNF and the decomposition algorithm terminates immediately with **1 table** (no decomposition needed).

</details>

---

Consider a table over attributes $x, a_1, a_2, \ldots, a_k$, where $a_i$ are all conditionally independent given $x$.
How many tables would we get if we decompose according to independence?
If every decomposed tables has $n$ rows, how many rows are there in the original table?

<details>
<summary>Solution</summary>

Each CI $a_i \perp \{a_1,\ldots,a_k\} \setminus \{a_i\} \mid x$ lets us split off $(x, a_i)$ from the rest. Applying this $k-1$ times yields **$k$ tables**: $(x, a_1),\ (x, a_2),\ \ldots,\ (x, a_k)$.

If each $(x, a_i)$ table has $n$ rows, there are $n$ distinct $(x, a_i)$ pairs. In the simplest case — one $x$-value with $n$ values of each $a_i$ — the original table is the full cross product, giving $n^k$ rows. More generally, if there are $d$ distinct $x$-values each with $n/d$ values per $a_i$, the original has $d \cdot (n/d)^k = n^k / d^{k-1}$ rows.

The key contrast with the FD case: FDs force $x$ to be a key, so the original has $n$ rows; CIs allow each $x$-value to pair with many $a_i$-values, so the original can have up to **$n^k$ rows**.

</details>

---

**Challenge** (won't be on the quiz):
If a conditional independence $X \perp Y \mid Z$ holds over a table and $X \cup Y \cup Z$ cover all table attributes,
 we say there is a *multi-valued dependency* (MVD) $Z \twoheadrightarrow X$ (or $Z \twoheadrightarrow Y$).
Prove that MVD generalizes FD, i.e., $Z \to X$ implies $Z \twoheadrightarrow X$.
Do the Armstrong Axioms also hold for MVDs?

<details>
<summary>Solution</summary>

**MVD generalizes FD**:

Let $\Sigma = X \cup Y \cup Z$ (disjoint). Suppose $Z \to X$ holds. We want to show $X \perp Y \mid Z$, i.e., for each value $z$, the set of $(x, y)$ pairs equals $X_z \times Y_z$.

Fix a value $z$. By $Z \to X$, every tuple with that $z$-value has the same $x$-value — call it $x_0$. So $X_z = \{x_0\}$ (a singleton). The set of $(x, y)$ pairs is $\{(x_0, y) : y \in Y_z\} = \{x_0\} \times Y_z = X_z \times Y_z$.

Since this holds for every $z$, $X \perp Y \mid Z$ holds, i.e., $Z \twoheadrightarrow X$. ∎

FDs are the special case of MVDs where $|X_z| = 1$ for every $z$.

**Armstrong Axioms for MVDs**:

1. **Reflexivity**: if $X \subseteq Z$, then given $Z$, $X$ is determinsitic and therefore independent from $Y$, so $Z \twoheadrightarrow X$.

2. **Augmentation**: $Z \twoheadrightarrow X$ means $X \perp Y \mid Z$ for some $Y$. To simplify, let's assume $X, Y, Z$ do not overlap.
Then each attribute $w$ in $W$ can be only in 1 of the 3 sets. If $w \in Z$, then $X$ and $Y$ are still independent after adding $w$;
if $w \in X$, then adding $w$ to $X$ has no effect, and similarly for $Y$.

See [@fagin1977] for rigorous proofs, including one for transitivity, and more details.

</details>

## References
