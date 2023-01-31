Red [
]

do %quick-test.red
do %../hessian-proxy.red

~~~start-file~~~ "parser"

; start a server
tmp-file: %port.tmp
pid: call/output "java -jar ../support/hessian-test-servlet.jar" tmp-file
data: read/lines tmp-file 
parse data/1 [
    thru "Listening on http port: " copy http-port to "," to end
]
?? http-port
delete tmp-file

hessian-proxy: make hessian-proxy-base [
    point: to-url rejoin ["http://127.0.0.1:" http-port "/api"]
]

===start-group=== "none tests"
	--test-- "none-1"	--assert none = hessian-proxy/run "replyNull"

===start-group=== "logic tests"
	--test-- "logic-1"	--assert true = hessian-proxy/run "replyTrue"
    --test-- "logic-2"	--assert false = hessian-proxy/run "replyFalse"

===start-group=== "int tests"
	--test-- "int-1"	--assert 0 = hessian-proxy/run "replyInt_0"
    --test-- "int-2"	--assert (to-integer #{30}) = hessian-proxy/run "replyInt_0x30"
    --test-- "int-3"	--assert (to-integer #{03ffff}) = hessian-proxy/run "replyInt_0x3ffff"
    --test-- "int-4"	--assert (to-integer #{040000}) = hessian-proxy/run "replyInt_0x40000"
    --test-- "int-5"	--assert (to-integer #{07ff}) = hessian-proxy/run "replyInt_0x7ff"
    --test-- "int-6"	--assert (to-integer #{7fffffff}) = hessian-proxy/run "replyInt_0x7fffffff"
    --test-- "int-7"	--assert (to-integer #{0800}) = hessian-proxy/run "replyInt_0x800"
    --test-- "int-8"	--assert 1 = hessian-proxy/run "replyInt_1"
    --test-- "int-9"	--assert 47 = hessian-proxy/run "replyInt_47"
    --test-- "int-10"	--assert (negate to-integer #{040000}) = hessian-proxy/run "replyInt_m0x40000"
    --test-- "int-11"	--assert (negate to-integer #{040001}) = hessian-proxy/run "replyInt_m0x40001"
    --test-- "int-12"	--assert (negate to-integer #{0800}) = hessian-proxy/run "replyInt_m0x800"
    --test-- "int-13"	--assert (to-integer #{80000000}) = hessian-proxy/run "replyInt_m0x80000000"
    --test-- "int-14"	--assert (negate to-integer #{0801}) = hessian-proxy/run "replyInt_m0x801"
    --test-- "int-15"	--assert -16 = hessian-proxy/run "replyInt_m16"
    --test-- "int-16"	--assert -17 = hessian-proxy/run "replyInt_m17"

===start-group=== "float tests"
    ; probe hessian-proxy/run "replyDouble_0_001"
	--test-- "float-1"	--assert 0.0 = hessian-proxy/run "replyDouble_0_0"
    --test-- "float-2"	--assert 0.001 = hessian-proxy/run "replyDouble_0_001"
    --test-- "float-3"	--assert 1.0 = hessian-proxy/run "replyDouble_1_0"
    --test-- "float-4"	--assert 127.0 = hessian-proxy/run "replyDouble_127_0"
    --test-- "float-5"	--assert 128.0 = hessian-proxy/run "replyDouble_128_0"
    --test-- "float-6"	--assert 2.0 = hessian-proxy/run "replyDouble_2_0"
    --test-- "float-7"	--assert 3.14159 = hessian-proxy/run "replyDouble_3_14159"
    --test-- "float-8"	--assert 32767.0 = hessian-proxy/run "replyDouble_32767_0"
    --test-- "float-9"	--assert 65.536 = hessian-proxy/run "replyDouble_65_536"
    --test-- "float-10"	--assert -0.001 = hessian-proxy/run "replyDouble_m0_001"
    --test-- "float-11"	--assert -128.0 = hessian-proxy/run "replyDouble_m128_0"
    --test-- "float-12"	--assert -129.0 = hessian-proxy/run "replyDouble_m129_0"
    --test-- "float-13"	--assert -32768.0 = hessian-proxy/run "replyDouble_m32768_0"

===start-group=== "date tests"
	--test-- "date-1"	--assert 1970-1-1/0:0:0 = hessian-proxy/run "replyDate_0"
    --test-- "date-2"	--assert 1998-5-8/9:51:31 = hessian-proxy/run "replyDate_1"
    --test-- "date-3"	--assert 1998-5-8/9:51:0 = hessian-proxy/run "replyDate_2"

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

===start-group=== "string tests"
    --test-- "string-1" --assert "" = hessian-proxy/run "replyString_0"
    --test-- "string-2" --assert "0" = hessian-proxy/run "replyString_1"
    --test-- "string-3" --assert "0123456789012345678901234567890" = hessian-proxy/run "replyString_31"
    --test-- "string-4" --assert "01234567890123456789012345678901" = hessian-proxy/run "replyString_32"
    --test-- "string-5" --assert (copy/part long-string-1024 1023) = hessian-proxy/run "replyString_1023"
    --test-- "string-6" --assert long-string-1024 = hessian-proxy/run "replyString_1024"
    --test-- "string-7" --assert long-string-65536 = hessian-proxy/run "replyString_65536"
    ; U+1F603  128515 #{F09F9883}
    --test-- "string-8" --assert "😃" = hessian-proxy/run "replyString_emoji"
    --test-- "string-9" --assert "é" = hessian-proxy/run "replyString_unicodeTwoOctetsCompact"
    --test-- "string-10" --assert "字" = hessian-proxy/run "replyString_unicodeThreeOctetsCompact"
    --test-- "string-11" --assert (rejoin collect [loop 64 [keep "é"]]) = hessian-proxy/run "replyString_unicodeTwoOctets"
    --test-- "string-12" --assert (rejoin collect [loop 64 [keep "字"]]) = hessian-proxy/run "replyString_unicodeThreeOctets"

===start-group=== "binary tests"
	--test-- "binary-1"	--assert (to-binary "") = hessian-proxy/run "replyBinary_0"
    --test-- "binary-2"	--assert (to-binary "0") = hessian-proxy/run "replyBinary_1"
    --test-- "binary-3"	--assert (to-binary copy/part long-string-1024 1023) = hessian-proxy/run "replyBinary_1023"
    --test-- "binary-4"	--assert (to-binary long-string-1024) = hessian-proxy/run "replyBinary_1024"
    --test-- "binary-5"	--assert (to-binary "012345678901234") = hessian-proxy/run "replyBinary_15"
    --test-- "binary-6"	--assert (to-binary "0123456789012345") = hessian-proxy/run "replyBinary_16"
    --test-- "binary-7"	--assert (to-binary long-string-65536) = hessian-proxy/run "replyBinary_65536"

===start-group=== "list tests"
    --test-- "list-1" --assert [] = hessian-proxy/run "replyUntypedFixedList_0"
    --test-- "list-2" --assert ["1"] = hessian-proxy/run "replyUntypedFixedList_1"
    --test-- "list-3" --assert ["1" "2" "3" "4" "5" "6" "7"] = hessian-proxy/run "replyUntypedFixedList_7"
    --test-- "list-4" --assert ["1" "2" "3" "4" "5" "6" "7" "8"] = hessian-proxy/run "replyUntypedFixedList_8"
    --test-- "list-5" --assert [] = hessian-proxy/run "replyTypedFixedList_0"
    --test-- "list-6" --assert ["1"]  = hessian-proxy/run "replyTypedFixedList_1"
    --test-- "list-7" --assert ["1" "2" "3" "4" "5" "6" "7"] = hessian-proxy/run "replyTypedFixedList_7"
    --test-- "list-8" --assert ["1" "2" "3" "4" "5" "6" "7" "8"] = hessian-proxy/run "replyTypedFixedList_8"

    obj: make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
    objs: reduce [obj obj]
    reference: reduce [objs objs]
    --test-- "list-9" --assert reference = hessian-proxy/run "replyListOfListWithRefs"

===start-group=== "map tests"
    --test-- "map-1" --assert (make map! []) = hessian-proxy/run "replyUntypedMap_0"
    --test-- "map-2" --assert (make map! ["a" 0]) = hessian-proxy/run "replyUntypedMap_1"
    --test-- "map-3" --assert (make map! [0 "a" 1 "b"]) = hessian-proxy/run "replyUntypedMap_2"
    ; probe hessian-proxy/run "replyUntypedMap_3"
    ; --test-- "map-4" --assert (make map! [["a"] 0]) = hessian-proxy/run "replyUntypedMap_3"


===start-group=== "object tests"
    --test-- "object-1" --assert (make object! [type: "com.caucho.hessian.test.A0"]) = hessian-proxy/run "replyObject_0"
    --test-- "object-2" --assert (make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]) = hessian-proxy/run "replyObject_1"
    
    expectedObject2: reduce [
        make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
        make object! [type: "com.caucho.hessian.test.TestObject" _value: 1]
    ]
    --test-- "object-3" --assert expectedObject2 = hessian-proxy/run "replyObject_2"

    expectedObject2a:  reduce [
        make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
        make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
    ]
    --test-- "object-4" --assert expectedObject2a = hessian-proxy/run "replyObject_2a"

    expectedObject2b: reduce [
        make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
        make object! [type: "com.caucho.hessian.test.TestObject" _value: 0]
    ]
    --test-- "object-5" --assert expectedObject2b = hessian-proxy/run "replyObject_2b"

    ; expected-object3: make object! [type: "com.caucho.hessian.test.TestCons" _first: "a" _rest: none]
    ; expected-object3/_rest: expected-object3
    ; probe expected-object3
    ; probe hessian-proxy/run "replyObject_3"
    ; --test-- "object-6" --assert expected-object3 = hessian-proxy/run "replyObject_3"
    
    expectedObject16: reduce [
        make object! [type: "com.caucho.hessian.test.A0"]
        make object! [type: "com.caucho.hessian.test.A1"]
        make object! [type: "com.caucho.hessian.test.A2"]
        make object! [type: "com.caucho.hessian.test.A3"]
        make object! [type: "com.caucho.hessian.test.A4"]
        make object! [type: "com.caucho.hessian.test.A5"]
        make object! [type: "com.caucho.hessian.test.A6"]
        make object! [type: "com.caucho.hessian.test.A7"]
        make object! [type: "com.caucho.hessian.test.A8"]
        make object! [type: "com.caucho.hessian.test.A9"]
        make object! [type: "com.caucho.hessian.test.A10"]
        make object! [type: "com.caucho.hessian.test.A11"]
        make object! [type: "com.caucho.hessian.test.A12"]
        make object! [type: "com.caucho.hessian.test.A13"]
        make object! [type: "com.caucho.hessian.test.A14"]
        make object! [type: "com.caucho.hessian.test.A15"]
        make object! [type: "com.caucho.hessian.test.A16"]
    ]

    --test-- "object-7" --assert expectedObject16 = hessian-proxy/run "replyObject_16"

===end-group===
~~~end-file~~~

?? pid
call rejoin ["kill " pid]