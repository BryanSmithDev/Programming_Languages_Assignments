; CSC 4200-01 - Programming Languages
; Name: Bryan Smith
; Date: 4/7/14
; Description: Rotate a list left or right

(define list1 '(a b c d e))

;Get the last element of the list
(define (last lis)
  (cond
    ( (null? lis) (display "Empty List"))
    ( (not (list? lis)) (display "Not a list"))
    ( (null? (cdr lis)) (car lis))
    (else (last (cdr lis)))
    )
  )

;Rotate the list left
(define (RotateLeft lis)
  (cond
    ( (null? lis) '())
    ( (not (list? lis)) (display "Not a list"))
    ( (eq? (length lis) 1) lis)
    (else (append (cdr lis) (list (car lis))) )
    )
  )

;Rotate the list right
(define (RotateRight lis)
  (cond
    ( (null? lis) '())
    ( (not (list? lis)) (display "Not a list"))
    ( (eq? (length lis) 1) lis)
    (else (append (list (last lis)) (reverse (cdr (reverse lis)))) )
    )
  )

;Demonstrate the methods
(RotateLeft list1)
(RotateRight list1)