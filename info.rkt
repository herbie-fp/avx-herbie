#lang info

(define collection "avx-herbie")
(define deps '("base" ("herbie" #:version "2.3")))
(define install-collection "install.rkt")
(define compile-omit-files '("install.rkt"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define pkg-desc "x86_64 AVX accelerators for Herbie")
(define version "1.1")
(define pkg-authors '("Jonas Regehr"))
