import context
import time
import vest

fn main() {
	c := vest.new()

	mut background := context.background()
	mut ctx, cancel := context.with_timeout(mut &background, time.second * 1)
	defer {
		cancel()
	}

	resp := c.get(ctx, 'https://httpbin.org/delay/2') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
