all ::
	lsc -bco lib src

run :: all
	PATH=node_modules/.bin:$(PATH) nodemon lib/server.js -w lib
