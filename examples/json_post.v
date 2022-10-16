import context
import json
import vest
import vest.bytes

struct Payload {
	hello string
}

struct Headers {
	accept string [json: 'Accept']
	host string [json: 'Host']
	user_agent string [json: 'User-Agent']
}

struct Response {
	url string
	headers Headers
	json Payload
}

fn main() {
	c := vest.new(
		vest.with_base_url('https://httpbin.org'),
	)

	payload := Payload{hello: "world"}
	body := bytes.new_buffer(json.encode(payload).bytes())
	resp := c.post(context.background(), '/post', body) or {
		eprintln(err)
		return
	}

	mut r := json.decode(Response, resp.body) or {
		eprintln('Failed to parse json')
		return
	}

	println(r)
}
