Examples
```
enum {
  RESET,
  S[5],
  W[6:9]
} state;
```

By default, has counter, assigns next, and increments.
Can override
```
enum {
  ONE  =  1,
  FIVE =  5,
  TEN  = 10
} state;
```

beware:
 - don't override with same value used elsewhere (even if implicitly assigned)

know:
 - can be any type default type is `int`
 - can assign to (vector containing) x or z
    - increment won't work

```
enum bit {TRUE, FALSE} Boolean;
enum logic [1:0] {WAITE, LOAD, READY} state;
enum logic [2:0] {
  WAITE = 3'b001,
  LEAD  = 3'b010,
  READY = 3'b100
} onehot;
```

methods to modify-in-place an enum object
  .first
  .last
  .next(n)
     move ahead n
     n is optional, default to 1
  .prev(n)
     move back n
  .num
     cardinality of type
  .name
     string name of current value
