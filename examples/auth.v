import context
import vest

fn main() {
	c := vest.new(vest.with_auth('Bearer token'))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
