import context
import alexferl.vest

fn before(mut req vest.Request) ! {
	println('sending ${req.method} to ${req.url}')
}

fn main() {
	c := vest.new(vest.with_before_request(before))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
