
function _require (file) {
  // extremely naive handling of pathing
  var paths = [ "/usr/local/plv8/lib/", "/usr/local/plv8/plv8_modules/" ];

  if (file.match(".+js$") === null) {
    file += ".js";
  }

  var exports = { };
  for (var i = 0; i < paths.length; i++) {
    var script = plv8._read_file(paths[i] + file);
    if (script) {
      eval(script);
      return exports;
    }
  }
  throw Error("Cannot to find module '" + file + "'");
}

var require = _require;