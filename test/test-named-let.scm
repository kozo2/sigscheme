;;  Filename : test-named-let.scm
;;  About    : unit test for R5RS named let
;;
;;  Copyright (C) 2005-2006 YAMAMOTO Kengo <yamaken AT bp.iij4u.or.jp>
;;  Copyright (c) 2007-2008 SigScheme Project <uim-en AT googlegroups.com>
;;
;;  All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without
;;  modification, are permitted provided that the following conditions
;;  are met:
;;
;;  1. Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;;  2. Redistributions in binary form must reproduce the above copyright
;;     notice, this list of conditions and the following disclaimer in the
;;     documentation and/or other materials provided with the distribution.
;;  3. Neither the name of authors nor the names of its contributors
;;     may be used to endorse or promote products derived from this software
;;     without specific prior written permission.
;;
;;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
;;  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;;  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;;  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
;;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(load "./test/unittest.scm")

(define *test-track-progress* #f)
(define tn test-name)


;;
;; named let
;;
(tn "named let invalid form")
;; bindings and body required
(assert-error  (tn) (lambda ()
                      (let loop)))
(assert-error  (tn) (lambda ()
                      (let loop ())))
(assert-error  (tn) (lambda ()
                      (let loop ((a)))))
(assert-error  (tn) (lambda ()
                      (let loop ((a 1)))))
(assert-error  (tn) (lambda ()
                      (let loop (a 1))))
(assert-error  (tn) (lambda ()
                      (let loop a)))
(assert-error  (tn) (lambda ()
                      (let loop #())))
(assert-error  (tn) (lambda ()
                      (let loop #f)))
(assert-error  (tn) (lambda ()
                      (let loop #t)))
;; bindings must be a list
(assert-error  (tn) (lambda ()
                      (let loop a 'val)))
(if (provided? "siod-bugs")
    (assert-equal? (tn)
                   'val
                   (let loop #f 'val))
    (assert-error  (tn) (lambda ()
                          (let loop #f 'val))))
(assert-error  (tn) (lambda ()
                      (let loop #() 'val)))
(assert-error  (tn) (lambda ()
                      (let loop #t 'val)))
;; each binding must be a 2-elem list
(assert-error  (tn) (lambda ()
                      (let loop (a 1))))
(if (provided? "siod-bugs")
    (assert-equal? (tn)
                   'val
                   (let loop ((a)) 'val))
    (assert-error  (tn)
                   (lambda ()
                     (let loop ((a)) 'val))))
(assert-error  (tn)
               (lambda ()
                 (let loop ((a 1 'excessive)) 'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((a 1) . (b 2)) 'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((a . 1)) 'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((a  1)) . a)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((a  1)) 'val . a)))
(assert-error  (tn)
               (lambda ()
                 (let loop (1) #t)))

(tn "named let binding syntactic keyword")
(assert-equal? (tn) 1 (let loop ((else 1)) else))
(assert-equal? (tn) 2 (let loop ((=> 2)) =>))
(assert-equal? (tn) 3 (let loop ((unquote 3)) unquote))
(assert-error  (tn) (lambda () else))
(assert-error  (tn) (lambda () =>))
(assert-error  (tn) (lambda () unquote))

(tn "named let env isolation")
(assert-error  (tn)
               (lambda ()
                 (let loop ((var1 1)
                            (var2 var1))
                   'result)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((var1 var2)
                            (var2 2))
                   'result)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((var1 var2)
                            (var2 var1))
                   'result)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((var1 1)
                            (var2 loop))
                   'result)))
;; 'loop' is not bound at outer env
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'result)
                 (loop)))
(assert-equal? (tn)
               '(#f #f #f)
               (let loop ((var1 (symbol-bound? 'loop))
                          (var2 (symbol-bound? 'loop))
                          (var3 (symbol-bound? 'loop)))
                 (list var1 var2 var3)))
(assert-equal? (tn)
               '(#f #f #f)
               (let loop ((var1 (symbol-bound? 'var1))
                          (var2 (symbol-bound? 'var1))
                          (var3 (symbol-bound? 'var1)))
                 (list var1 var2 var3)))
(assert-equal? (tn)
               '(#f #f #f)
               (let loop ((var1 (symbol-bound? 'var2))
                          (var2 (symbol-bound? 'var2))
                          (var3 (symbol-bound? 'var2)))
                 (list var1 var2 var3)))
(assert-equal? (tn)
               '(#f #f #f)
               (let loop ((var1 (symbol-bound? 'var3))
                          (var2 (symbol-bound? 'var3))
                          (var3 (symbol-bound? 'var3)))
                 (list var1 var2 var3)))

(tn "named let internal definitions lacking sequence part")
;; at least one <expression> is required
(assert-error  (tn)
               (lambda ()
                 (let loop  ()
                   (define var1 1))))
(assert-error  (tn)
               (lambda ()
                 (let loop  ()
                   (define (proc1) 1))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define var1 1)
                   (define var2 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define (proc1) 1)
                   (define (proc2) 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define var1 1)
                   (define (proc2) 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define (proc1) 1)
                   (define var2 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     (define var2 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define (proc2) 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     (define (proc2) 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define var2 2)))))
;; appending a non-definition expression into a begin block is invalid
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     'val))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     'val))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     (define var2 2)
                     'val))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define (proc2) 2)
                     'val))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     (define (proc2) 2)
                     'val))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define var2 2)
                     'val))))

(tn "named let internal definitions cross reference")
;; R5RS: 5.2.2 Internal definitions
;; Just as for the equivalent `letrec' expression, it must be possible to
;; evaluate each <expression> of every internal definition in a <body> without
;; assigning or referring to the value of any <variable> being defined.
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define var1 1)
                   (define var2 var1)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define var1 var2)
                   (define var2 2)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (define var1 var1)
                   'val)))
(assert-equal? (tn)
               '(0 0 0 0 0)
               (let loop ((var0 0))
                 (define var1 var0)
                 (define var2 var0)
                 (begin
                   (define var3 var0)
                   (begin
                     (define var4 var0)))
                 (define var5 var0)
                 (list var1 var2 var3 var4 var5)))
(assert-equal? (tn)
               '(#f #f #f #f #f #f)
               (let loop ((var0 (symbol-bound? 'var1)))
                 (define var1 (symbol-bound? 'var1))
                 (define var2 (symbol-bound? 'var1))
                 (begin
                   (define var3 (symbol-bound? 'var1))
                   (begin
                     (define var4 (symbol-bound? 'var1))))
                 (define var5 (symbol-bound? 'var1))
                 (list var0 var1 var2 var3 var4 var5)))
(assert-equal? (tn)
               '(#f #f #f #f #f #f)
               (let loop ((var0 (symbol-bound? 'var2)))
                 (define var1 (symbol-bound? 'var2))
                 (define var2 (symbol-bound? 'var2))
                 (begin
                   (define var3 (symbol-bound? 'var2))
                   (begin
                     (define var4 (symbol-bound? 'var2))))
                 (define var5 (symbol-bound? 'var2))
                 (list var0 var1 var2 var3 var4 var5)))
(assert-equal? (tn)
               '(#f #f #f #f #f #f)
               (let loop ((var0 (symbol-bound? 'var3)))
                 (define var1 (symbol-bound? 'var3))
                 (define var2 (symbol-bound? 'var3))
                 (begin
                   (define var3 (symbol-bound? 'var3))
                   (begin
                     (define var4 (symbol-bound? 'var3))))
                 (define var5 (symbol-bound? 'var3))
                 (list var0 var1 var2 var3 var4 var5)))
(assert-equal? (tn)
               '(#f #f #f #f #f #f)
               (let loop ((var0 (symbol-bound? 'var4)))
                 (define var1 (symbol-bound? 'var4))
                 (define var2 (symbol-bound? 'var4))
                 (begin
                   (define var3 (symbol-bound? 'var4))
                   (begin
                     (define var4 (symbol-bound? 'var4))))
                 (define var5 (symbol-bound? 'var4))
                 (list var0 var1 var2 var3 var4 var5)))
(assert-equal? (tn)
               '(#f #f #f #f #f #f)
               (let loop ((var0 (symbol-bound? 'var5)))
                 (define var1 (symbol-bound? 'var5))
                 (define var2 (symbol-bound? 'var5))
                 (begin
                   (define var3 (symbol-bound? 'var5))
                   (begin
                     (define var4 (symbol-bound? 'var5))))
                 (define var5 (symbol-bound? 'var5))
                 (list var0 var1 var2 var3 var4 var5)))
;; outer let cannot refer internal variable
(assert-error  (tn)
               (lambda ()
                 (let loop ((var0 (lambda () var1)))
                   (define var1 (lambda () 1))
                   (eq? (var0) var0))))
;; defining procedure can refer other (and self) variables as if letrec
(assert-equal? (tn)
               '(#t #t #t #t #t)
               (let loop ((var0 (lambda () 0)))
                 (define var1 (lambda () var0))
                 (define var2 (lambda () var0))
                 (begin
                   (define var3 (lambda () var0))
                   (begin
                     (define var4 (lambda () var0))))
                 (define var5 (lambda () var0))
                 (list (eq? (var1) var0)
                       (eq? (var2) var0)
                       (eq? (var3) var0)
                       (eq? (var4) var0)
                       (eq? (var5) var0))))
(assert-equal? (tn)
               '(#t #t #t #t #t)
               (let loop ()
                 (define var1 (lambda () var1))
                 (define var2 (lambda () var1))
                 (begin
                   (define var3 (lambda () var1))
                   (begin
                     (define var4 (lambda () var1))))
                 (define var5 (lambda () var1))
                 (list (eq? (var1) var1)
                       (eq? (var2) var1)
                       (eq? (var3) var1)
                       (eq? (var4) var1)
                       (eq? (var5) var1))))
(assert-equal? (tn)
               '(#t #t #t #t #t)
               (let loop ()
                 (define var1 (lambda () var2))
                 (define var2 (lambda () var2))
                 (begin
                   (define var3 (lambda () var2))
                   (begin
                     (define var4 (lambda () var2))))
                 (define var5 (lambda () var2))
                 (list (eq? (var1) var2)
                       (eq? (var2) var2)
                       (eq? (var3) var2)
                       (eq? (var4) var2)
                       (eq? (var5) var2))))
(assert-equal? (tn)
               '(#t #t #t #t #t)
               (let loop ()
                 (define var1 (lambda () var3))
                 (define var2 (lambda () var3))
                 (begin
                   (define var3 (lambda () var3))
                   (begin
                     (define var4 (lambda () var3))))
                 (define var5 (lambda () var3))
                 (list (eq? (var1) var3)
                       (eq? (var2) var3)
                       (eq? (var3) var3)
                       (eq? (var4) var3)
                       (eq? (var5) var3))))
(assert-equal? (tn)
               '(#t #t #t #t #t)
               (let loop ()
                 (define var1 (lambda () var4))
                 (define var2 (lambda () var4))
                 (begin
                   (define var3 (lambda () var4))
                   (begin
                     (define var4 (lambda () var4))))
                 (define var5 (lambda () var4))
                 (list (eq? (var1) var4)
                       (eq? (var2) var4)
                       (eq? (var3) var4)
                       (eq? (var4) var4)
                       (eq? (var5) var4))))
(assert-equal? (tn)
               '(#t #t #t #t #t)
               (let loop ()
                 (define var1 (lambda () var5))
                 (define var2 (lambda () var5))
                 (begin
                   (define var3 (lambda () var5))
                   (begin
                     (define var4 (lambda () var5))))
                 (define var5 (lambda () var5))
                 (list (eq? (var1) var5)
                       (eq? (var2) var5)
                       (eq? (var3) var5)
                       (eq? (var4) var5)
                       (eq? (var5) var5))))

(tn "named let internal definitions valid forms")
;; valid internal definitions
(assert-equal? (tn)
               '(1)
               (let loop ()
                 (define var1 1)
                 (list var1)))
(assert-equal? (tn)
               '(1)
               (let loop ()
                 (define (proc1) 1)
                 (list (proc1))))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (define var1 1)
                 (define var2 2)
                 (list var1 var2)))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (define (proc1) 1)
                 (define (proc2) 2)
                 (list (proc1) (proc2))))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (define var1 1)
                 (define (proc2) 2)
                 (list var1 (proc2))))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (define (proc1) 1)
                 (define var2 2)
                 (list (proc1) var2)))
;; SigScheme accepts '(begin)' as valid internal definition '(begin
;; <definition>*)' as defined in "7.1.6 Programs and definitions" of R5RS
;; although it is rejected as expression '(begin <sequence>)' as defined in
;; "7.1.3 Expressions".
(assert-equal? (tn)
               1
               (let loop ()
                 (begin)
                 1))
(assert-equal? (tn)
               1
               (let loop ()
                 (begin)
                 (define var1 1)
                 (begin)
                 1))
(assert-equal? (tn)
               '(1)
               (let loop ()
                 (begin
                   (define var1 1))
                 (list var1)))
(assert-equal? (tn)
               '(1)
               (let loop ()
                 (begin
                   (define (proc1) 1))
                 (list (proc1))))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (begin
                   (define var1 1)
                   (define var2 2))
                 (list var1 var2)))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (begin
                   (define (proc1) 1)
                   (define (proc2) 2))
                 (list (proc1) (proc2))))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (begin
                   (define var1 1)
                   (define (proc2) 2))
                 (list var1 (proc2))))
(assert-equal? (tn)
               '(1 2)
               (let loop ()
                 (begin
                   (define (proc1) 1)
                   (define var2 2))
                 (list (proc1) var2)))
(assert-equal? (tn)
               '(1 2 3 4 5 6)
               (let loop ()
                 (begin
                   (define (proc1) 1)
                   (define var2 2)
                   (begin
                     (define (proc3) 3)
                     (define var4 4)
                     (begin
                       (define (proc5) 5)
                       (define var6 6))))
                 (list (proc1) var2
                       (proc3) var4
                       (proc5) var6)))
;; begin block and single definition mixed
(assert-equal? (tn)
               '(1 2 3 4 5 6)
               (let loop ()
                 (begin)
                 (define (proc1) 1)
                 (begin
                   (define var2 2)
                   (begin
                     (define (proc3) 3)
                     (begin)
                     (define var4 4)))
                 (begin)
                 (define (proc5) 5)
                 (begin
                   (begin
                     (begin
                       (begin)))
                   (define var6 6)
                   (begin))
                 (begin)
                 (list (proc1) var2
                       (proc3) var4
                       (proc5) var6)))

(tn "named let internal definitions invalid begin blocks")
;; appending a non-definition expression into a begin block is invalid
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     'val)
                   (list var1))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     'val)
                   (list (proc1)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     (define var2 2)
                     'val)
                   (list var1 var2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define (proc2) 2)
                     'val)
                   (list (proc1) (proc2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define var1 1)
                     (define (proc2) 2)
                     'val)
                   (list var1 (proc2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define var2 2)
                     'val)
                   (list (proc1) var2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define var2 2)
                     (begin
                       (define (proc3) 3)
                       (define var4 4)
                       (begin
                         (define (proc5) 5)
                         (define var6 6)
                         'val)))
                   (list (proc1) var2
                         (proc3) var4
                         (proc5) var6))))

(tn "named let internal definitions invalid placement")
;; a non-definition expression prior to internal definition is invalid
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define var1 1))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define (proc1) 1))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define var1 1)
                   (define var2 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define (proc1) 1)
                   (define (proc2) 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define var1 1)
                   (define (proc2) 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define (proc1) 1)
                   (define var2 2))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define var1 1)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define var1 1)
                     (define var2 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)
                     (define (proc2) 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define var1 1)
                     (define (proc2) 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)
                     (define var2 2)))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)
                     (define var2 2)
                     (begin
                       (define (proc3) 3)
                       (define var4 4)
                       (begin
                         (define (proc5) 5)
                         (define var6 6)))))))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   (begin
                     (define (proc1) 1)
                     (define var2 2)
                     'val
                     (begin
                       (define (proc3) 3)
                       (define var4 4)
                       (begin
                         (define (proc5) 5)
                         (define var6 6)))))))
;; a non-definition expression prior to internal definition is invalid even if
;; expression(s) is following the internal definition
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define var1 1)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define (proc1) 1)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define var1 1)
                   (define var2 2)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define (proc1) 1)
                   (define (proc2) 2)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define var1 1)
                   (define (proc2) 2)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (define (proc1) 1)
                   (define var2 2)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin)
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define var1 1))
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1))
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define var1 1)
                     (define var2 2))
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)
                     (define (proc2) 2))
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define var1 1)
                     (define (proc2) 2))
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)
                     (define var2 2))
                   'val)))
(assert-error  (tn)
               (lambda ()
                 (let loop ()
                   'val
                   (begin
                     (define (proc1) 1)
                     (define var2 2)
                     (begin
                       (define (proc3) 3)
                       (define var4 4)
                       (begin
                         (define (proc5) 5)
                         (define var6 6))))
                   (list (proc1) var2
                         (proc3) var4
                         (proc5) var6))))

(tn "named let binding syntactic keywords")
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn define))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn if))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn and))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn cond))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn begin))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn do))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn delay))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn let*))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn else))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn =>))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn quote))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn quasiquote))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn unquote))
                   #t)))
(assert-error  (tn)
               (lambda ()
                 (let loop ((syn unquote-splicing))
                   #t)))


(tn "named let")
;; empty bindings is allowed by the formal syntax spec
(assert-equal? (tn)
               'yes
               (let loop ()
                 (if (procedure? loop) 'yes 'no)))
;; duplicate variable name
(assert-error  (tn)
               (lambda ()
                 (let loop ((var1 1)
                            (var1 2))
                   'result)))
;; masked variable name
(assert-equal? (tn)
               '(100 200 300)
               (let ((cnt 100)
                     (cnt2 200)
                     (cnt3 300))
                 (let loop ((cnt (+ -3 3))
                            (cnt2 0)
                            (cnt3 (length '(#t #t #t))))
                   (if (not (>= cnt 3))
                       (begin
                         (set! cnt (+ cnt 1))
                         (set! cnt2 (- cnt2 1))
                         (set! cnt3 (* cnt3 3))
                         (loop cnt cnt2 cnt3))))
                 (list cnt cnt2 cnt3)))
(assert-equal? (tn)
               '(4 5 3)
               (let loop1 ((var1 1)
                           (var2 2)
                           (var3 3))
                 (let loop2 ((var1 4)
                             (var2 5))
                   (list var1 var2 var3))))
(assert-equal? (tn)
               '(1 2 3)
               (let loop1 ((var1 1)
                           (var2 2)
                           (var3 3))
                 (let loop2 ((var1 4)
                             (var2 5))
                   'dummy)
                 (list var1 var2 var3)))
(assert-equal? (tn)
               '(1 2 9)
               (let loop1 ((var1 1)
                           (var2 2)
                           (var3 3))
                 (let loop2 ((var1 4)
                             (var2 5))
                   (set! var3 (+ var1 var2)))
                 (list var1 var2 var3)))
(assert-equal? (tn)
               '(1 2 30)
               (let loop1 ((var1 1)
                           (var2 2)
                           (var3 3))
                 (let loop2 ((var1 4)
                             (var2 5))
                   (set! var1 10)
                   (set! var2 20)
                   (set! var3 (+ var1 var2)))
                 (list var1 var2 var3)))
(assert-equal? (tn)
               '(1 2 3 (10 20))
               (let loop1 ((var1 1)
                           (var2 2)
                           (var3 3)
                           (var4 (let loop2 ((var1 4)
                                                 (var2 5))
                                       (set! var1 10)
                                       (set! var2 20)
                                       (list var1 var2))))
                 (list var1 var2 var3 var4)))
(assert-error  (tn)
               (lambda ()
                 (let loop1 ((var1 1)
                             (var2 2)
                             (var3 3)
                             (var4 (let loop2 ((var1 4)
                                                   (var2 5))
                                         (set! var3 10))))
                   (list var1 var2 var3 var4))))
;; no arg
(assert-equal? (tn)
               3
               (let ((cnt 0))
                 (let loop ()
                   (if (>= cnt 3)
                       cnt
                       (begin
                         (set! cnt (+ cnt 1))
                         (loop))))))
;; 1 arg
(assert-equal? (tn)
               3
               (let loop ((cnt 0))
                 (if (>= cnt 3)
                     cnt
                     (loop (+ cnt 1)))))
;; 3 arg + init with evaled value
(assert-equal? (tn)
               '(3 -3 81)
               (let loop ((cnt (+ -3 3))
                          (cnt2 0)
                          (cnt3 (length '(#t #t #t))))
                 (if (>= cnt 3)
                     (list cnt cnt2 cnt3)
                     (loop (+ cnt 1) (- cnt2 1) (* cnt3 3)))))
(assert-equal? (tn)
               '((2 54 -8)
                 (-33 1 29 3))
               (let loop ((lst '(3 29 -8 54 1 -33 2))
                          (even '())
                          (odd '()))
                 (cond
                  ((null? lst)
                   (list even odd))
                  ((even? (car lst))
                   (loop (cdr lst)
                         (cons (car lst) even)
                         odd))
                  (else
                    (loop (cdr lst)
                          even
                          (cons (car lst) odd))))))

(tn "named let lexical scope")
(define count-namedlet
  (let loop ((count-namedlet 0))  ;; intentionally same name
    (lambda ()
      (set! count-namedlet (+ count-namedlet 1))
      count-namedlet)))
(assert-true   (tn) (procedure? count-namedlet))
(assert-equal? (tn) 1 (count-namedlet))
(assert-equal? (tn) 2 (count-namedlet))
(assert-equal? (tn) 3 (count-namedlet))


(total-report)
