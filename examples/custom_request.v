import context
import net.http
import vest
import vest.bytes

fn main() {
	c := vest.new()

	mut req := c.new_request(context.background(), http.Method.get, 'https://httpbin.org/get',
		bytes.new_buffer([]u8{})) or {
		eprintln(err)
		return
	}
	resp := c.do(mut req) or {
		eprintln(err)
		return
	}

	println(resp.body)
}
