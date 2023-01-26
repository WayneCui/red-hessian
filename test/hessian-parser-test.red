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

===end-group===
~~~end-file~~~