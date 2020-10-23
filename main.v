import vogel

fn test() vogel.Response {
	return vogel.default(418)
}

fn test2() vogel.Response {
	return vogel.json(500, '{"hooh":"sheesh"}')
}

fn main() {
	mut a := vogel.App{port: 8080}
	a.route("kek", test)
	a.route("kek2", test2)
	a.run()
}
