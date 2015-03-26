;	CSC 4200-01 - Programming Languages
;	Name: Bryan Smith
;	Date: 4/1/14
;	Description: Method to count the length of a list

(define list '(a,b,c,d,e,f))
(define lLength 0)

;Method to count the list length
(define (ListLength tlist)
  (set! lLength (+ lLength 1))
  (cond
    ( (not(list? tlist)) (display "Not a list."))
    ( (null? tlist) (display 0))
    ( (null? (cdr tlist)) (display lLength))
    (else(ListLength (cdr tlist)))
    )
 )

(ListLength list) ;Run the method
