## rpcresponse.gd
# A reponse object for RPC
# @author bibby<bibby@bbby.org>
#

var _is_error = false
var _response_code = 0
var _body = ""
var _body_length = 0
var _headers

func hasError():
	return _is_error

func getBody():
	return _body

func getResponseCode():
	return _response_code

func getBodyLength():
	return _body_length

func getHeaders():
	return _headers