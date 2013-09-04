;; Pac-Man ghost state machine, from:
;; http://research.ncl.ac.uk/game/mastersdegree/gametechnologies/aifinitestatemachines/

(letrec ([wander-maze (lambda (action)
                        (case action
                          [(sight-pac-man) chase-pac-man]
                          [(pac-man-eats-last-pill) run-away]
                          [else wander-maze]))]
         [chase-pac-man (lambda (action)
                          (case action
                            [(pac-man-eats-pill) run-away]
                            [(lose-sight-of-pac-man) wander-maze]
                            [else chase-pac-man]))]
         [run-away (lambda (action)
                     (case action
                       [(pill-wears-off) wander-maze]
                       [(eaten-by-pac-man) return-to-base]
                       [else run-away]))]
         [return-to-base (lambda (action)
                           (case action
                             [(reach-base) wander-maze]
                             [else return-to-base]))])
  wander-maze)


;; in a loop, with printed state transitions 

(begin
  (printf "wandering...\n")
  (let loop ((state (letrec ([wander-maze
                              (lambda (action)
                                (case action
                                  [(sight-pac-man)
                                   (printf "chasing pac-man!\n")
                                   chase-pac-man]
                                  [(pac-man-eats-last-pill)
                                   (printf "run away!\n")
                                   run-away]
                                  [else
                                   (printf "still wandering...\n")
                                   wander-maze]))]
                             [chase-pac-man
                              (lambda (action)                              
                                (case action
                                  [(pac-man-eats-pill)
                                   (printf "run away!\n")
                                   run-away]
                                  [(lose-sight-of-pac-man)
                                   (printf "wandering...\n")
                                   wander-maze]
                                  [else
                                   (printf "still chasing...\n")
                                   chase-pac-man]))]
                             [run-away
                              (lambda (action)                              
                                (case action
                                  [(pill-wears-off)
                                   (printf "wandering...\n")
                                   wander-maze]
                                  [(eaten-by-pac-man)
                                   (printf "returning to base!\n")
                                   return-to-base]
                                  [else
                                   (printf "still running away...\n")
                                   run-away]))]
                             [return-to-base
                              (lambda (action)
                                (case action
                                  [(reach-base)
                                   (printf "wandering...\n")
                                   wander-maze]
                                  [else
                                   (printf "still returning to base...\n")
                                   return-to-base]))])
                      wander-maze)))
    (loop (state (read)))))

;; example session:

;; > wandering...
;; sight-pac-man
;; chasing pac-man!
;; pac-man-eats-pill
;; run away!
;; sight-pac-man
;; still running away...
;; eaten-by-pac-man
;; returning to base!
;; pac-man-eats-pill
;; still returning to base...
;; eaten-by-pac-man
;; still returning to base...
;; reach-base
;; wandering...
