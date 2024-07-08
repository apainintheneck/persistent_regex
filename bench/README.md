# Benchmarking

## First Pass

Initially I assumed that the algorithm would be faster on both the Erlang and JavaScript targets because no caching was taking place for regexes on either platform. This turned out not to be the case.

### Erlang

```console
$ gleam run
  Compiling bench
   Compiled in 0.52s
    Running bench.main
benching set x1 regex strings regex
benching set x1 regex strings persistent_regex
benching set x10 regex strings regex
benching set x10 regex strings persistent_regex
benching set x100 regex strings regex
benching set x100 regex strings persistent_regex
benching set x1000 regex strings regex
benching set x1000 regex strings persistent_regex
Input                   Function                           IPS             Min            Mean             Max             SD%             P99
x1 regex strings        regex                       85282.5173          0.0103          0.0117          2.2999        105.8547          0.0197
x1 regex strings        persistent_regex           619289.3542          0.0013          0.0016         10.5755       1671.7137          0.0020
x10 regex strings       regex                        9426.4882          0.0949          0.1060          0.4061         26.8891          0.3173
x10 regex strings       persistent_regex            90725.9352          0.0098          0.0110         15.1340        643.7065          0.0185
x100 regex strings      regex                         948.8463          0.9514          1.0539          1.5097          9.4825          1.3650
x100 regex strings      persistent_regex             9822.7417          0.0960          0.1018          0.2835          8.4096          0.1315
x1000 regex strings     regex                          95.7426          9.9907         10.4446         11.0730          2.2195         11.0730
x1000 regex strings     persistent_regex              985.8514          0.9570          1.0143          1.5465          5.0358          1.1902
```

As you can see, it is quite a bit faster once the regexes have been precomputed. The higher standard deviation probably has to do with this precomputation time.

### JavaScript

```console
$ gleam run --target javascript
   Compiled in 0.01s
    Running bench.main
benching set x1 regex strings regex
benching set x1 regex strings persistent_regex
benching set x10 regex strings regex
benching set x10 regex strings persistent_regex
benching set x100 regex strings regex
benching set x100 regex strings persistent_regex
benching set x1000 regex strings regex
benching set x1000 regex strings persistent_regex
Input                   Function                           IPS             Min            Mean             Max             SD%             P99
x1 regex strings        regex                      374047.5193          0.0020          0.0026         18.9715       1463.8945          0.0043
x1 regex strings        persistent_regex           373786.1488          0.0021          0.0026          3.3536        823.4975          0.0029
x10 regex strings       regex                       49682.4622          0.0179          0.0201          0.7767         86.7899          0.0292
x10 regex strings       persistent_regex            43777.7449          0.0207          0.0228          0.6391         77.2511          0.0314
x100 regex strings      regex                        5140.0109          0.1796          0.1945          0.6003         17.6592          0.3026
x100 regex strings      persistent_regex             4433.0792          0.2088          0.2255          0.5955         16.6849          0.5206
x1000 regex strings     regex                         512.6193          1.8097          1.9507          2.5443          6.1878          2.3409
x1000 regex strings     persistent_regex              442.8119          2.0917          2.2582          2.9519          5.8432          2.6989
```

Surprisingly it is actually slower with the JavaScript cache here which is very interesting. Clearly some amount of caching is already taking place in the v8 JavaScript runtime that Node.js is built on top of.

### Conclusion

It might not even be worth caching the JavaScript regexes at all. I could just alias the `persistent_regex.from_string` method so that it calls the `regex.from_string` method directly instead. I also think it'd be helpful to test more varied regexes to see if that ends up making the Erlang approach less convincing. It'd also be nice to add the ability to clear the cache for testing purposes (that'd have to be well documented though).