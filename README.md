gd-rpc-threaded
======

Threaded Web requests in GDScript for [Godot game engine](github.com/okamstudio/godot).

## Installation
*rpc* and *rpcresponse* are [GDScript](https://github.com/okamstudio/godot/wiki/gdscript)s, so you need only drop into your Godot project's resourse location. They are standalone classes; They do inherit from a built-in type.

## Use

### rpc

```
var RPC = preload("rpc.gd")
var www

func _init():
    www = RPC.new() # use "localhost", on port 80
    # or for "http://myhost.example:1234":
    www = RPC.new("myhost.example", 1234)

```

By default, the `www` object has a user-agent header set. You may set your own headers. This is done separate from any actual request.

```
# remove user agent
www.resetHeaders()

# set one header
www.setHeader("Authorization", authToken)

# set many headers
www.setHeaders({
    "Accept": "*",
    "Content-Type": "application/json"
})
```

With host, port, and headers configured, make your HTTP request.

```
r = www.get("/users")
r = www.post("/ratings/" + id, '{"rating":4,"review":"ok"}')
r = www.delete("/reviews/12")
```

##rpcresponse

Every request (using `get`, `post`, `put`, `delete`) returns a RpcResponse object, a data container with the response's HTTP Status code, body, and headers. Check for errors before assuming all went well;

```
response = www.get("/something")
if( response.isError() ):
    handleError( response.getResponseCode() )
else:
    handleSuccess( response.getBody() )
```

#TODO
* Optional form encoding for http-post
* Optional url encoding for http-get param dictionaries
* SSL support
* support for binarieys and biger files (chunked get/post)
* handel Redirects

# Contributing

Please, if you have a feature you'd like to have added, create an issue on github or send a pull request.
