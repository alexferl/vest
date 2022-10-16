import context
import vest

fn main() {
	c := vest.new(vest.with_validate(false))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
