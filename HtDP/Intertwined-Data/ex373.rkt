;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex373) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require 2htdp/abstraction)
(require 2htdp/image)

; An Xexpr is (cons Symbol Xe-Body)

; An XWord is '(word ((text String)))

;; An Xe-Body is one of:
;; - Body
;; - (cons [List-of Atrribute] Body)
;; - XWord
;; where Body is short for [List-of Xexpr]

; An Attribute is a list of two items:
;   (cons Symbol (cons String '()))

; An XItem.v2 is one of: 
; – (cons 'li (cons XWord '()))
; – (cons 'li (cons [List-of Attribute] (list XWord)))
; – (cons 'li (cons XEnum.v2 '()))
; – (cons 'li (cons [List-of Attribute] (list XEnum.v2)))
; 
; An XEnum.v2 is one of:
; – (cons 'ul [List-of XItem.v2])
; – (cons 'ul (cons [List-of Attribute] [List-of XItem.v2]))

(define i1 '(li (word ((text "Python")))))
(define i2 '(li (word ((text "is")))))
(define i3 '(li (word ((text "great")))))
(define i4 `(li (ul ,i1)))

(define e1 `(ul ,i1))
(define e2 `(ul ,i1 ,i2 ,i3))
(define e3 `(ul ,i2 (li ,e1)))

(define SIZE 12) ; font size 
(define COLOR "black") ; font color 
(define BT ; a graphical constant 
  (beside (circle 1 'solid 'black) (text " " SIZE COLOR)))

; for tests
(define i1-rendered (text "Python" SIZE COLOR))
(define i2-rendered (text "is" SIZE COLOR))
(define i3-rendered (text "great" SIZE COLOR))

; Image -> Image
; marks item with bullet
(check-expect
 (bulletize i1-rendered)
 (beside/align 'center BT i1-rendered))

(define (bulletize item)
  (beside/align 'center BT item))

; for tests
(define e1-rendered
  (above/align 'left (bulletize i1-rendered) empty-image))
(define e2-rendered
  (above/align 'left (bulletize i1-rendered)
               (above/align 'left (bulletize i2-rendered)
                            (above/align 'left (bulletize i3-rendered)
                                         empty-image))))
(define e3-rendered
  (above/align 'left
               (bulletize i2-rendered)
               (bulletize e1-rendered)))
 
; XEnum.v2 -> Image
; renders an XEnum.v2 as an image
(check-expect (render-enum e1) e1-rendered)
(check-expect (render-enum e2) e2-rendered)
(check-expect (render-enum e3) e3-rendered)

(define (render-enum xe)
  (local ((define content (xexpr-content xe))
          ; XItem.v2 Image -> Image 
          (define (deal-with-one item so-far)
            (above/align 'left (render-item item) so-far)))
    (foldr deal-with-one empty-image content)))
 
; XItem.v2 -> Image
; renders one XItem.v2 as an image
(check-expect (render-item i1) (bulletize i1-rendered))
(check-expect (render-item i4) (bulletize (render-enum e1)))

(define (render-item an-item)
  (local ((define content (first (xexpr-content an-item))))
    (bulletize
      (cond
        [(word? content)
         (text (word-text content) SIZE 'black)]
        [else (render-enum content)]))))

;; Xexpr.v2 -> Xe-Body
;; extracts the list of content elements
(define (xexpr-content xe)
  (match xe
    [(cons (? symbol?) (cons (? list-of-attributes?) body)) body]
    [(cons (? symbol?) body) body]))

; [List-of Attribute] or Xexpr.v2 -> Boolean
; is x a list of attributes
(define (list-of-attributes? x)
  (cond
    [(empty? x) #true]
    [else
     (local ((define possible-attribute (first x)))
       (cons? possible-attribute))]))

;; Any -> Boolean
;; is a in XWord
(define (word? a)
  (match a
    [`(word ((text ,s))) #true]
    [else #false]))

;; XWord -> String
;; extracts the value xw
(define (word-text xw)
  (second (first (second xw))))

