#lang herbie/platform

;;; The default Racket platform, with reciprocal and reciprocal
;;; square root backed by the AVX approximate instructions from the
;;; `avx-intrinsics` shared library that this package compiles and
;;; installs next to this file. Falls back to Racket's own operations
;;; when that library cannot be loaded (for example on non-x86_64
;;; systems, or when no compiler was available at install time).
;;;
;;; The accelerated implementations trade accuracy for speed: `recip`
;;; and `rsqrt` use the hardware `rcp`/`rsqrt` instructions, which
;;; carry roughly 12 bits of precision.

(require math/flonum
         math/base
         ffi/unsafe
         racket/runtime-path)

(define-runtime-path avx-lib-path
  (path-replace-extension "avx-intrinsics" (system-type 'so-suffix)))

(define (load-avx name)
  (with-handlers ([exn:fail? (const #f)])
    (get-ffi-obj name (ffi-lib avx-lib-path) (_fun _double -> _double))))

(define recip.avx (load-avx "recip_f64"))
(define rsqrt.avx (load-avx "rsqrt_f64"))

(unless (and recip.avx rsqrt.avx)
  (eprintf "avx-herbie: AVX intrinsics library unavailable, using exact Racket operations\n"))

(define recip-impl (or recip.avx /))
(define rsqrt-impl (or rsqrt.avx (lambda (x) (/ 1 (sqrt x)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BOOLEAN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-representation <bool> #:cost 1)

(define-operations () <bool>
  [true  #:spec (TRUE)  #:impl (const true)  #:fpcore TRUE  #:cost 1]
  [false #:spec (FALSE) #:impl (const false) #:fpcore FALSE #:cost 1])

(define-operations ([x <bool>] [y <bool>]) <bool>
  [and #:spec (and x y) #:impl (lambda v (andmap values v)) #:cost 1]
  [or  #:spec (or x y)  #:impl (lambda v (ormap values v))  #:cost 1])

(define-operation (not [x <bool>]) <bool>
  #:spec (not x) #:impl not #:cost 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BINARY 64 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-representation <binary64> #:cost 1)

(define-operation (if.f64 [c <bool>] [t <binary64>] [f <binary64>]) <binary64>
  #:spec (if c t f) #:impl if-impl
  #:cost (if-cost 1))

(define-operations () <binary64>
  [PI.rkt       #:spec (PI)       #:impl (const pi)       #:fpcore PI       #:cost 1]
  [INFINITY.rkt #:spec (INFINITY) #:impl (const +inf.0)   #:fpcore INFINITY #:cost 1]
  [NAN.rkt      #:spec (NAN)      #:impl (const +nan.0)   #:fpcore NAN      #:cost 1])

(define-operations ([x <binary64>] [y <binary64>]) <bool>
  [=  #:spec (== x y) #:impl =  #:cost 1]
  [<  #:spec (< x y)  #:impl <  #:cost 1]
  [>  #:spec (> x y)  #:impl >  #:cost 1]
  [<= #:spec (<= x y) #:impl <= #:cost 1]
  [>= #:spec (>= x y) #:impl >= #:cost 1])

(define ((no-complex fun) . xs)
  (define res (apply fun xs))
  (if (real? res) res +nan.0))

(define-operation (-/1 [x <binary64>]) <binary64>
  #:spec (neg x) #:impl - #:fpcore (- x) #:cost 1)

(define-operations ([x <binary64>]) <binary64>
 [acos      #:spec (acos  x) #:impl (no-complex acos)  #:cost 1]
 [acosh     #:spec (acosh x) #:impl (no-complex acosh) #:cost 1]
 [asin      #:spec (asin  x) #:impl (no-complex asin)  #:cost 1]
 [asinh     #:spec (asinh x) #:impl (no-complex asinh) #:cost 1]
 [atan      #:spec (atan  x) #:impl (no-complex atan)  #:cost 1]
 [atanh     #:spec (atanh x) #:impl (no-complex atanh) #:cost 1]
 [ceiling   #:spec (ceil  x) #:impl ceiling            #:cost 1]
 [cos       #:spec (cos   x) #:impl cos                #:cost 1]
 [cosh      #:spec (cosh  x) #:impl cosh               #:cost 1]
 [exp       #:spec (exp   x) #:impl exp                #:cost 1]
 [abs       #:spec (fabs  x) #:impl abs                #:cost 1]
 [floor     #:spec (floor x) #:impl floor              #:cost 1]
 [log       #:spec (log   x) #:impl (no-complex log)   #:cost 1]
 [round     #:spec (round x) #:impl round              #:cost 1]
 [sin       #:spec (sin   x) #:impl sin                #:cost 1]
 [sinh      #:spec (sinh  x) #:impl sinh               #:cost 1]
 [sqrt      #:spec (sqrt  x) #:impl (no-complex sqrt)  #:cost 1]
 [tan       #:spec (tan   x) #:impl tan                #:cost 1]
 [tanh      #:spec (tanh  x) #:impl tanh               #:cost 1]
 [truncate  #:spec (trunc x) #:impl truncate           #:cost 1])

(define-operations ([x <binary64>] [y <binary64>]) <binary64>
 [+         #:spec (+ x y)         #:impl +                 #:cost 1]
 [-         #:spec (- x y)         #:impl -                 #:cost 1]
 [*         #:spec (* x y)         #:impl *                 #:cost 1]
 [/         #:spec (/ x y)         #:impl /                 #:cost 1]
 [atan/2    #:spec (atan2 x y)     #:impl (no-complex atan) #:cost 1]
 [max       #:spec (fmax x y)      #:impl max               #:cost 1]
 [min       #:spec (fmin x y)      #:impl min               #:cost 1]
 [expt      #:spec (pow x y)       #:impl (no-complex expt) #:cost 1]
 [remainder #:spec (remainder x y) #:impl remainder         #:cost 1])

;; `recip` and `rsqrt` accelerate reciprocal and reciprocal square
;; root with the AVX approximate instructions when the shared library
;; is available, and otherwise fall back to the exact operations.
(define-operation (recip [x <binary64>]) <binary64>
  #:spec (/ 1 x) #:impl recip-impl #:fpcore (recip x) #:cost 1)

(define-operation (rsqrt [x <binary64>]) <binary64>
  #:spec (/ 1 (sqrt x)) #:impl rsqrt-impl #:fpcore (rsqrt x) #:cost 1)

(define-operation (log/2 [x <binary64>] [y <binary64>]) <binary64>
  #:spec (/ (log x) (log y)) #:impl log #:fpcore (log x y) #:cost 1)

(define-operation (flsingle [x <binary64>]) <binary64>
  #:spec x #:impl flsingle #:fpcore (cast x) #:cost 1)
