Red []

; https://blog.csdn.net/u012842630/article/details/85726870
do %quick-test.red
do %../hessian-proxy.red

http-port: 55002
hessian-proxy: make hessian-proxy-base [
    end-point: to-url rejoin ["http://127.0.0.1:" http-port "/api"]
]

~~~start-file~~~ "encode"

===start-group=== "arg-none tests"
    --test-- "arg-none-1"	--assert true = hessian-proxy/run/arg "argNull" [none]

===start-group=== "arg-logic tests"
    --test-- "arg-logic-1"	--assert true = hessian-proxy/run/arg "argFalse" [false]
    --test-- "arg-logic-2"	--assert true = hessian-proxy/run/arg "argTrue" [true]

===start-group=== "arg-date tests"
    --test-- "arg-date-1"	--assert true = hessian-proxy/run/arg "argDate_0" [1970-01-01/00:00:00]
    --test-- "arg-date-2"	--assert true = hessian-proxy/run/arg "argDate_1" [1998-05-08/9:51:31]
    --test-- "arg-date-2"	--assert true = hessian-proxy/run/arg "argDate_2" [1998-05-08/9:51:00+00:00]

===end-group===
~~~end-file~~~