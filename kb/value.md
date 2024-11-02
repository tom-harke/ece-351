4 valued logic
| 0 | logic 0, Ground |
| 1 | logic 1, VDD    |
| X | don't know / undefined |
| Z | high impedance |

eg tri-state buffer
```
assign y = en ? a : 1'bz;
```

```
&│ 0 1 x z
─┼────────
0│ 0 0 0 0
1│ 0 1 x x
x│ 0 x x x
z│ 0 x x x
```
&│ 0 1 x z
─┼────────
0│ 0 0 0 0
1│ 0 1 x x
x│ 0 x x x
z│ 0 x x x
