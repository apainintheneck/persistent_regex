# Benchmarking

---

## First Pass

Initially I assumed that the algorithm would be faster on both the Erlang and JavaScript targets because no caching was taking place for regexes on either platform. This turned out not to be the case.

- Commit: f8aa68de41741a3ce7b25f7a55ea0f8256767c35
- Gleam: 1.2.1
- Node.js: 22.4.0
- Erlang: 27.0

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

---

## Second Pass

I updated the number of regexes to include more of those from the `gleam/regex` tests and the [common_mark](https://github.com/mscharley/gleam-commonmark/commit/ea4770eae9be91b9d135e28c27799c7256c23ebd) library. The regexes in the `common_mark` library are often platform specific but they achieve the same goal and are similar lengths and complexity so I thought it'd be a good test.

- Commit: 9233ed604f204efa433f7a193035b76849ff4eae
- Gleam: 1.2.1
- Node.js: 22.4.0
- Erlang: 27.0

### Erlang

```console
$ gleam run
  Compiling persistent_regex
  Compiling bench
   Compiled in 1.02s
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
x1 regex strings        regex                       19067.3424          0.0474          0.0524          0.3988         30.9365          0.1011
x1 regex strings        persistent_regex           166562.3380          0.0053          0.0060          2.1184        131.5610          0.0122
x10 regex strings       regex                        1943.5685          0.4548          0.5145          0.9031          9.9341          0.7113
x10 regex strings       persistent_regex            18862.2440          0.0485          0.0530          0.2381         13.0762          0.0931
x100 regex strings      regex                         203.7703          4.6443          4.9074          5.3152          2.8267          5.2644
x100 regex strings      persistent_regex             1906.7968          0.4868          0.5244          0.7533          5.5787          0.6184
x1000 regex strings     regex                          20.2695         48.6569         49.3350         50.3676          0.9857         50.3676
x1000 regex strings     persistent_regex              189.8695          5.0279          5.2667          6.5729          3.1896          5.7742
```

The cached regexes seem to be an order of magnitude faster consistently regardless of the number of regexes.

### JavaScript

Caching regexes doesn't seem to help on Node.js in any meaningful way.

```console
$ gleam run --target javascript
  Compiling persistent_regex
  Compiling bench
   Compiled in 0.02s
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
x1 regex strings        regex                       16616.1650          0.0541          0.0601          3.7717         56.6585          0.0794
x1 regex strings        persistent_regex            14637.6075          0.0634          0.0683          0.8030         25.7331          0.0879
x10 regex strings       regex                        1736.4720          0.5279          0.5758          1.1660          6.3075          0.6878
x10 regex strings       persistent_regex             1500.6805          0.6110          0.6663          1.0968          5.8976          0.8292
x100 regex strings      regex                         168.0465          5.1654          5.9507          6.7137          3.4169          6.6086
x100 regex strings      persistent_regex              147.1994          6.2049          6.7935          7.2398          2.5027          7.2166
x1000 regex strings     regex                          16.8680         53.7798         59.2836         60.4718          2.5597         60.4718
x1000 regex strings     persistent_regex               14.9039         62.3612         67.0965         68.6988          2.1776         68.6988
```

This benchmark is tricky to read because whichever function is tested first tests a bit faster but ultimately it shows that caching doesn't help here.

### Conclusion

Caching is really only necessary on the Erlang side and not needed on JavaScript at all.