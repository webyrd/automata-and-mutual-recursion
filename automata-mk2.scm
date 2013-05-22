;;; Relational translation of fsm-ho2 into miniKanren

;;; This version uses the non-logical feature 'project' in order to
;;; access (and then call) procedures associated with logic variables.
;;;
;;; It should be possible to remove these calls to project by running
;;; the entire state machine inside a meta-circular interpreter
;;; capable of running miniKanren inside of miniKanren.  This approach
;;; should allow state machine code to be constructed automatically
;;; when running backwards.

(load "mk.scm")
(load "test-check.scm")

(define fsm-hoo2
  (lambda (str out)
    (let ([start-stateo
           (letrec ([S0 (lambda (b out)
                          (conde
                            [(== 'end b) (== 'accept out)]
                            [(conde
                               [(== 0 b) (== S0 out)]
                               [(== 1 b) (== S1 out)])]))]
                    [S1 (lambda (b out)
                          (conde
                            [(== 'end b) (== 'reject out)]
                            [(conde
                               [(== 0 b) (== S2 out)]
                               [(== 1 b) (== S0 out)])]))]
                    [S2 (lambda (b out)
                          (conde
                            [(== 'end b) (== 'reject out)]
                            [(conde
                               [(== 0 b) (== S1 out)]
                               [(== 1 b) (== S2 out)])]))])
             S0)])
      (letrec ([drivero (lambda (str stateo)
                          (conde
                            [(== '() str)
                             (project (stateo)
                               ;;; project nastiness
                               (stateo 'end out))]
                            [(fresh (a d stateo^)
                               (== `(,a . ,d) str)
                               (=/= 'end a)
                               (project (stateo)
                                 ;;; project nastiness
                                 (stateo a stateo^))
                               (drivero d stateo^))]))])
        (drivero str start-stateo)))))

(test "fsm-hoo2-1"
  (run* (q) (fsm-hoo2 '(0 1 1) q))
  '(accept))

(test "fsm-hoo2-2"
  (run* (q) (fsm-hoo2 '(0 1 1 1) q))
  '(reject))

(test "fsm-hoo2-3"
  (run 10 (q) (fsm-hoo2 q 'accept))
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

(test "fsm-hoo2-4"
  (run 10 (q) (fsm-hoo2 q 'reject))
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

(test "fsm-hoo2-5"
  (run 10 (q)
    (fresh (str out)
      (fsm-hoo2 str out)
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

(test "fsm-hoo2-6"
  (run* (q) (fsm-hoo2 `(0 ,q) 'accept))
  '(0))

(test "fsm-hoo2-7"
  (run 10 (q) (fsm-hoo2 `(0 . ,q) 'accept))
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

(test "fsm-hoo2-8"
  (run 10 (q) (fsm-hoo2 `(1 . ,q) 'accept))
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

(test "fsm-hoo2-9"
  (run 10 (q)
    (fresh (b rest)
      (== `(,b 0 . ,rest) q)
      (fsm-hoo2 q 'accept)))
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
