var util = require('util');

exports.log = function() {
  plv8.elog(INFO, util.format.apply(this, arguments));
};

exports.info = exports.log;

exports.warn = function () {
  plv8.elog(WARNING, util.format.apply(this, arguments));
};

exports.error = function () {
  plv8.elog(ERROR, util.format.apply(this.arguments));
};

exports.dir = function (obj) {
  plv8.elog(INFO, util.inspect(obj));
};
