syntax is
```
MODULE_NAME #(PARAMETER_VALUES) INSTANCE_NAME (CONNECTIONS);
```

connections may be made by
 - order
 - name
    - `.NAME` if same name is used in both module definition and instance
    - `.*` for all ports having common name
    - `.NAME1(NAME2)`
