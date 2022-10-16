import context
import alexferl.vest

fn main() {
	c := vest.new(vest.with_content_type('application/xml'))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
