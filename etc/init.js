var module, require;
module = function(pathfilename){
  this.id = 'module_' + (new Date).getTime();
  this.pathfilename = pathfilename;
  return this.exports = {};
};
require = function(modulename){
  var filename, delim, c, prefixes, cwd, path_delim, dirar, i$, len$, prefix, rp, stats, fname, packageJson, __dirname, __filename, T, pos, m, body, fn, oldCwd;
  filename = modulename;
  delim = require.path_delim;
  c = filename.charAt(0);
  prefixes = ['/usr/local/plv8/plv8_modules/', '/usr/local/plv8/lib/'];
  if (c == '.' || c == '/') {
    prefixes = [''];
  }
  if (c != '.' && c != '/') {
    cwd = native_fs_.getcwd();
    path_delim = require.path_delim;
    dirar = cwd.split(path_delim);
    do {
      if (native_fs_.statSync(dirar.join(path_delim) + '/package.json').isFile) {
        prefixes.push((dirar.concat(['node_modules', ''])).join(path_delim));
      }
    } while (dirar.pop());
  }
  for (i$ = 0, len$ = prefixes.length; i$ < len$; ++i$) {
    prefix = prefixes[i$];
    rp = require.resolvePath(prefix + "" + filename);
    if (require.loaded[rp] != null) {
      return require.loaded[rp].exports;
    }
    if (require.loading[rp] != null) {
      return require.loading[rp].exports;
    }
    stats = native_fs_.statSync(rp);
    switch (false) {
    case !stats.isDirectory:
      fname = rp + "" + delim + 'package.json';
      packageJson = new Function("return " + native_fs_.readFileSync(fname))();
      if (packageJson.main == null) {
        throw new Error("cannot find module of " + modulename + " (" + fname + " " + packageJson + "})");
      }
      __dirname = rp;
      __filename = packageJson.main;
      T = rp + "/" + delim + __filename;
      if (native_fs_.statSync(T).isDirectory) {
        T += '/index.js';
      } else {
        if (!/\.js$/.test(T)) {
          T += '.js';
        }
      }
      break;
    case !stats.isFile:
      T = rp;
      break;
    case !native_fs_.existsSync(rp + ".js"):
      T = rp + ".js";
      break;
    case !native_fs_.existsSync(rp + ".node"):
      T = rp + ".node";
      break;
    case this["native_" + modulename + "_"] == null:
      return this["native_" + modulename + "_"];
    default:
      continue;
    }
    pos = T.lastIndexOf(delim);
    __dirname = T.substring(0, pos);
    __filename = T.substring(pos + 1);
    switch (__filename.substring(__filename.lastIndexOf('.'))) {
    case '.js':
      m = new module(T);
      require.loading[rp] = m;
      body = native_fs_.readFileSync(T);
      fn = new Function('module', 'exports', '__dirname', '__filename', body);
      oldCwd = native_fs_.getcwd();
      native_fs_.chdir(__dirname);
      m.exports = {};
      fn(m, m.exports, __dirname, __filename);
      require.loaded[rp] = m;
      require.loading[rp] = void 8;
      native_fs_.chdir(oldCwd);
      return m.exports;
    case '.node':
      m = new module(T);
      native_fs_.loadso(T, m.exports);
      require.loaded[T] = m;
      return m.exports;
    default:
      continue;
    }
  }
  throw new Error("cannot find module of " + modulename);
};
require.resolvePath = function(filename){
  var path_delim, dir, dirar, i$, ref$, len$, t;
  path_delim = require.path_delim;
  if (filename[0] === path_delim) {
    return filename;
  }
  dir = typeof __dirname != 'undefined' && __dirname !== null
    ? __dirname
    : native_fs_.getcwd();
  dirar = dir.split(path_delim);
  for (i$ = 0, len$ = (ref$ = filename.split(path_delim)).length; i$ < len$; ++i$) {
    t = ref$[i$];
    switch (t) {
    case '.':
      continue;
    case '..':
      dirar.pop();
      break;
    default:
      dirar.push(t);
    }
  }
  return dirar.join(path_delim);
};
require.path_delim = '/';
require.loading = {};
require.loaded = {};