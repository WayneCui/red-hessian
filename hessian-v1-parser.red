Red [

]

byte: 'skip
null:       charset "N"
boolean-T:  charset "T"
boolean-F:  charset "F"
int:        ["I" copy data 4 skip (data: to-integer data)]
float:     ["D" copy raw-data 8 skip (float-data: to-float raw-data) ]
date:       ["d" copy high-part 4 skip copy low-part 4 skip]

; see: https://en.wikipedia.org/wiki/UTF-8
utf-8:   [
                copy first-byte skip (str-base2: enbase/base first-byte 2) 
                [
                    if (parse str-base2 ["0" to end]) [copy data 0 skip] |
                    if (parse str-base2 ["110" to end]) [copy data 1 skip] |
                    if (parse str-base2 ["1110" to end]) [copy data 2 skip] |
                    if (parse str-base2 ["11110" to end]) [copy data 3 skip] |
                ]  
                (append buf rejoin [first-byte data])
            ]
str-fragment:  [
                    copy len 2 skip (n: to-integer len) 
                    n [
                        utf-8
                    ] 
                ]
string:     [(buf: copy #{}) any ["s" str-fragment ] "S" str-fragment (data: to-string buf)]

end-symbol: charset "z"

; as Red only support 32-bits integer at present, we need this way to deal with long numbers
from-timestamp: func [ high-part low-part ][
    high: to-integer high-part
    low:  to-integer low-part
    return to date! to-integer (round (high * ((power 2 32 ) / 1000) + (low / 1000)))
]

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
                date (keep from-timestamp high-part low-part) |                
                string (keep data) |
            ]
            end-symbol
        ]
    ]

    result/1
]
