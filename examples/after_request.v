import context
import alexferl.vest

fn after(mut resp vest.Response) ? {
	println('received $resp.status_code: $resp.status_msg')
}

fn main() {
	c := vest.new(vest.with_after_request(after))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
