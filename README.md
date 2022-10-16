# vest
REST client in [V](https://vlang.io).

# Installing
```shell
v install alexferl.vest
```

# Using
More complex examples [here](examples).

```v
import context
import vest

fn main() {
	c := vest.new(
		vest.with_base_url('https://httpbin.org'),
	)

	resp := c.get(context.background(), '/get') or {
		eprintln(err)
		return
	}

	println(resp.body)
}
```
