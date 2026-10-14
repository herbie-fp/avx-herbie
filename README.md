# avx-herbie

x86_64 AVX accelerators for [Herbie](https://herbie.uwplse.org/).

This package provides a Herbie platform in which reciprocal and
reciprocal square root are evaluated with the AVX `rcp`/`rsqrt`
approximate instructions — roughly 12 bits of precision, in exchange
for speed. All other operations behave like the standard `racket`
platform.

Use it by pointing Herbie at the platform file:

```sh
herbie shell --platform <avx-herbie>/main.rkt
```

(Replace `<avx-herbie>` with the package's installed location.)

## Installation

```sh
raco pkg install avx-herbie
```

At install time the package compiles `avx-intrinsics.c` into a shared
library next to the platform file. This needs x86_64 and a C compiler
(`gcc`). On any other system the compile step is skipped with a
notice; the platform then still loads and works, falling back to
Racket's exact (slower) operations. Reinstalling the package rebuilds
the library.

The old `herbie/plugin` API this package was originally written
against was removed in Herbie 2.0's platform redesign; the package
now requires Herbie 2.3 or later and uses the platform language.
