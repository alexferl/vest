import context
import alexferl.vest

fn main() {
	cookies := {
		'key': 'val'
	}
	c := vest.new(vest.with_cookies(cookies))

	resp := c.get(context.background(), 'https://httpbin.org/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
