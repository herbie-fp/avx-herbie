#lang racket/base

(require racket/system
         racket/list)

(provide installer)

;; Compiles avx-intrinsics.c into a shared library placed next to
;; main.rkt, so the platform file can load it by its own location
;; regardless of whether the package is installed at user or system
;; scope.
;;
;; The AVX intrinsics only build for x86_64, and only when a C
;; compiler is available; otherwise the build is skipped with a
;; notice and the platform falls back to Racket's own operations.

(define (installer collections-top-path this-collection-path user-specific?)
  (define (skip why)
    (eprintf "avx-herbie: skipping AVX intrinsics build (~a); the platform will fall back to Racket operations\n" why))

  (define (compile-intrinsics)
    (define gcc (find-executable-path "gcc"))
    (define (call-and-wait command)
      (define out (process command))
      ((fifth out) 'wait)
      (unless (eq? ((fifth out) 'status) 'done-ok)
        (for ([line (in-lines (first out))])
          (displayln line (current-output-port)))
        (for ([line (in-lines (fourth out))])
          (displayln line (current-error-port)))
        (eprintf "avx-herbie: compile failed; the platform will fall back to Racket operations\n")))

    (define lib-name (path-replace-extension "avx-intrinsics" (system-type 'so-suffix)))
    (define lib-location (build-path this-collection-path lib-name))
    (call-and-wait (format "~a ~a -mavx -shared -o ~a"
                           (path->string gcc)
                           (path->string (build-path this-collection-path "avx-intrinsics.c"))
                           (path->string lib-location))))

  (cond
    [(not (member (system-type) '(unix macosx)))
     (skip (format "unsupported system ~a" (system-type)))]
    [(not (eq? (system-type 'arch) 'x86_64))
     (skip (format "unsupported architecture ~a" (system-type 'arch)))]
    [(not (find-executable-path "gcc"))
     (skip "gcc not found")]
    [else (compile-intrinsics)]))
