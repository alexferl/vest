module bytes

import io

pub struct Buffer {
mut:
	buf []u8
	i   int
}

// bytes returns a slice of length b.len() holding
// the unread portion of the buffer.
pub fn (b Buffer) bytes() []u8 {
	return b.buf[b.i..]
}

// string returns the contents of the unread portion of the
// buffer as a string.
pub fn (b Buffer) string() string {
	return b.buf.str()
}

// len returns the number of bytes of the unread portion of the buffer;
// b.len() == b.bytes().len.
pub fn (b Buffer) len() int {
	return b.buf.len - b.i
}

// cap returns the capacity of the buffer's underlying byte slice.
pub fn (b Buffer) cap() int {
	return b.buf.cap
}

// truncate discards all but the first n unread bytes from the buffer
// but continues to use the same allocated storage.
// It panics if n is negative or greater than the length of the buffer.
pub fn (mut b Buffer) truncate(n int) {
	if n == 0 {
		b.reset()
		return
	}
	if n < 0 || n > b.len() {
		panic('truncation out of range')
	}
	b.buf = b.buf[..b.i + n]
}

// reset resets the buffer to be empty,
// but it retains the underlying storage for use by future writes.
// reset is the same as truncate(0).
fn (mut b Buffer) reset() {
	b.buf = b.buf[..0]
	b.i = 0
}

// read reads the next p.len bytes from the buffer or until the buffer
// is drained. The return value is the number of bytes read. If the
// buffer has no data to return, io.Eof is returned.
pub fn (mut b Buffer) read(mut p []u8) !int {
	if !(b.i < b.buf.len) {
		return IError(io.Eof{})
	}
	n := copy(mut p, b.buf[b.i..])
	b.i += n
	return n
}

pub fn (mut b Buffer) next(n int) []u8 {
	mut mn := n
	m := b.len()
	if mn > m {
		mn = m
	}
	data := b.buf[b.i..b.i + n]
	b.i += n
	return data
}

// new_buffer creates and initializes a new Buffer using buf as its
// initial contents.
pub fn new_buffer(b []u8) &Buffer {
	return &Buffer{
		buf: b
	}
}
