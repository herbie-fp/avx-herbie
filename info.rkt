#lang info

(define collection "avx-herbie")
(define deps '("base"))
(define install-collection "install.rkt")
(define compile-omit-files '("install.rkt"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib" ("herbie" #:version "2.0")))
(define pkg-desc "Herbie plugin for avx accelerators")
(define version "1.0")
(define pkg-authors '("Jonas Regehr"))

(define herbie-plugin 'avx-herbie)

