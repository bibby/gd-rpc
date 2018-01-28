## rpc-threaded.gd
# A threaded RPC channel using HTTPClient
# @author Kirill Omelchenko<kirill.omelchenko@gmail.com>
# Based on the work of
# @author bibby<bibby@bbby.org>
#
## publics
# new( host, port )
#
# resetHeaders()
# setHeaders( dict )
# setHeader( name, val)
#
# get( url )
# post( url, body )
# put( url, body )
# delete( url )
extends Node


var RPCResponse = preload("rpcresponse.gd")

var _host = "localhost" # override with new()
var _port = 80
var _error = ""
var _headers = {}

var client = HTTPClient.new()

var request_queue = []
var request_queue_busy = false
var request_thread = Thread.new()

# override default new()
func _init(host = "localhost", port = "80"):
	_host = host
	_port = port
	_headers = {"User-Agent": "Godot Game Engine"}

func _ready():
	set_process(true)

func _process(delta):
	process_request_queue()

func get(url):
	return _request( HTTPClient.METHOD_GET, url, "")

# TODO, form encode collections if desired
func post(url, body):
	return _request(HTTPClient.METHOD_POST, url, body)

func put(url, body):
	return _request(HTTPClient.METHOD_PUT, url, body)

func delete(url):
	return _request(HTTPClient.METHOD_DELETE, url, "")

func resetHeaders():
	_headers = {}

func setHeaders(headerDict):
	for k in headerDict:
		setHeader(k, headerDict[k])

func setHeader(headerName, value):
	_headers[headerName] = value

func add_to_request_queue(item):
	request_queue_busy = true

	request_queue.append(item)

	request_queue_busy = false

func del_from_request_queue(item):
	request_queue_busy = true

	if request_queue.has(item):
		request_queue.erase(item)

	request_queue_busy = false

func process_request_queue():
	if request_queue.empty():
	    return
	
	if request_queue_busy and request_thread.is_active():
	    return
	
	request_thread.start(self, '__request', request_queue[0])

func _request_sent(request_item):
	var res = request_thread.wait_to_finish()
	var method = request_item[0]
	var url = request_item[1]
	var body = request_item[2]

	del_from_request_queue([method, url, body])

	return res

func _request(method, url, body):
	add_to_request_queue([method, url, body])

func __request(request_item):
	var res = _connect()
	var method = request_item[0]
	var url = request_item[1]
	var body = request_item[2]

	if(res.hasError()):
		return res
	else:
		var headers = StringArray()

		for h in _headers:
			headers.push_back(h + ": " + _headers[h])

		client.request(method, url, headers, body)

	res = _poll();
	client.close()

	call_deferred('_request_sent', [method, url, body])

	return res

func _connect():
	client.connect(_host, _port)
	
	return _poll()

func _poll():
	var status = -1
	var current_status

	while(true):
		client.poll()
		current_status = client.get_status()

		if( status != current_status ):
			status = current_status
			if( status == HTTPClient.STATUS_RESOLVING ):
				continue

			elif( status == HTTPClient.STATUS_REQUESTING ):
				continue

			elif( status == HTTPClient.STATUS_CONNECTING ):
				continue

			elif( status == HTTPClient.STATUS_CONNECTED ):
				return _respond(status)

			elif( status == HTTPClient.STATUS_DISCONNECTED ):
				return _errorResponse("Disconnected from Host")

			elif( status == HTTPClient.STATUS_CANT_RESOLVE ):
				return _errorResponse("Can't Resolve Host")

			elif( status == HTTPClient.STATUS_CANT_CONNECT ):
				return _errorResponse("Can't Connect to Host")

			elif( status == HTTPClient.STATUS_CONNECTION_ERROR ):
				return _errorResponse("Connection Error")

			elif( status == HTTPClient.STATUS_BODY ):
				return _parseBody()

func _parseBody():
	var body = client.read_response_body_chunk().get_string_from_utf8()
	var response = _respond(body)

	if(response.getResponseCode() >= 400):
		return response.setIsError(true)

	return response

func _respond(body):
	var response = RPCResponse.new()

	response._body = body
	response._response_code = client.get_response_code()
	response._body_length = client.get_response_body_length()
	response._headers = client.get_response_headers_as_dictionary()

	return response

func _errorResponse(body):
	var response = _respond(body)

	response.setIsError( true )

	return response
