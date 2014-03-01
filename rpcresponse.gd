## rpcresponse.gd
# A reponse object for RPC
# @author bibby<bibby@bbby.org>
#

var is_error = false
var response_code = 0
var body = ""
var body_length = 0
var headers

func setIsError(bol):
	is_error = bol

func hasError():
	return is_error

func setBody(msg):
	body = str(msg)

func setBodyLength(len):
	body_length = len

func setResponseCode(code):
	response_code = code

func setHeaders(heads):
	headers = heads

func getBody():
	return body

func getResponseCode():
	return response_code

func getBodyLength():
	return body_length

func getHeaders():
	return headers
