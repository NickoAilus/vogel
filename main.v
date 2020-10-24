import vogel as v
import net.http
import rand

fn index() v.Response { return v.text(200, "Everything works correctly.") }

fn im_a_teapot() v.Response { return v.default(418) }
fn json_example() v.Response { return v.json(200, '{"text":"JSON example", "random_number":${rand.int()}}') }
fn plain_text() v.Response { return v.text(200, "Plain text example.") }

fn custom() v.Response {
	return v.Response{
		http.Status.ok,
		[
			v.Header{"Content-Type", "text/plain; charset=utf-8"}
		],
		"This is a custom response. You can add custom headers, change status code and data."
	}
}

fn main() {
	mut a := v.App{port: 8080}

	a.set_routes([
		v.Route{"/", index},
		v.Route{"/teapot", im_a_teapot},
		v.Route{"/examples/json", json_example},
		v.Route{"/examples/txt", plain_text},
		v.Route{"/custom", custom}
	])

	a.run()
}
