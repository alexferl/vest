import context
import vest

fn main() {
	headers := {'X-Hello': 'world'}
	c := vest.new(vest.with_headers(headers))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
