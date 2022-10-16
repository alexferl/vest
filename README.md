# vest
REST client in [V](https://vlang.io).

# Using
## Simple GET:
```v
import context
import vest

fn main() {
	c := vest.new(
		vest.with_base_url('https://httpbin.org'),
	)

	resp := c.get(context.background(), '/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
```

## Simple POST:
```v
import context
import vest
import vest.bytes

fn main() {
	c := vest.new(
		vest.with_base_url('https://httpbin.org'),
	)

	body := '{\"hello\": \"world\"}'
	resp := c.post(context.background(), '/post', bytes.new_buffer(body.bytes())) or {
		eprintln(err)
		return
	}

	println(resp.body)
}
```

## JSON GET:
```v
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
```
