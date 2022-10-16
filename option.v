module vest

import net.http
import time

type BeforeFn = fn (mut Request) ?

struct Options {
mut:
	base_url       string
	accept         string = 'application/json, */*;q=0.5'
	content_type   string = 'application/json'
	auth           string
	before_request BeforeFn = unsafe { nil }

	version        http.Version = http.Version.v1_1
	headers        map[string]string
	cookies        map[string]string
	read_timeout   time.Duration = 30 * time.second
	write_timeout  time.Duration = 30 * time.second
	validate       bool = true
	root_ca        string
	cert           string
	cert_key       string
	allow_redirect bool = true
}

interface ClientOption {
	apply(mut Options)
}

// FnOption wraps a function that modifies Options into an
// implementation of the ClientOption interface.
struct FnOption {
	f fn (mut Options)
}

fn (o FnOption) apply(mut do Options) {
	o.f(mut do)
}

fn new_fn_option(f fn (mut Options)) FnOption {
	return FnOption{
		f: f
	}
}

// with_base_url sets a base_url all requests will be prefixed with.
pub fn with_base_url(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.base_url = s
	})
}

// with_accept sets an Accept header that
// will be sent with all requests.
// Defaults to application/json, */*;q=0.5.
pub fn with_accept(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.accept = s
	})
}

// with_content_type sets a Content-Type header that
// will be sent with all POST, PUT and PATCH requests.
// Defaults to application/json.
pub fn with_content_type(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.content_type = s
	})
}

// with_auth sets a Authorization header that
// will be sent with all requests.
pub fn with_auth(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.auth = s
	})
}

// with_before_request sets a function that will be run
// after the request is built, but before it's sent.
pub fn with_before_request(f fn (mut req Request) ?) ClientOption {
	return new_fn_option(fn [f] (mut o Options) {
		o.before_request = f
	})
}

// with_version sets the HTTP version for all requests.
// Defaults to HTTP/1.1.
pub fn with_version(v http.Version) ClientOption {
	return new_fn_option(fn [v] (mut o Options) {
		o.version = v
	})
}

// with_headers sets headers that will be sent with all requests.
pub fn with_headers(m map[string]string) ClientOption {
	return new_fn_option(fn [m] (mut o Options) {
		o.headers = &m
	})
}

// with_cookies sets cookies that will be sent with all requests.
pub fn with_cookies(m map[string]string) ClientOption {
	return new_fn_option(fn [m] (mut o Options) {
		o.cookies = &m
	})
}

// with_read_timeout sets the read timeout for all requests.
pub fn with_read_timeout(d time.Duration) ClientOption {
	return new_fn_option(fn [d] (mut o Options) {
		o.read_timeout = d
	})
}

// with_write_timeout sets the write timeout for all requests.
pub fn with_write_timeout(d time.Duration) ClientOption {
	return new_fn_option(fn [d] (mut o Options) {
		o.write_timeout = d
	})
}

// with_validate controls if TLS certificates will be
// validated or not. Set to false for self-signed certificates.
// Defaults to true.
pub fn with_validate(b bool) ClientOption {
	return new_fn_option(fn [b] (mut o Options) {
		o.validate = b
	})
}

// with_root_ca sets the root CA for all requests.
pub fn with_root_ca(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.root_ca = s
	})
}

// with_cert sets the certificate for all requests.
pub fn with_cert(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.cert = s
	})
}

// with_cert_key sets the certificate private key
// for all requests.
pub fn with_cert_key(s string) ClientOption {
	return new_fn_option(fn [s] (mut o Options) {
		o.cert_key = s
	})
}

// with_allow_redirect controls if requests will
// follow redirects or not.
// Defaults to true.
pub fn with_allow_redirect(b bool) ClientOption {
	return new_fn_option(fn [b] (mut o Options) {
		o.allow_redirect = b
	})
}
