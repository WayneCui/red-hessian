Red [
]

do %quick-test.red
do %../hessian-proxy.red

~~~start-file~~~ "parser"

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

===end-group===
~~~end-file~~~