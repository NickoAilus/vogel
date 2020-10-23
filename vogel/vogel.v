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
	server = "VOGEL 0. 0. 1"
)

// Route
// -=-=-
// You can attach a URL to your function using route.

pub struct Route { function fn()Response }

// App
// -=-
// Most important thing of this framework.

pub struct App {
	mut: functions map[string]Route
	routes map[string]bool
	port int
}

pub fn (mut a App) route(r string, f fn()Response) {
	a.functions[r] = Route{f}
	a.routes[r] = true
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
	mut out := ""
	mut buffer := ""
	for {
		buffer = r.socket.read_line()
		if buffer == "\r\n" { break } else { out += buffer }
	}
	return out
}

fn (a &App) handle(r Request) {
	println("📩 Got a request, ${time.now().utc_string()}")
	mut url := r.socket.read_line()
	url = url[5..url.len - 11]
	url_splitted := url.split('/')
	// println("$r")

	mut response := Response{}
	if a.routes[url_splitted[0]] {
		response = a.functions[url_splitted[0]].function()
	} else {
		response = default(404)
	}

	r.socket.send_string("$response")

	println("📨 Sent a response, ${time.now().utc_string()}")
	// println("$response")

	r.socket.close() // or {}
}

// -=-=-=-=-
// Response
// -=-=-=-=-
// Browser sends a request to server, server sends a response to browser. Sounds simple enough, isn't it?Header{""}

struct Response {
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
		200,
		[
			Header{"Connection", "close"},
			Header{"Content-Type", "application/json; charset=utf-8"}
		],
		j
	}
}

// -=-=-=-
// Header
// -=-=-=-
// Requests and responses contain headers.

struct Header {
	header string
	content string
}

pub fn (h Header) str() string { return "$h.header: $h.content\r\n" }
