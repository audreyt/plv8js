

function require(file) {
  // extremely naive handling of pathing
  var paths = [ "/usr/local/plv8/lib/", "/usr/local/plv8/plv8_modules/" ];
  
  var exports = { };
  for (var i = 0; i < paths.length; i++) {
    var script = plv8._require(paths[i] + file);
    if (script) {
      eval(script);
      return exports;
    }
  }
  throw Error("Cannot to find module '" + file+ "'");
}

var console = {
  log: function () {
    var args = Array.prototype.slice.call(arguments, 0);
    args.unshift(INFO);
    plv8.elog.apply(undefined, args);
  },
  dir: function () {
    var util = require('util.js');
    console.log(util);
    for (var i in util) {
      console.log(i + " => " + util[i]);
    }
    var args = Array.prototype.slice.call(arguments, 0);
    for (var i = 0; i < args.length; i++) {
      console.log(util.inspect(args[i], 10));
    }
  },
  error: function () {
    var args = Array.prototype.slice.call(arguments, 0);
    args.unshift(ERROR);
    plv8.elog.apply(undefined, args);
  }
};
