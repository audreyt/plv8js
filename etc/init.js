var module, require;
module = function(pathfilename){
  this.id = 'module_' + (new Date).getTime();
  this.pathfilename = pathfilename;
  return this.exports = {};
};
require = function(modulename){
  var filename, delim, c, rp, __dirname, __filename, T, stats, packagejson, pos, suffix, m, fn, exports, key;
  filename = modulename;
  delim = require.path_delim;
  c = filename.charAt(0);
  if (c !== '.' && c !== '/' && filename.indexOf(delim) < 0) {
    filename = './node_modules/' + filename;
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
    packagejson = new Function('return ' + native_fs_.readFileSync(rp + delim + 'package.json'));
    if (packagejson.main === undefined) {
      throw new Error('cannot find module of ' + modulename);
    }
    __dirname = rp;
    __filename = packagejson.main;
    T = rp + delim + __filename;
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
    fn = new Function('module, exports, __dirname, __filename', native_fs_.readFileSync(T));
    exports = m.exports;
    fn(m, exports, __dirname, __filename);
    require.loaded[rp] = m;
    require.loading[rp] = undefined;
    for (key in exports) {
      m.exports[key] = exports[key];
    }
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
  var path_delim, dirar, fnar, dir, i, n, t;
  path_delim = require.path_delim;
  dirar = void 8;
  if (filename[0] === path_delim) {
    return filename;
  } else {
    fnar = filename.split(path_delim);
    dir = void 8;
    if (typeof __dirname === 'undefined') {
      dir = native_fs_.getcwd();
    } else {
      dir = __dirname;
    }
    dirar = dir.split(path_delim);
    i = 0;
    n = fnar.length;
    while (i < n) {
      t = fnar[i];
      if (t === '.') {
        continue;
      } else if (t === '..') {
        dirar.pop();
      } else {
        dirar.push(t);
      }
      i++;
    }
    return dirar.join(path_delim);
  }
};
require.path_delim = '/';
require.loading = {};
require.loaded = {};