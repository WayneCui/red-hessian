Red []

; https://blog.csdn.net/u012842630/article/details/85726870
do %quick-test.red
do %../hessian-proxy.red

http-port: 63357
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

===start-group=== "arg-int tests"
    --test-- "arg-int-1"	--assert true = hessian-proxy/run/arg "argInt_0" [0]
    --test-- "arg-int-2"	--assert true = hessian-proxy/run/arg "argInt_1" [1]
    --test-- "arg-int-3"	--assert true = hessian-proxy/run/arg "argInt_0x30" [to-integer #{30}]
    --test-- "arg-int-4"	--assert true = hessian-proxy/run/arg "argInt_0x3ffff" [to-integer #{03ffff}]
    --test-- "arg-int-5"	--assert true = hessian-proxy/run/arg "argInt_0x40000" [to-integer #{040000}]
    --test-- "arg-int-6"	--assert true = hessian-proxy/run/arg "argInt_0x7ff" [to-integer #{07ff}]
    --test-- "arg-int-7"	--assert true = hessian-proxy/run/arg "argInt_0x7fffffff" [to-integer #{7fffffff}]
    --test-- "arg-int-8"	--assert true = hessian-proxy/run/arg "argInt_0x800" [to-integer #{0800}]
    --test-- "arg-int-9"	--assert true = hessian-proxy/run/arg "argInt_47" [47]
    --test-- "arg-int-10"	--assert true = hessian-proxy/run/arg "argInt_m0x40000" [negate to-integer #{040000}]
    --test-- "arg-int-11"	--assert true = hessian-proxy/run/arg "argInt_m0x40001" [negate to-integer #{040001}]
    --test-- "arg-int-12"	--assert true = hessian-proxy/run/arg "argInt_m0x800" [negate to-integer #{0800}]
    --test-- "arg-int-13"	--assert true = hessian-proxy/run/arg "argInt_m0x80000000" [to-integer #{80000000}]
    --test-- "arg-int-14"	--assert true = hessian-proxy/run/arg "argInt_m0x801" [negate to-integer #{0801}]
    --test-- "arg-int-15"	--assert true = hessian-proxy/run/arg "argInt_m16" [-16]
    --test-- "arg-int-16"	--assert true = hessian-proxy/run/arg "argInt_m17" [-17]

===start-group=== "arg-double tests"
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_0_0" [0.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_0_001" [0.001]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_1_0" [1.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_127_0" [127.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_128_0" [128.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_2_0" [2.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_3_14159" [3.14159]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_32767_0" [32767.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_65_536" [65.536]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_m0_001" [-0.001]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_m128_0" [-128.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_m129_0" [-129.0]
    --test-- "arg-double-1"	--assert true = hessian-proxy/run/arg "argDouble_m32768_0" [-32768.0]

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