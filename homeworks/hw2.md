---
title: "HW 2: Dependencies"
---

🤖 Find out how to create a [set](https://docs.python.org/3/tutorial/datastructures.html#sets) in Python.

🤖 Find out how to check if a set is contained in another set,
 and how to take the union of two sets in Python.

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

**To be continued...**
