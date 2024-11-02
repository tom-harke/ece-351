syntax
 - in contrast to C, each case-item has an implicit `break`
 - a case-item has exactly one statement
    - use `begin`/`end` to bundle a sequence into 1 compound stmt

variants
 - case
 - casex
    - allows both `x` and `z` to be treated as don't-cares
    - don't use `casex` for synth -- it propagates x's
    - ok for testbenches
 - casez
    - eg: a case item of `2'b1?` matches all of
         `2'b10` `2'b11` `2'b1x` `2'b1z`
    - ?? can do the same with `case inside`

??? compares 0,1,x,y ??

modifiers
 - `priority` TODO
     - at least one case matches
     - at many match, take the first
     - allows synthesis
        - to treat unlisted conditions as don't-cares
        - smaller/faster
 - `unique`
     - at sim time a match must be found
     - at run time, exactly one match
     - synthesis is simpler
        - as earlier cases don't shadow later ones
        - check can be done in parallel
     - may use `default`
        - drops compiler check for non-existent matches
        - uniqueness still required
 - `inside`
    - TODO
    - seems to allow wildcard patterns like `0?1??`

eg priority
```
module decoder (
  output logic [3:0] y,
  input  logic [1:0] a
);

  always_comb
    priority case (a)
      0 : y = 1;
      1 : y = 2;
      2 : y = 4;
    endcase

endmodule
```

What if a = 3?
 - Simulation: warning
 - Synthesis: OK
