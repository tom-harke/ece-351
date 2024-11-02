
stages
 - preponed
    - values are sampled for assertions
 - active
    - handles regular & non-blocking events in the active region
 - observed
    - assertions executed with values from preponed
 - reactive
    - handles regular & non-blocking events in the reactive region
 - postponed
    - handle monitor events

