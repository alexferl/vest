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

	resp := c.post(context.background(), '/get') or {
		println(err)
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
		println(err)
		return
	}

	println(resp.body)
}
```
