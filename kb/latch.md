synthesis infers a latch in an `always` for variables that have partial assignments.

Can happen with
 - if
 - case

```
// 3-to-1 mux
always
  case (sel)
    2'b00: y=a;
    2'b01: y=b;
    2'b10: y=c;
    // implicit/unused 2'b11 causes latch
  endcase
```

```
always
  case (mode)
    ADD: add_result = a+b;
    SUB: sub_result = a-b;
  endcase
```

Avoid by
 - specifying all branches
 - adding `default`
 - use a pre-case assignment of default value
 - use `unique` and `priority` modifiers
   - TODO: what does `priority` mean?
