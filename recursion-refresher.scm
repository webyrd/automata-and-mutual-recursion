;;; Recursion and mutual-recursion refresher

(load "test-check.scm")

(define multi-rember
  (lambda (x ls)
    (cond
      [(null? ls) '()]
      [(eq? (car ls) x)
       (multi-rember x (cdr ls))]
      [else
       (cons (car ls) (multi-rember x (cdr ls)))])))

(test "multi-rember-1"
  (multi-rember 'y '(x y z x y))
  '(x z x))

(test "multi-rember-2"
  (multi-rember 'y '())
  '())

(test "multi-rember-3"
  (multi-rember 'y '(y z x y))
  '(z x))

(test "multi-rember-4"
  (multi-rember 'y '(z y z x y))
  '(z z x))




(define even?
  (lambda (n)
    (cond
      [(zero? n) #t]
      [else (odd? (sub1 n))])))

(define odd?
  (lambda (n)
    (cond
      [(zero? n) #f]
      [else (even? (sub1 n))])))

(test "even?"
  (even? 1)
  #f)

(test "odd?"
  (odd? 0)
  #f)



;;; equivalence between let and lambda + procedure application
(test "let"
  (let ([x (+ 2 3)])
    (* x x))
  ((lambda (x) (* x x)) (+ 2 3)))



(define !
  (lambda (n)
    (cond
      [(zero? n) 1]
      [else (* (! (sub1 n)) n)])))

(test "!"
  (! 5)
  120)


(letrec ([! (lambda (n)
              (cond
                [(zero? n) 1]
                [else (* (! (sub1 n)) n)]))])
  (! 5))
; => 120


(letrec ([even? (lambda (n)
                  (cond
                    [(zero? n) #t]
                    [else (odd? (sub1 n))]))]
         [odd? (lambda (n)
                 (cond
                   [(zero? n) #f]
                   [else (even? (sub1 n))]))])
  (odd? 101))
; => #t

;;; This is equivalent to (odd? 101)
((cadr (letrec ([even? (lambda (n)
                         (cond
                           [(zero? n) #t]
                           [else (odd? (sub1 n))]))]
                [odd? (lambda (n)
                        (cond
                          [(zero? n) #f]
                          [else (even? (sub1 n))]))])
         (list even? odd?)))
 101)
; => #t
