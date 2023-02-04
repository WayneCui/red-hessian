Red []

; https://blog.csdn.net/u012842630/article/details/85726870
do %quick-test.red
do %../hessian-proxy.red

http-port: 55002
hessian-proxy: make hessian-proxy-base [
    end-point: to-url rejoin ["http://127.0.0.1:" http-port "/api"]
]

~~~start-file~~~ "encode"
long-string-1024: func[/local s i][
    base: " 456789012345678901234567890123456789012345678901234567890123^/"
    s: copy ""
    repeat i 16 [
        append s rejoin [ to-integer (i - 1) / 10 (i - 1) // 10 base]
    ]
    s
]

long-string-65536: func[/local s i][
    base: " 56789012345678901234567890123456789012345678901234567890123^/"
    s: copy ""
    repeat i 1024 [
        append s rejoin [ to-integer (i - 1) / 100 remainder (to-integer (i - 1) / 10) 10  remainder (i - 1) 10 base]
    ]
    copy/part s 65536
]

===start-group=== "arg-none tests"
    --test-- "arg-none-1"	--assert true = hessian-proxy/run/arg "argNull" [none]

===start-group=== "arg-logic tests"
    --test-- "arg-logic-1"	--assert true = hessian-proxy/run/arg "argFalse" [false]
    --test-- "arg-logic-2"	--assert true = hessian-proxy/run/arg "argTrue" [true]

===start-group=== "arg-date tests"
    --test-- "arg-date-1"	--assert true = hessian-proxy/run/arg "argDate_0" [1970-01-01/00:00:00]
    --test-- "arg-date-2"	--assert true = hessian-proxy/run/arg "argDate_1" [1998-05-08/9:51:31]
    --test-- "arg-date-2"	--assert true = hessian-proxy/run/arg "argDate_2" [1998-05-08/9:51:00+00:00]

===start-group=== "arg-binary tests"
    --test-- "arg-binary-1"	--assert true = hessian-proxy/run/arg "argBinary_0" [(to-binary "")]
    --test-- "arg-binary-2"	--assert true = hessian-proxy/run/arg "argBinary_1" [(to-binary "0")]
    --test-- "arg-binary-3"	--assert true = hessian-proxy/run/arg "argBinary_1023" [(to-binary copy/part long-string-1024 1023)]
    --test-- "arg-binary-4"	--assert true = hessian-proxy/run/arg "argBinary_1024" [(to-binary long-string-1024)]
    --test-- "arg-binary-5"	--assert true = hessian-proxy/run/arg "argBinary_15" [(to-binary "012345678901234")]
    --test-- "arg-binary-6"	--assert true = hessian-proxy/run/arg "argBinary_16" [ (to-binary "0123456789012345")]
    --test-- "arg-binary-7"	--assert true = hessian-proxy/run/arg "argBinary_65536" [ (to-binary long-string-65536)]

===end-group===
~~~end-file~~~