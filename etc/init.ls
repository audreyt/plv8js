module = (pathfilename) ->
  @id = 'module_' + (new Date).getTime!
  @pathfilename = pathfilename
  @exports = {}

require = (modulename) ->
  filename = modulename
  delim = require.path_delim
  c = filename.charAt 0
  filename = './node_modules/' + filename if c isnt '.' and c isnt '/' and (filename.indexOf delim) < 0
  rp = require.resolvePath filename
  if require.loaded[rp] isnt ``undefined`` then return require.loaded[rp].exports else if require.loading[rp] isnt ``undefined`` then return require.loading[rp].exports
  __dirname = void
  __filename = void
  T = void
  stats = native_fs_.statSync rp
  if stats.isDirectory
    packagejson = new Function 'return ' + native_fs_.readFileSync rp + delim + 'package.json'
    throw new Error 'cannot find module of ' + modulename if packagejson.main is ``undefined``
    __dirname = rp
    __filename = packagejson.main
    T = rp + delim + __filename
  else
    if stats.isFile
      T = rp
    else
      if native_fs_.existsSync rp + '.js'
        T = rp + '.js'
      else
        if native_fs_.existsSync rp + '.node'
          T = rp + '.node'
        else
          if typeof @['native_' + modulename + '_'] isnt 'undefined' then return @['native_' + modulename + '_'] else throw new Error 'cannot find module of ' + modulename
  pos = void
  pos = T.lastIndexOf delim
  __dirname = T.substring 0, pos
  __filename = T.substring pos + 1
  suffix = __filename.substring __filename.lastIndexOf '.'
  if suffix is '.js'
    m = new module T
    require.loading[rp] = m
    fn = new Function 'module, exports, __dirname, __filename', native_fs_.readFileSync T
    exports = m.exports
    fn m, exports, __dirname, __filename
    require.loaded[rp] = m
    require.loading[rp] = ``undefined``
    for key of exports
      m.exports[key] = exports[key]
    m.exports
  else
    if suffix is '.node'
      m = new module T
      native_fs_.loadso T, m.exports
      require.loaded[T] = m
      m.exports

require.resolvePath = (filename) ->
  path_delim = require.path_delim
  dirar = void
  if filename.0 is path_delim
    filename
  else
    fnar = filename.split path_delim
    dir = void
    if typeof __dirname is 'undefined' then dir = native_fs_.getcwd! else dir = __dirname
    dirar = dir.split path_delim
    i = 0
    n = fnar.length
    while i < n
      t = fnar[i]
      if t is '.' then continue else if t is '..' then dirar.pop! else dirar.push t
      i++
    dirar.join path_delim

require.path_delim = '/'

require.loading = {}

require.loaded = {}
