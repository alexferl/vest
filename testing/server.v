module httptest

import io
import net
import net.http
import time

pub enum State {
	running = 0
	stopped
	closed
}

pub struct Server {
mut:
	listener &net.TcpListener = unsafe { nil }
pub:
	family net.AddrFamily = .ip
pub mut:
	url            string
	state          State
	handler        http.Handler  = DebugHandler{}
	read_timeout   time.Duration = 30 * time.second
	write_timeout  time.Duration = 30 * time.second
	accept_timeout time.Duration = 30 * time.second
}

pub fn new_server(handler http.Handler) &Server {
	return &Server{
		handler: handler
		listener: 0
		state: .closed
	}
}

pub fn (mut s Server) start() ? {
	s.listener = net.listen_tcp(s.family, 'localhost:0')?
	laddr := s.listener.addr()?
	s.url = 'http://$laddr'
	s.listener.set_accept_timeout(s.accept_timeout)
	s.set_state(.running)

	go s.handle()
}

fn (mut s Server) handle() {
	for s.state == .running {
		mut conn := s.listener.accept() or {
			if s.state != .running {
				break
			}
			if !err.msg().contains('net: op timed out') {
				eprintln('accept() failed: $err; skipping')
			}
			continue
		}

		conn.set_read_timeout(s.read_timeout)
		conn.set_write_timeout(s.write_timeout)
		s.parse_and_respond(mut conn)
	}
	if s.state == .stopped {
		s.close()
	}
}

// stop signals the server that it should not respond anymore
pub fn (mut s Server) stop() {
	s.set_state(.stopped)
}

// close immediatly closes the port and signals the server that it has been closed
pub fn (mut s Server) close() {
	s.set_state(.closed)
	s.listener.close() or { panic(err) }
}

pub fn (s &Server) status() State {
	return s.state
}

fn (mut s Server) parse_and_respond(mut conn net.TcpConn) {
	defer {
		conn.close() or { eprintln('close() failed: $err') }
	}

	mut reader := io.new_buffered_reader(reader: conn)
	defer {
		unsafe {
			reader.free()
		}
	}
	req := http.parse_request(mut reader) or {
		$if debug {
			// only show in debug mode to prevent abuse
			eprintln('error parsing request: $err')
		}
		return
	}
	mut resp := s.handler.handle(req)
	if resp.version() == .unknown {
		resp.set_version(req.version)
	}
	conn.write(resp.bytes()) or { eprintln('error sending response: $err') }
}

// set_state sets current state in a thread safe way
fn (mut s Server) set_state(state State) {
	lock  {
		s.state = state
	}
}

// DebugHandler implements the Handler interface by echoing the request
// in the response.
pub struct DebugHandler {}

fn (d DebugHandler) handle(req http.Request) http.Response {
	$if debug {
		eprintln('[$time.now()] $req.method $req.url\n\r$req.header\n\r$req.data - 200 OK')
	} $else {
		eprintln('[$time.now()] $req.method $req.url - 200')
	}
	mut r := http.Response{
		body: req.data
		header: req.header
	}
	r.set_status(.ok)
	r.set_version(req.version)
	return r
}
