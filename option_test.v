module vest

import net.http
import time

fn test_with_base_url() {
	s := 'https://example.com'
	mut opts := Options{}
	with_base_url(s).apply(mut opts)

	assert s == opts.base_url
}

fn test_with_accept() {
	s := 'application/xml'
	mut opts := Options{}
	with_accept(s).apply(mut opts)

	assert s == opts.accept
}

fn test_with_content_type() {
	s := 'application/xml'
	mut opts := Options{}
	with_content_type(s).apply(mut opts)

	assert s == opts.content_type
}

fn before_test(mut req Request) ? {}

fn test_with_before_request() {
	mut opts := Options{}
	with_before_request(before_test).apply(mut opts)

	assert before_test == opts.before_request
}

fn after_test(mut resp Response) ? {}

fn test_with_after_request() {
	mut opts := Options{}
	with_after_request(after_test).apply(mut opts)

	assert after_test == opts.after_request
}

fn test_with_auth() {
	s := 'Bearer token'
	mut opts := Options{}
	with_auth(s).apply(mut opts)

	assert s == opts.auth
}

fn test_with_version() {
	v := http.Version.v2_0
	mut opts := Options{}
	with_version(v).apply(mut opts)

	assert v == opts.version
}

fn test_with_headers() {
	m := {
		'X-Test': 'test'
	}
	mut opts := Options{}
	with_headers(m).apply(mut opts)

	assert m == opts.headers
}

fn test_with_cookies() {
	m := {
		'key': 'val'
	}
	mut opts := Options{}
	with_cookies(m).apply(mut opts)

	assert m == opts.cookies
}

fn test_with_read_timeout() {
	d := 42 * time.second
	mut opts := Options{}
	with_read_timeout(d).apply(mut opts)

	assert d == opts.read_timeout
}

fn test_with_write_timeout() {
	d := 42 * time.second
	mut opts := Options{}
	with_write_timeout(d).apply(mut opts)

	assert d == opts.write_timeout
}

fn test_with_validate() {
	b := false
	mut opts := Options{}
	with_validate(b).apply(mut opts)

	assert b == opts.validate
}

fn test_with_root_ca() {
	s := 'root'
	mut opts := Options{}
	with_root_ca(s).apply(mut opts)

	assert s == opts.root_ca
}

fn test_with_cert() {
	s := 'cert'
	mut opts := Options{}
	with_cert(s).apply(mut opts)

	assert s == opts.cert
}

fn test_with_cert_key() {
	s := 'cert.key'
	mut opts := Options{}
	with_cert_key(s).apply(mut opts)

	assert s == opts.cert_key
}

fn test_with_allow_redirect() {
	b := false
	mut opts := Options{}
	with_allow_redirect(b).apply(mut opts)

	assert b == opts.allow_redirect
}
