automata-and-mutual-recursion
=============================

Code from the Tutorial Thursday hangout of 2 May 2013 on using mutual-recursion to represent automata.

The Scheme files in this repository:

`recursion-refresher.scm`
refresher examples of recursion, mutual-recursion, and Scheme's 'letrec'

`automata.scm`
three Scheme implementations of the deterministic finite automaton (DFA) from the Wikipedia page:
http://en.wikipedia.org/wiki/Deterministic_finite_automaton

`automata-mk.scm`
translation of the second DFA implementation from `automata.scm` into the miniKanren relational language

Support files:

`pmatch.scm`
a simple pattern matcher

`test-check.scm`
a simple test macro

`mk.scm`
an implementation of miniKanren



The YouTube video of hangout is at: https://www.youtube.com/watch?v=yrf1AYtrKm0

In the video I demonstrate an old functional programming trick: how to encode a deterministic finite state automata using mutually recursive procedures in Scheme and miniKanren.  I begin with a gentle introduction to recursion, mutual recursion, and Scheme's letrec construct, which experienced functional programmers may wish to skip.

If you find this interesting, you might want to read Shriram Krishnamurthi's 2006 Journal of Functional Programming paper, 'Automata via Macros':
http://cs.brown.edu/~sk/Publications/Papers/Published/sk-automata-macros/

Michael Sipser's overpriced but excellent 'Introduction to the Theory of Computation, third edition' contains the clearest explanation of finite automata I have seen.