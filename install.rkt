#lang racket/base

(require racket/system)
(require racket/list)
(require setup/dirs)

(provide installer)

(define (installer collections-top-path this-collection-path user-specific?)
  
  (define (call-and-wait command)
    (define out (process command))
    ((fifth out) 'wait)
    (unless (eq? ((fifth out) 'status) 'done-ok)
      (for ([line (in-lines (first out))])
        (displayln line (current-output-port)))
      (for ([line (in-lines (fourth out))])
        (displayln line (current-error-port)))
      (error 'avx-accelerators "Error running ~a" command)))
  
  (define build-location (build-path this-collection-path))
  (define lib-name (path-replace-extension "avx-intrinsics.so" (system-type 'so-suffix)))
  (define lib-location (build-path (if user-specific? (find-user-lib-dir) (find-lib-dir)) lib-name))
  (call-and-wait (string-append "gcc " (path->string build-location) "\\avx-intrinsics.c -mavx -shared -o " (path->string lib-location)))
)