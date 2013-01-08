#lang racket

(require redex)
(provide (all-defined-out))


(define-language λπ
  ;; heap
  (Σ ((ref val) ...))
  ;; type of references
  (ref natural)
  
  ;; environment
  (ε ((x ref) ...))
  (εs (ε ...))
  
  ;; value types
  (val
   #|
   ;; core string type, not string class
   (str-val string)
   ;; built in bool types
   (true-val)
   (false-val)
   ;; none type
   (none-val)
   ;; list and tuple types, just reference heap values
   (list-val (ref ...))
   (tuple-val (ref ...))
   ;; dict has key/value pairs (all on heap)
   (dict-val ((ref ref) ...))
   ;; set is like a list in representation, lack of order has
   ;; to be accounted for in semantics
   (set-val (ref ...))
   ;; class has name, base, and body
   (class-val string string e)
   |#
   ;; object has class and body-val, with/without meta-val - not sure how to do meta-vals yet
   (obj-val x mval ((string ref) ...))
   (obj-val x ((string ref) ...))
   ;; closure, with/without vararg
   (fun-val εs (λ (x ...) e))
   (fun-val εs (λ (x ...) (x) e))
   ;; undefined
   undefined-val)
  
  ;; primitive operators
  (op string)
  
  ;; id-type
  (t global nonlocal local)
  
  ;; types of meta-val
  (mval (meta-num number)
        (meta-str string)
        (meta-list (val ...))
        (meta-tuple (val ...))
        (meta-dict ((val val) ...))
        ;; set is like a list in representation, lack of order has to be accounted for in semantics
        (meta-set (val ...))
        (meta-class x)
        (meta-none))
  
  ;; types of expressions
  (e (str string)
     true
     false
     none
     (class x x e)
     ;; with/without meta-val - how to do metavals?
     (object x)
     (object x mval)
     (get-field e string)
     (seq e e)
     (assign e e)
     (error e)
     (if e e e)
     (id x t)
     (let (x e) e)
     ;; we have two variants of app, with and without stararg
     (app e (e ...))
     (app-star e (e ...) e)
     (fun (x ...) e)
     (fun (x ...) x e)
     ;; put method as a separate construct for now
     (method (x ...) e)
     (method (x ...) x e)
     (while e e e)
     (return e)
     (prim1 op e)
     (prim2 op e e)
     (builtin-prim op (e ...))
     (list (e ...))
     (tuple (e ...))
     (dict ((e e) ...))
     (set (e ...))
     (reraise)
     (raise e)
     (try e (e ...) e e)
     (except (e ...) e)
     (except (e ...) (x) e)
     undefined
     break
     (module e e)
     r)
  
  ;; types for result
  (r val
     (return-r val)
     break-r
     (exception-r val))
  
  ;; evaluation context
  (E hole
     (module E e)
     (assign e E)
     (seq E e)
     (if E e e)
     (let (x E) e)
     (list E)
     (tuple E)
     (set E)
     (dict ((val val) ... (e E) (e e) ...))
     (dict ((val val) ... (E val) (e e) ...)) ;; Python's dict has this evaluation order
     (get-field E string)
     (prim1 op E)
     (prim2 op E e)
     (prim2 op val E)
     (builtin-prim op E)
     (raise E)
     (return E)
     (try E (e ...) e e)
     ;(try val (e ...) E e)
     (app E (e ...))
     (app val E)
     (app-star E (e ...) e)
     (app-star val E e)
     (app-star val (val ...) E)
     (val ... E e ...) ;; for list, tuple, app, etc.
     ;; todo - may need more
     )
  
  ;; context in a try block
  (T hole
     (assign e T)
     (seq T e)
     (if T e e)
     (let (x T) e)
     (list T)
     (tuple T)
     (set T)
     (dict ((val val) ... (e T) (e e) ...))
     (dict ((val val) ... (T val) (e e) ...)) ;; Python's dict has this evaluation order
     (get-field T string)
     (prim1 op T)
     (prim2 op T e)
     (prim2 op val T)
     (builtin-prim op T)
     (raise T)
     (app T (e ...))
     (app val T)
     (app-star T (e ...) e)
     (app-star val T e)
     (app-star val (val ...) T)
     (val ... T e ...) ;; for list, tuple, app, etc.
     ;; todo - may need more
     )
  
  ;; identifiers, as per
  ;; http://docs.python.org/3.2/reference/lexical_analysis.html#keywords
  (x (variable-except False class finally is return
		      None continue for lambda try
		      True def from nonlocal while
		      and del global not with
		      as elif if or yield
		      assert else import pass
		      break except in raise))
  
  (p (e εs Σ))
  (P (E εs Σ))
  )
