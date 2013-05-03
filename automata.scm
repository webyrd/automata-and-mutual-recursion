(load "pmatch.scm")
(load "test-check.scm")

;;; Three Scheme implementations of the example deterministic finite automaton (DFA) from:
;;; http://en.wikipedia.org/wiki/Deterministic_finite_automaton

;;; Here is the DFA in the form of a 5-tuple (as described on p. 35 of Michael Sipser's overpriced but excellent 'Introduction to the Theory of Computation, third edition')

;;; (Q Sigma delta q0 F)
;;;
;;; 'Q' is the set of states: {S0 S1 S2}
;;; 'Sigma' is alphabet (binary digits in this case): {0 1}
;;; 'delta' is the transition function, of type    delta: Q x Sigma -> Q
;;; 'q0' is the starting state: S0
;;; 'F' is the set of accepting states: {S0}
;;;
;;; We can represent the transition function 'delta' as a table:
;;;
;;;     |  0    1
;;; --------------
;;; S0 |  S0   S1
;;; S1 |  S2   S0
;;; S2 |  S1   S2
;;;
;;; The table shows that when in state S1, reading a 0 results in a
;;; transition to state S2, while reading a 1 results in a transition
;;; to state S0.


;;; Implementation 1: first-order representation of states
;;;
;;; States are represted as symbols (data).  State transitions are
;;; encoded as recursive calls to fsm-aux.

(define fsm
  (lambda (str)
    (fsm-aux str 'S0)))

(define fsm-aux
  (lambda (str state)
    (cond
      [(null? str) (if (eq? 'S0 state) 'accept 'reject)]
      [else
       (let ([d (cdr str)])
         (pmatch (list state (car str))
           [(S0 0) (fsm-aux d 'S0)]
           [(S0 1) (fsm-aux d 'S1)]
           [(S1 0) (fsm-aux d 'S2)]
           [(S1 1) (fsm-aux d 'S0)]
           [(S2 0) (fsm-aux d 'S1)]
           [(S2 1) (fsm-aux d 'S2)]))])))

(test "fsm-1"
  (fsm '(0 1 1))
  'accept)

(test "fsm-2"
  (fsm '(0 1 1 1))
  'reject)


;;; Implementation 2: higher-order representation of states
;;;
;;; States are represented as mutually-recursive procedures.
;;; State transitions are encoded as procedure calls.

(define fsm-ho
  (lambda (str)
    (letrec ([S0 (lambda (str)
                   (cond
                     [(null? str) 'accept]
                     [else
                      (let ([d (cdr str)])
                        (case (car str)
                          [(0) (S0 d)]
                          [(1) (S1 d)]))]))]
             [S1 (lambda (str)
                   (cond
                     [(null? str) 'reject]
                     [else
                      (let ([d (cdr str)])
                        (case (car str)
                          [(0) (S2 d)]
                          [(1) (S0 d)]))]))]
             [S2 (lambda (str)
                   (cond
                     [(null? str) 'reject]
                     [else
                      (let ([d (cdr str)])
                        (case (car str)
                          [(0) (S1 d)]
                          [(1) (S2 d)]))]))])
      (S0 str))))

(test "fsm-ho-1"
  (fsm-ho '(0 1 1))
  'accept)

(test "fsm-ho-2"
  (fsm-ho '(0 1 1 1))
  'reject)


;;; Implementation 3: higher-order representation of states
;;;
;;; States are represented as mutually-recursive procedures.  State
;;; transitions are encoded as a procedure *returned* by a call.  The
;;; 'driver' function is responsible for consuming the input string,
;;; and calling the procedures returned from previous calls to states.

(define fsm-ho2
  (lambda (str)
    (let ([start-state
           (letrec ([S0 (lambda (b)
                          (cond
                            [(eq? b 'end) 'accept]
                            [else
                             (case b
                               [(0) S0]
                               [(1) S1])]))]
                    [S1 (lambda (b)
                          (cond
                            [(eq? b 'end) 'reject]
                            [else
                             (case b
                               [(0) S2]
                               [(1) S0])]))]
                    [S2 (lambda (b)
                          (cond
                            [(eq? b 'end) 'reject]
                            [else
                             (case b
                               [(0) S1]
                               [(1) S2])]))])
             S0)])
      (letrec ([driver (lambda (str state)
                         (cond
                           [(null? str) (state 'end)]
                           [else
                            (driver (cdr str) (state (car str)))]))])
        (driver str start-state)))))

(test "fsm-ho2-1"
  (fsm-ho2 '(0 1 1))
  'accept)

(test "fsm-ho2-2"
  (fsm-ho2 '(0 1 1 1))
  'reject)
