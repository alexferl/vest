module vest

import context
import io
import json
import net.http
import v.vmod
import bytes

struct Client {
	opts Options
}

// Request represents an HTTP request to be sent by a client.
pub struct Request {
	http.Request
mut:
	ctx context.Context = context.background()
}

// json will attempt to decode the body to json
// with the provided struct.
pub fn (r Response) json<T>() ?T {
	return json.decode(T, r.body)
}

// Response represents the response from an HTTP request.
pub struct Response {
	http.Response
pub mut:
	request Request
}

// new creates a new Client.
pub fn new(opt ...ClientOption) &Client {
	mut opts := Options{}
	for o in opt {
		o.apply(mut opts)
	}

	c := &Client{
		opts: opts
	}

	return c
}

// new_request creates a new Request.
pub fn (c &Client) new_request(ctx context.Context, method http.Method, url string, body io.Reader) ?&Request {
	mut u := url
	if c.opts.base_url != '' {
		u = '$c.opts.base_url$url'
	}

	mut headers := map[string]string{}
	for k, v in c.opts.headers {
		headers[k] = v
	}

	if c.opts.auth != '' {
		headers[http.CommonHeader.authorization.str()] = c.opts.auth
	}

	if c.opts.accept != '' {
		headers[http.CommonHeader.accept.str()] = c.opts.accept
	}

	if method in [http.Method.post, http.Method.put, http.Method.patch] {
		if c.opts.content_type != '' {
			headers[http.CommonHeader.content_type.str()] = c.opts.content_type
		}
	}

	mut cookies := map[string]string{}
	for k, v in c.opts.cookies {
		cookies[k] = v
	}

	data := io.read_all(reader: body)?

	return &Request{
		version: c.opts.version
		method: method
		header: http.new_custom_header_from_map(headers)?
		cookies: cookies
		data: data.bytestr()
		url: u
		user_agent: get_user_agent()
		read_timeout: c.opts.read_timeout
		write_timeout: c.opts.write_timeout
		verify: c.opts.root_ca
		cert: c.opts.cert
		cert_key: c.opts.cert_key
		allow_redirect: c.opts.allow_redirect
		ctx: ctx
	}
}

// do sends a Request and returns a Response.
pub fn (c &Client) do(mut req Request) ?&Response {
	unsafe {
		if c.opts.before_request != nil {
			c.opts.before_request(mut req)?
		}
	}
	resp_ch := chan http.Response{}
	err_ch := chan IError{}
	go fn (resp_ch chan http.Response, err_ch chan IError, mut req Request) ? {
		resp := req.do() or {
			err_ch <- err
			return
		}

		resp_ch <- resp
	}(resp_ch, err_ch, mut req)

	ctx_ch := req.ctx.done()
	select {
		_ := <-ctx_ch {
			return req.ctx.err()
		}
		resp := <-resp_ch {
			return &Response{resp, req}
		}
		err := <-err_ch {
			return err
		}
	}

	return none
}

// get sends a GET request and returns a Response.
pub fn (c &Client) get(ctx context.Context, url string) ?&Response {
	mut req := c.new_request(ctx, http.Method.get, url, bytes.new_buffer([]u8{}))?
	return c.do(mut req)
}

// post sends a POST request and returns a Response.
pub fn (c &Client) post(ctx context.Context, url string, body io.Reader) ?&Response {
	mut req := c.new_request(ctx, http.Method.post, url, body)?
	return c.do(mut req)
}

// put sends a PUT request and returns a Response.
pub fn (c &Client) put(ctx context.Context, url string, body io.Reader) ?&Response {
	mut req := c.new_request(ctx, http.Method.put, url, body)?
	return c.do(mut req)
}

// head sends a HEAD request and returns a Response.
pub fn (c &Client) head(ctx context.Context, url string) ?&Response {
	mut req := c.new_request(ctx, http.Method.head, url, bytes.new_buffer([]u8{}))?
	return c.do(mut req)
}

// delete sends a DELETE request and returns a Response.
pub fn (c &Client) delete(ctx context.Context, url string) ?&Response {
	mut req := c.new_request(ctx, http.Method.delete, url, bytes.new_buffer([]u8{}))?
	return c.do(mut req)
}

// options sends a OPTIONS request and returns a Response.
pub fn (c &Client) options(ctx context.Context, url string) ?&Response {
	mut req := c.new_request(ctx, http.Method.options, url, bytes.new_buffer([]u8{}))?
	return c.do(mut req)
}

// patch sends a PATCH request and returns a Response.
pub fn (c &Client) patch(ctx context.Context, url string, body io.Reader) ?&Response {
	mut req := c.new_request(ctx, http.Method.patch, url, body)?
	return c.do(mut req)
}

fn get_user_agent() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return '$vm.name/$vm.version'
}
