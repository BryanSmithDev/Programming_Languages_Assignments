; CSC 4200-01 - Programming Languages
; Name: Bryan Smith
; Date: 4/9/14
; Description: Heap Sort in Racket

;Get the value of a list's element
(define (get lis pos)
  (cond
   ( (null? lis) (display "Empty List") )
   ( (or (> pos (length lis)) (< pos 0)) (display "Invalid Position") )
   ( (= pos 1) (car lis) )
   (else (get (cdr lis) (- pos 1)) )
   )
  )

;Replace an element of a list
(define (replace lis pos item)
  (cond
    ( (> pos (length lis)) (append lis (list item)) )
    ( (= pos 1 ) ( cons item (cdr lis)) )
    (else (cons (car lis) (replace (cdr lis) (- pos 1) item)) )
   )
  )

;Swap two elements of a list
(define (swap lis pos1 pos2)
  (cond
    ( (null? lis) (display "Empty List")lis )
    ( (or (> pos1 (length lis)) (> pos2 (length lis))) (display "Invalid Position")lis pos2 )
    (else (replace (replace lis pos1 (get lis pos2)) pos2 (get lis pos1)) )
   )
  )

(define (heapify lis start count)
  (cond
    ( (>= count 0) (siftDown lis start (- count 1)) (heapify lis (- start 1) count) )
  )
 )

(define (siftDown lis root end)
  (cond
    ( (< (* root 2) end) (siftDown lis (* root 2) end) )
    ( (< (get lis root) (* root 2)) (swap lis root (* root 2)) (siftDown lis (* root 2) end) )
    ( (and (<= (+ (* root 2) 1) end) (< (get lis root) (get lis (+ (* root 2) 1)))) (swap lis root (+ (* root 2) 1)) (siftDown lis (* root 2) end) )
  )
 )

(define lis '(6 5 3 1 8 7 2 4))
(siftDown lis 1 (floor (/ (- (length lis) 1) 2)))

