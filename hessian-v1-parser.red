Red [

]

byte: 'skip
null:       charset "N"
boolean-T:  charset "T"
boolean-F:  charset "F"
int:        ["I" copy data 4 skip (data: to-integer data)]


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
                int (keep data) 

            ]
            end-symbol
        ]
    ]

    result/1
]
