import context
import json
import vest

struct Headers {
	accept string [json: 'Accept']
	host string [json: 'Host']
	user_agent string [json: 'User-Agent']
}

struct Response {
	url string
	headers Headers
}

fn main() {
	c := vest.new(
		vest.with_base_url('https://httpbin.org'),
	)

	resp := c.get(context.background(), '/get') or {
		eprintln(err)
		return
	}

	mut r := json.decode(Response, resp.body) or {
		eprintln('Failed to parse json')
		return
	}

	println(r)
}
