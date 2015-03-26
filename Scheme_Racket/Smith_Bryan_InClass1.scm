(define list '(a b c (d e f) g))

(define (deep-member value slist)
  (cond
    ( (or (null? slist) (not (list? slist))) #f )
    ( (eq? value (car slist)) #t )
    ( (and (list? (car slist))
         (not (deep-member value (car slist)))
         (deep-member value (cdr slist)) )
     )
    ( (and (list? (car slist))
           (deep-member value (car slist))) #t)
    (else (deep-member value (cdr slist)))
    )
  )

(deep-member 'f list)