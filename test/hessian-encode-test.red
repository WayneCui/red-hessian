Red []

; https://blog.csdn.net/u012842630/article/details/85726870
do %quick-test.red
do %../hessian-proxy.red

http-port: 52695
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

===start-group=== "arg-string tests"
    --test-- "arg-string-1"	--assert true = hessian-proxy/run/arg "argString_0" [""]
    --test-- "arg-string-2"	--assert true = hessian-proxy/run/arg "argString_1" ["0"]
    --test-- "arg-string-3"	--assert true = hessian-proxy/run/arg "argString_31" ["0123456789012345678901234567890"]
    --test-- "arg-string-4"	--assert true = hessian-proxy/run/arg "argString_32" ["01234567890123456789012345678901"]
    --test-- "arg-string-5"	--assert true = hessian-proxy/run/arg "argString_1023" [copy/part long-string-1024 1023]
    --test-- "arg-string-6"	--assert true = hessian-proxy/run/arg "argString_1024" [long-string-1024]
    --test-- "arg-string-7"	--assert true = hessian-proxy/run/arg "argString_65536" [long-string-65536]
    --test-- "arg-string-8"	--assert true = hessian-proxy/run/arg "argString_emoji" ["😃"]
    --test-- "arg-string-9"	--assert true = hessian-proxy/run/arg "argString_unicodeTwoOctetsCompact" ["é"]
    --test-- "arg-string-10" --assert true = hessian-proxy/run/arg "argString_unicodeThreeOctetsCompact" ["字"]
    --test-- "arg-string-11" --assert true = hessian-proxy/run/arg "argString_unicodeTwoOctets" [rejoin collect [loop 64 [keep "é"]]]
    --test-- "arg-string-12" --assert true = hessian-proxy/run/arg "argString_unicodeThreeOctets" [rejoin collect [loop 64 [keep "字"]]]

; ===start-group=== "arg-map tests"
;     --test-- "arg-map-1"	--assert true = hessian-proxy/run/arg "argUntypedMap_0" [#()]
;     --test-- "arg-map-2"	--assert true = hessian-proxy/run/arg "argUntypedMap_0" [#("a": 0)]
;     --test-- "arg-map-3"	--assert true = hessian-proxy/run/arg "argUntypedMap_0" [#(0: "a" 1: "b")]

; ===start-group=== "arg-object tests"
;     --test-- "arg-object-1"	--assert true = hessian-proxy/run/arg "argObject_0" [make object! [type: "com.caucho.hessian.test.A0"]]
;     --test-- "arg-object-2"	--assert true = hessian-proxy/run/arg "argObject_1" [make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]]
    
;     argObject2: reduce [
;         make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
;         make object! [type: "com.caucho.hessian.test.TestObject" _value: 1]
;     ]
;     --test-- "arg-object-3"	--assert true = hessian-proxy/run/arg "argObject_2" [argObject2]

;     argObject2a:  reduce [
;         make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
;         make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
;     ]
;     --test-- "arg-object-4"	--assert true = hessian-proxy/run/arg "argObject_2a" [argObject2a]
    
;     argObject2b:  reduce [
;         make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
;         make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
;     ]
;     --test-- "arg-object-5"	--assert true = hessian-proxy/run/arg "argObject_2b" [argObject2b]

;     ; arg-object3: make object! [type: "com.caucho.hessian.test.TestCons" _first: "a" _rest: none]
;     ; arg-object3/_rest: expected-object3
;     --test-- "arg-object-6"	--assert true = hessian-proxy/run/arg "argObject_3" [arg-object3]

    
;     argObject16: reduce [
;         make object! [type: "com.caucho.hessian.test.A0"]
;         make object! [type: "com.caucho.hessian.test.A1"]
;         make object! [type: "com.caucho.hessian.test.A2"]
;         make object! [type: "com.caucho.hessian.test.A3"]
;         make object! [type: "com.caucho.hessian.test.A4"]
;         make object! [type: "com.caucho.hessian.test.A5"]
;         make object! [type: "com.caucho.hessian.test.A6"]
;         make object! [type: "com.caucho.hessian.test.A7"]
;         make object! [type: "com.caucho.hessian.test.A8"]
;         make object! [type: "com.caucho.hessian.test.A9"]
;         make object! [type: "com.caucho.hessian.test.A10"]
;         make object! [type: "com.caucho.hessian.test.A11"]
;         make object! [type: "com.caucho.hessian.test.A12"]
;         make object! [type: "com.caucho.hessian.test.A13"]
;         make object! [type: "com.caucho.hessian.test.A14"]
;         make object! [type: "com.caucho.hessian.test.A15"]
;         make object! [type: "com.caucho.hessian.test.A16"]
;     ]
;     --test-- "arg-object-3"	--assert true = hessian-proxy/run/arg "argObject_16" [argObject16]

; ===start-group=== "arg-list tests"
;     --test-- "arg-list-1"	--assert true = hessian-proxy/run/arg "argUntypedFixedList_0" [[]]
;     --test-- "arg-list-2"	--assert true = hessian-proxy/run/arg "argUntypedFixedList_1" [["1"]]
;     --test-- "arg-list-3"	--assert true = hessian-proxy/run/arg "argUntypedFixedList_7" [["1" "2" "3" "4" "5" "6" "7"]]
;     --test-- "arg-list-4"	--assert true = hessian-proxy/run/arg "argUntypedFixedList_8" [["1" "2" "3" "4" "5" "6" "7" "8"]]

;     obj: make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
;     objs: reduce [obj obj]
;     reference: reduce [objs objs]
;     --test-- "arg-list-5"	--assert true = hessian-proxy/run/arg "argListOfListWithRefs" [reference]

===end-group===
~~~end-file~~~