module vest

import context
import json
import net.http
import time
import bytes
import testing

fn before(mut req Request) ! {
	req.version = http.Version.v2_0
}

fn after(mut resp Response) ! {
	resp.status_code = http.Status.created.int()
}

fn test_new_request() {
	method := http.Method.post
	url := 'https://example.com'
	endpoint := '/users'
	accept := 'application/xml'
	content_type := 'application/xml'
	version := http.Version.v2_0
	headers := {
		'X-Custom': 'value'
	}
	cookies := {
		'key': 'val'
	}
	read_timeout := 42 * time.second
	write_timeout := 42 * time.second
	validate := false
	root_ca := 'root'
	cert := 'cert'
	cert_key := 'cert.key'
	allow_redirect := false

	// vfmt off
	c := new(
		with_base_url(url),
		with_accept(accept),
		with_content_type(content_type),
		with_before_request(before),
		with_after_request(after),
		with_version(version),
		with_headers(headers),
		with_cookies(cookies),
		with_read_timeout(read_timeout),
		with_write_timeout(write_timeout),
		with_validate(validate),
		with_root_ca(root_ca),
		with_cert(cert),
		with_cert_key(cert_key),
		with_allow_redirect(allow_redirect)
	)
	// vfmt on

	req := c.new_request(context.background(), method, endpoint, bytes.new_buffer([]u8{})) or {
		panic(err)
	}

	assert method == req.method
	assert '${url}${endpoint}' == req.url
	assert content_type == req.header.get(http.CommonHeader.content_type)!
	assert version == req.version
	assert headers['X-Custom'] == req.header.get_custom('X-Custom')!
	assert cookies == req.cookies
	assert read_timeout == req.read_timeout
	assert write_timeout == req.write_timeout
	assert validate == req.validate
	assert root_ca == req.verify
	assert cert == req.cert
	assert cert_key == req.cert_key
	assert allow_redirect == req.allow_redirect
	assert get_user_agent() == req.user_agent
}

struct TestHandler {
	method      http.Method
	body        string
	status_code int
}

fn (h TestHandler) handle(req http.Request) http.Response {
	mut resp := http.Response{
		header: http.new_header_from_map({
			http.CommonHeader.content_type: 'text/plain'
		})
	}
	resp.body = h.body
	if h.status_code > 0 {
		resp.status_code = h.status_code
	} else {
		resp.status_code = http.Status.ok.int()
	}
	return resp
}

fn test_do() {
	method := http.Method.post
	body := 'do'
	mut s := testing.new_server(TestHandler{ method: method, body: body })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new(with_version(http.Version.v1_0), with_before_request(before))
	mut req := c.new_request(context.background(), method, s.url, bytes.new_buffer([]u8{})) or {
		panic(err)
	}
	resp := c.do(mut req) or { panic(err) }

	assert method == resp.request.method
	assert body == resp.body
	assert http.Version.v2_0 == resp.request.version
}

fn test_get() {
	body := 'get'
	method := http.Method.get
	mut s := testing.new_server(TestHandler{ method: method, body: body })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.get(context.background(), s.url)!

	assert method == resp.request.method
	assert body == resp.body
}

fn test_post() {
	body := 'post'
	method := http.Method.post
	mut s := testing.new_server(TestHandler{ method: method, body: body })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.post(context.background(), s.url, bytes.new_buffer(body.bytes()))!

	assert method == resp.request.method
	assert body == resp.body
}

struct Hello {
	hello string
}

fn test_post_json() {
	hello := Hello{
		hello: 'world'
	}
	body := json.encode(hello)
	method := http.Method.post
	mut s := testing.new_server(TestHandler{ method: method, body: body })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.post(context.background(), s.url, bytes.new_buffer(body.bytes()))!

	assert hello == resp.json[Hello]()!
}

fn test_put() {
	body := 'put'
	method := http.Method.put
	mut s := testing.new_server(TestHandler{ method: method, body: body })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.put(context.background(), s.url, bytes.new_buffer(body.bytes())) or { panic(err) }

	assert method == resp.request.method
	assert body == resp.body
}

fn test_patch() {
	body := 'patch'
	method := http.Method.patch
	mut s := testing.new_server(TestHandler{ method: method, body: body })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.patch(context.background(), s.url, bytes.new_buffer(body.bytes())) or { panic(err) }

	assert method == resp.request.method
	assert body == resp.body
}

fn test_head() {
	method := http.Method.head
	mut s := testing.new_server(TestHandler{ method: method })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.head(context.background(), s.url) or { panic(err) }

	assert method == resp.request.method
}

fn test_delete() {
	method := http.Method.delete
	mut s := testing.new_server(TestHandler{ method: method })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.delete(context.background(), s.url) or { panic(err) }

	assert method == resp.request.method
}

fn test_options() {
	method := http.Method.options
	mut s := testing.new_server(TestHandler{ method: method })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new()
	resp := c.options(context.background(), s.url) or { panic(err) }

	assert method == resp.request.method
}

fn test_after_request() {
	mut s := testing.new_server(TestHandler{ method: http.Method.get })
	defer {
		s.close()
	}
	s.start() or { panic(err) }

	c := new(with_after_request(after))
	resp := c.get(context.background(), s.url)!

	assert http.Status.created.int() == resp.status_code
}
