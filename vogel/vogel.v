module vogel

import net
import net.http
import time
//import json
//import arrays
//import net.urllib
//import strings

// Default variables
// -=-=-=-=-=-=-=-=-
// can't touch this! tuuu tu tu tu, tu tu, tu tu. can't touch this - tuuu tu tu tu

pub const (
	server = "VOGEL 0. 0. 2"
)

// Route
// -=-=-
// You can attach a URL to your function using route.

pub struct Route {
	name string
	function fn()Response
}

// App
// -=-
// Most important thing of this framework.

pub struct App {
	mut: routes map[string]Route
	port int
}

pub fn (mut a App) set_routes(r []Route) {
	for route in r {
		a.routes[route.name] = route
	}
}

pub fn (mut a App) run() {
	println(server)

	println("🕑 Starting server on localhost:${a.port}...")
	listener := net.listen(a.port) or { panic("—— ❌ Can't listen the port.") }
	println("✅ Server started successfully.\n")

	for {
		r_buffer := listener.accept() or { panic("❌ Can't accept the connection.") }
		r := Request{r_buffer}
		a.handle(r)
	}
}

// Request
// -=-=-=-
// Browser sends a request to server, server sends a response to browser. Simple, isn't it?

struct Request { socket net.Socket }

pub fn (r Request) str() string {
	r_clone := r
	mut out := ""
	mut buffer := ""
	for {
		buffer = r_clone.socket.read_line()
		if buffer == "\r\n" { break } else { out += buffer }
	}
	return out
}

fn (a &App) handle(r Request) {
	println("📩 Got a request, ${time.now().utc_string()}")
	//println("$r")

	// TODO: improve routing mechanism

	input_url := r.socket.read_line()
	url := input_url[4..input_url.len - 11]
	//println("$url")

	mut response := Response{}
	if a.routes[url].name != "" {
		response = a.routes[url].function()
	} else {
		response = default(404)
	}

	r.socket.send_string("$response")

	println("📨 Sent a response, ${time.now().utc_string()}")
	println("$response")

	r.socket.close() // or {}
}

// Response
// -=-=-=-=-
// Browser sends a request to server, server sends a response to browser. Sounds simple enough, isn't it?

pub struct Response {
	status http.Status
	headers []Header
	data string
}

pub fn (r Response) str() string {
	mut out := "HTTP/1.1 ${r.status.int()} $r.status\r\n"
	out += "Server: $server\r\n"
	for h in r.headers {
		out += "$h"
	}
	out += "\r\n"
	out += r.data
	return out
}

pub fn default(status http.Status) Response {
	return Response{
		status,
		[
			Header{"Connection", "close"},
			Header{"Content-Type", "text/html; charset=utf-8"}
		]
		'<html><body><p><b>Code ${status.int()}</b></p><p>$status</p><hr/><i>$server</i></body></html>'
	}
}

pub fn json(status http.Status, j string) Response {
	return Response{
		status,
		[
			Header{"Connection", "close"},
			Header{"Content-Type", "application/json; charset=utf-8"}
		],
		j
	}
}

pub fn text(status http.Status, t string) Response {
	return Response{
		status,
		[
			Header{"Connection", "close"},
			Header{"Content-Type", "text/plain; charset=utf-8"}
		],
		t
	}
}

// Header
// -=-=-=-
// Requests and responses contain headers.

pub struct Header {
	header string
	content string
}

pub fn (h Header) str() string { return "$h.header: $h.content\r\n" }
