var module, require;
module = function(pathfilename){
  this.id = 'module_' + (new Date).getTime();
  this.pathfilename = pathfilename;
  return this.exports = {};
};
require = function(modulename){
  var filename, delim, c, rp, __dirname, __filename, T, stats, fname, packagejson, pos, suffix, m, body, fn;
  filename = modulename;
  delim = require.path_delim;
  c = filename.charAt(0);
  if (c !== '.' && c !== '/' && filename.indexOf(delim) < 0) {
    filename = '/usr/local/plv8/plv8_modules/' + filename;
  }
  rp = require.resolvePath(filename);
  if (require.loaded[rp] !== undefined) {
    return require.loaded[rp].exports;
  } else if (require.loading[rp] !== undefined) {
    return require.loading[rp].exports;
  }
  __dirname = void 8;
  __filename = void 8;
  T = void 8;
  stats = native_fs_.statSync(rp);
  if (stats.isDirectory) {
    fname = rp + delim + 'package.json';
    packagejson = new Function('return ' + native_fs_.readFileSync(fname))();
    if (packagejson.main === undefined) {
      throw new Error("cannot find module of " + modulename + " (" + fname + " " + packagejson + "})");
    }
    __dirname = rp;
    __filename = packagejson.main;
    T = rp + delim + __filename;
    if (!/\.js$/.test(T)) {
      T += '.js';
    }
  } else {
    if (stats.isFile) {
      T = rp;
    } else {
      if (native_fs_.existsSync(rp + '.js')) {
        T = rp + '.js';
      } else {
        if (native_fs_.existsSync(rp + '.node')) {
          T = rp + '.node';
        } else {
          if (typeof this['native_' + modulename + '_'] !== 'undefined') {
            return this['native_' + modulename + '_'];
          } else {
            throw new Error('cannot find module of ' + modulename);
          }
        }
      }
    }
  }
  pos = void 8;
  pos = T.lastIndexOf(delim);
  __dirname = T.substring(0, pos);
  __filename = T.substring(pos + 1);
  suffix = __filename.substring(__filename.lastIndexOf('.'));
  if (suffix === '.js') {
    m = new module(T);
    require.loading[rp] = m;
    body = native_fs_.readFileSync(T);
    fn = new Function("module", "exports", "__dirname", "__filename", body);
    native_fs_.chdir(__dirname);
    m.exports = {};
    fn(m, m.exports, __dirname, __filename);
    require.loaded[rp] = m;
    require.loading[rp] = undefined;
    return m.exports;
  } else {
    if (suffix === '.node') {
      m = new module(T);
      native_fs_.loadso(T, m.exports);
      require.loaded[T] = m;
      return m.exports;
    }
  }
};
require.resolvePath = function(filename){
  var path_delim, dir, dirar, i$, ref$, len$, t;
  path_delim = require.path_delim;
  if (filename[0] === path_delim) {
    return filename;
  } else {
    dir = typeof __dirname === 'undefined' ? native_fs_.getcwd() : __dirname;
    dirar = dir.split(path_delim);
    for (i$ = 0, len$ = (ref$ = filename.split(path_delim)).length; i$ < len$; ++i$) {
      t = ref$[i$];
      if (t === '.') {
        continue;
      } else if (t === '..') {
        dirar.pop();
      } else {
        dirar.push(t);
      }
    }
    return dirar.join(path_delim);
  }
};
require.path_delim = '/';
require.loading = {};
require.loaded = {};