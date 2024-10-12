{:user
 {:dependencies [[hashp "0.2.1"]
                 [com.bhauman/rebel-readline "0.1.4"]]
  :injections [(require 'hashp.core)]
  :aliases {"rebl" ["trampoline" "run" "-m" "rebel-readline.main"]}
  :repl {
    :init (require '[clojure.repl :refer :all])
  }}}
