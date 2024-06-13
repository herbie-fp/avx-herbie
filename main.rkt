#lang racket/base

(require herbie/plugin 
        ffi/unsafe)

(eprintf "Loading avx-accelerators...\n")
(module test racket/base)

(define recip_f32 (get-ffi-obj "recip_f32" "avx-intrinsics" (_fun _float -> _float)))
(define recip_f64 (get-ffi-obj "recip_f64" "avx-intrinsics" (_fun _double -> _double)))
(define rsqrt_f32 (get-ffi-obj "rsqrt_f32" "avx-intrinsics" (_fun _float -> _float)))
(define rsqrt_f64 (get-ffi-obj "rsqrt_f64" "avx-intrinsics" (_fun _double -> _double)))

(define-accelerator (avx-recip real) real (lambda (x) (/ 1 x)))
(define-accelerator (avx-rsqrt real) real (lambda (x) (/ 1 (sqrt x))))

(define-accelerator-impl avx-recip recip.f32 (binary32) binary32 recip_f32)
(define-accelerator-impl avx-recip recip.f64 (binary64) binary64 recip_f64)
(define-accelerator-impl avx-rsqrt rsqrt.f32 (binary32) binary32 rsqrt_f32)
(define-accelerator-impl avx-rsqrt rsqrt.f64 (binary64) binary64 rsqrt_f64)

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco docs <<name>>
;;
;; For your convenience, we have included LICENSE-MIT and LICENSE-APACHE files.
;; If you would prefer to use a different license, replace those files with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html
