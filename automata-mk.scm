;;; Relational translation of fsm-ho into miniKanren

(load "mk.scm")
(load "test-check.scm")

(define fsm-hoo
  (lambda (str out)
    (letrec ([S0 (lambda (str)
                   (conde
                     [(== '() str) (== 'accept out)]
                     [(fresh (a d)
                        (== `(,a . ,d) str)
                        (conde
                          [(== 0 a) (S0 d)]
                          [(== 1 a) (S1 d)]))]))]
             [S1 (lambda (str)
                   (conde
                     [(== '() str) (== 'reject out)]
                     [(fresh (a d)
                        (== `(,a . ,d) str)
                        (conde
                          [(== 0 a) (S2 d)]
                          [(== 1 a) (S0 d)]))]))]
             [S2 (lambda (str)
                   (conde
                     [(== '() str) (== 'reject out)]
                     [(fresh (a d)
                        (== `(,a . ,d) str)
                        (conde
                          [(== 0 a) (S1 d)]
                          [(== 1 a) (S2 d)]))]))])
      (S0 str))))

(test "fsm-hoo-1"
  (run* (q) (fsm-hoo '(0 1 1) q))
  '(accept))

(test "fsm-hoo-2"
  (run* (q) (fsm-hoo '(0 1 1 1) q))
  '(reject))

(test "fsm-hoo-3"
  (run 10 (q) (fsm-hoo q 'accept))
  '(()
    (0)
    (0 0)
    (1 1)
    (0 0 0)
    (1 1 0)
    (0 1 1)
    (1 0 0 1)    
    (0 0 0 0)
    (1 1 0 0)))

(test "fsm-hoo-4"
  (run 10 (q) (fsm-hoo q 'reject))
  '((1)
    (0 1)
    (1 0)
    (0 0 1)
    (0 1 0)
    (1 0 0)
    (1 1 1)
    (1 0 1)
    (0 0 0 1)
    (0 0 1 0)))

(test "fsm-hoo-5"
  (run 10 (q)
    (fresh (str out)
      (fsm-hoo str out)
      (== `(,str ,out) q)))
  '((() accept)
    ((0) accept)
    ((1) reject)
    ((0 0) accept)
    ((1 0) reject)
    ((0 1) reject)
    ((1 1) accept)
    ((0 0 0) accept)
    ((1 0 0) reject)
    ((0 1 0) reject)))

(test "fsm-hoo-6"
  (run* (q) (fsm-hoo `(0 ,q) 'accept))
  '(0))

(test "fsm-hoo-7"
  (run 10 (q) (fsm-hoo `(0 . ,q) 'accept))
  '(()
    (0)
    (0 0)
    (1 1)
    (0 0 0)
    (1 1 0)
    (0 1 1)
    (1 0 0 1)
    (0 0 0 0)
    (1 1 0 0)))

(test "fsm-hoo-8"
  (run 10 (q) (fsm-hoo `(1 . ,q) 'accept))
  '((1)
    (1 0)
    (0 0 1)
    (1 0 0)
    (1 1 1)
    (0 1 0 1)
    (0 0 1 0)
    (1 0 0 0)
    (1 1 1 0)
    (1 0 1 1)))

(test "fsm-hoo-9"
  (run 10 (q)
    (fresh (b rest)
      (== `(,b 0 . ,rest) q)
      (fsm-hoo q 'accept)))
  '((0 0)
    (0 0 0)
    (1 0 0 1)
    (0 0 0 0)
    (0 0 1 1)
    (1 0 1 0 1)
    (1 0 0 1 0)
    (0 0 0 0 0)
    (0 0 1 1 0)
    (0 0 0 1 1)))
