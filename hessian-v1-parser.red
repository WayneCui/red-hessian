Red [

]

byte: 'skip
null:       charset "N"
boolean-T:  charset "T"
boolean-F:  charset "F"
int:        ["I" copy data 4 skip (data: to-integer data)]
float:     ["D" copy raw-data 8 skip (float-data: to-float raw-data) ]

; see: https://en.wikipedia.org/wiki/UTF-8
one-byte:   [copy first-byte skip if ((copy/part (enbase/base first-byte 2) 1) = "0") (append buf first-byte)]
two-byte:   [copy first-byte skip if ((copy/part (enbase/base first-byte 2) 3) = "110") (append buf first-byte)]
three-byte: [copy first-byte skip if ((copy/part (enbase/base first-byte 2) 4) = "1110") (append buf first-byte)]
four-byte:  [copy first-byte skip if ((copy/part (enbase/base first-byte 2) 5) = "11110") (append buf first-byte)]
str-fragment:  [
                    copy len 2 skip (n: to-integer len) 
                    n [
                        one-byte |
                        two-byte [copy data 1 skip (append buf data)] | 
                        three-byte [copy data 2 skip (append buf data)] | 
                        four-byte [copy data 3 skip (append buf data)] 
                    ] 
                ]
string:     [(buf: copy #{}) any ["s" str-fragment ] "S" str-fragment (data: to-string buf)]

end-symbol: charset "z"


decode: func [ response ][
    list-collection: copy []
    temp: none
    local-blk: none
    refs: copy []
    result: collect [
        parse response [
            thru #{720100} 
            [ 
                null (keep none)       |
                boolean-T (keep true)  |
                boolean-F (keep false) |
                int (keep data)        |
                float (keep float-data) |
                string (keep data) |
            ]
            end-symbol
        ]
    ]

    result/1
]
