Red [

]

byte: 'skip
null:       charset "N"
boolean-T:  charset "T"
boolean-F:  charset "F"
int:        ["I" copy data 4 skip (data: to-integer data)]
float:     ["D" copy raw-data 8 skip (float-data: to-float raw-data) ]
date:       ["d" copy high-part 4 skip copy low-part 4 skip]
binary-fragment:  [copy len 2 skip (n: to-integer len) copy data n skip (append buf data)]
binary:     [(buf: copy #{}) any ["b" binary-fragment] "B" binary-fragment]

; see: https://en.wikipedia.org/wiki/UTF-8
utf-8:   [      
                copy first-byte skip (str-base2: enbase/base first-byte 2) 
                [
                    if (parse str-base2 ["0" to end]) [copy data 0 skip] |
                    if (parse str-base2 ["110" to end]) [copy data 1 skip] |
                    if (parse str-base2 ["1110" to end]) [copy data 2 skip] |
                    if (parse str-base2 ["11110" to end]) [copy data 3 skip]
                ]  
                (append buf rejoin [first-byte data])
            ]

str-fragment:  [
                    copy len 2 skip (n: to-integer len) 
                    [ n [ utf-8 ]]
                ]
string:     [(buf: copy #{}) any ["s" str-fragment ] "S" str-fragment 
                (
                    string-data: to-string buf
                    (string-data: after-chars-collected string-data)
                )
            ]

list:       [ 
                "V" 
                (   temp: local-blk 
                    local-blk: copy [] 
                    append/only either temp [temp][list-collection] local-blk 
                    append/only refs local-blk)
                opt ["t" copy len 2 skip (n: to-integer len) n skip ]
                "l" copy len 4 skip (n: to-integer len)
                n [
                    [string (append local-blk string-data)] |
                    [map (append/only local-blk map-obj)] |
                    [list] |
                    [ref  (append/only local-blk refs/(ref-index)) ]
                ]
                end-symbol (local-blk: temp)
            ]

map:        [   
                "M"
                "t" copy len 2 skip (type-len: to-integer len) 
                    (map-blk: copy [] map-obj: make map! map-blk)
                    copy type-data type-len skip (if type-len > 0 [ append map-blk reduce ['type to-string type-data] map-obj: construct-obj map-blk])
                    any [
                        (key: 'none val: 'none)
                        [[int (key: data)] | [string (key: string-data)] ]
                        [[int (val: data)] | [string (val: string-data)] | [ref ( val: 'refs/(ref-index))]]
                        (append map-blk reduce [key val])
                        (either type-len > 0 [ map-obj: construct-obj map-blk ] [ map-obj: make map! map-blk])
                        (append/only refs map-obj)
                    ]
                end-symbol
            ]

ref:        [
                "R" 
                copy data 4 skip (ref-index: (to-integer data) + 1)
                ; (ref-obj: refs/(ref-index))
            ]

end-symbol: charset "z"

; as Red only support 32-bits integer at present, we need this way to deal with long numbers
from-timestamp: func [ high-part low-part ][
    high: to-integer high-part
    low:  to-integer low-part
    return to date! to-integer (round (high * ((power 2 32 ) / 1000) + (low / 1000)))
]

to-timestamp: func [ the-date ][
    timestamp-float: (to-float to-integer the-date) * 1000
    high: to-integer round(timestamp-float / (power 2 32 ))
    low:  to-integer round(timestamp-float - (high * (power 2 32 )))
    return rejoin [to-binary high to-binary low]
]

decode-surrogate-pair: func [ high low /local code][
    ; ?? high
    ; ?? low
    code: to-integer #{010000}
    code: (((to-integer to-char to-string high) and (to-integer #{03FF})) << 10) + code
    code: (((to-integer to-char to-string low) and (to-integer #{03FF}))) + code
    return to-binary to-char code
]

; deal with surrogate pairs after utf-8 char(s) have bean collected, regardless of performance
after-chars-collected: func [ intermediate-chars [string!]][
    if empty? intermediate-chars [ return "" ]
    rejoin parse string-data [ 
        collect [
            any [ set a-char skip [
                if((a-char  >= (to-char "^(D800)")) and (a-char < (to-char "^(DBFF)"))) copy next-char skip keep (to-string decode-surrogate-pair (to-binary a-char) (to-binary next-char)) |
                keep (a-char)
            ]]
        ]
    ]
]

construct-obj: func [ blk ][
    ; probe blk
    ; probe refs
    blk: copy []
    foreach [k v] map-blk [append blk reduce [to-set-word k v]]
    object blk
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
                string (keep string-data) |
                binary (keep buf) |
                list ( keep/only list-collection/1 ) |
                map (keep/only map-obj ) |
            ]
            end-symbol
        ]
    ]

    result/1
]

encode: func [ arg ][
    ; probe arg
    arg-type: type? reduce arg
    switch to-word arg-type [
        none! [to-binary "N"]
        logic! [to-binary either arg ["T"] ["F"]]
        date! [rejoin [to-binary "d" to-timestamp arg ]]
        binary! [ encode-binary arg ]
        integer! [rejoin [to-binary "I" to-binary arg]]
        float! [rejoin [to-binary "D" to-binary arg]]
        string! [ encode-string arg ]
    ]
]

encode-binary: func [ data [binary!]][
    len: length? data
    n: to-integer round (len / 255)
    remainer: len // 255
    flag-1: rejoin [to-binary "b" at (to-binary 255) 3 ]
    flag-2: rejoin [to-binary "B" at (to-binary remainer) 3 ]
    parse data [
        n [
            insert flag-1 255 skip
        ]
        insert flag-2 to end
    ]

    data
]

encode-string: func [data [string!] /local i][
    part-len: 65535
    len: length? data
    n: to-integer round (len / part-len)
    remainer: len // part-len
    result: copy #{}
    collect/into [
        repeat i n [ keep rejoin [ to-binary "s" at to-binary part-len 3 to-binary (copy/part (at data (i - 1) * part-len + 1) part-len)]]
        keep rejoin [ to-binary "S" at to-binary remainer 3 to-binary at data (n * part-len) + 1 ]
    ] result
    result
]
    
    