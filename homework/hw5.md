---
title: "HW 5: Indexes"
---

The focus of this homework is to make sure you understand how the two main data structures,
B+ Trees and Bloom Filters, work.
The best way to understand them is to implement them,
 but this time we don't have a lot of time,
 so you'll do the second best way: run them by hand.

There are no specific questions, but you should get as much practice as possible
 running the algorithm with different inputs.

For B+ Trees, you should compare your simulation with https://bptvisualizer.netlify.app

Some examples: 

- Try inserting the numbers 1 to 10 (or even more), and in reverse.
- Generate some random numbers and insert them.
- Try to make an internal node overflow, figure out what's the minimum number of insertions you need
- Make sure you understand how splitting a leaf node differs from splitting an internal one
- Do a point query (search for a single number)
- Do a range query (search for numbers falling in a range)
- Can you manage to fill every single slot in the tree?

**Challenge**: 
It's actually impossible to end up with the "Initial example" in the web tool 
 by inserting numbers. Do you see why?

**Challenge**:
Implement the B+ Tree data structure and compare against the web demo.


For Bloom filters, it's actually not too hard to implement.
Use AI to figure out what size you need for the bit vector
 and what (and how many) hash functions you need.
These two numbers will depend on a target false positive rate,
 you can set this to 0.1 percent.
Then, implement the Bloom filter data structure and try inserting some values to it.

You can also set a dummy hash function and an arbitrary size,
 then practice insertion/query by hand,
 and compare your simulation with the implementation.

**Challenge**:
[This](https://save-buffer.github.io/bloom_filter.html)
 is an excellent blog post on how to further improve Bloom filter performance
 by thinking about memory hierarchy.
With the help of AI, reproduce the experiments on your computer.

## Solution: Bloom filter in Python

```python
import math
import hashlib

# Pick the bit-vector size m and number of hash functions k
# from the expected number of items n and target false positive rate p.
def make_bloom(n, p):
    m = math.ceil(-(n * math.log(p)) / (math.log(2) ** 2))
    k = max(1, round((m / n) * math.log(2)))
    bits = [0] * m
    return {"bits": bits, "m": m, "k": k}

# Use double hashing: derive k indices from two independent hashes.
# h(i) = (h1 + i * h2) mod m
def indices(filt, value):
    data = str(value).encode()
    h1 = int.from_bytes(hashlib.md5(data).digest(), "big")
    h2 = int.from_bytes(hashlib.sha1(data).digest(), "big")
    m = filt["m"]
    return [(h1 + i * h2) % m for i in range(filt["k"])]

def insert(filt, value):
    for idx in indices(filt, value):
        filt["bits"][idx] = 1

# Returns False if definitely absent, True if possibly present.
def query(filt, value):
    return all(filt["bits"][idx] for idx in indices(filt, value))

# Demo
if __name__ == "__main__":
    filt = make_bloom(n=1000, p=0.001)
    print("m =", filt["m"], "bits, k =", filt["k"], "hash functions")

    for x in range(1000):
        insert(filt, x)

    # No false negatives: every inserted item is found.
    assert all(query(filt, x) for x in range(1000))

    # Estimate the false positive rate on items never inserted.
    fp = sum(query(filt, x) for x in range(1000, 11000))
    print("measured false positive rate:", fp / 10000)
```
