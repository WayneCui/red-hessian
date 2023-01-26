Red [

]

do %hessian-v1-parser.red

hessian-proxy: make object! [
    run: func[ method /arg args ][
        arguments: copy #{}
        ; probe reduce [method args]
        if arg [
            foreach a reduce args [
                append arguments encode a
            ]
        ]

        ; method: "replyDate_1"
        ; probe to-binary "c^A^@m^@^KreplyDate_1z"
        data: rejoin [to-binary "c" #{0100} to-binary "m" (at to-binary length? method 3) to-binary method arguments to-binary "z"]
        ; probe data
        result: write/binary http://127.0.0.1:55967/api compose [
            post [
                ; Host: "hessian.caucho.com"
                Content-type: "application/x-hessian"
                Accept-Encoding: "identity"
                User-Agent: "red-hessian/0.0.1"
                Accept-Charset: "*"
            ]
            (data)
        ]

        ; if method = "replyUntypedMap_1" [ probe result]
        ; probe result
        decode result
    ]
]