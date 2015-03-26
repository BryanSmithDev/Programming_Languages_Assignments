(define (count lis)
 (cond 
   ((null? lis) 0)
   ((not (list? lis)) 1)
   (else (+ (count (car lis)) (count (cdr lis)) ))
  )
 )

(define (interparse lis1 lis2)
  (cond ((null? lis1) lis2)
        ((null? lis2) lit1)
        (else (cons (car lis1) (cons (car lis2) (interparse (cdr lis1) (cdr lis2)))) )
   )
)

(count '(1 2 3 (4 5 6 7) 8 9 10 11 12 13))
(interparse '(a c e) '(b d f))