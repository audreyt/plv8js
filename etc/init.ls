module = (pathfilename) ->
  @id = 'module_' + (new Date).getTime!
  @pathfilename = pathfilename
  @exports = {}

require = (modulename) ->
  filename = modulename
  delim = require.path_delim
  c = filename.charAt 0
  prefixes = <[ /usr/local/plv8/plv8_modules/ /usr/local/plv8/lib/ ]>
  prefixes = [''] if c in <[ . / ]> or ~filename.indexOf(delim)
  for prefix in prefixes
    rp = require.resolvePath "#prefix#filename"
    return require.loaded[rp].exports if require.loaded[rp]?
    return require.loading[rp].exports if require.loading[rp]?
    stats = native_fs_.statSync rp
    switch
    | stats.is-directory
      fname = "#rp#delim#{\package.json}"
      package-json = (new Function "return #{ native_fs_.readFileSync fname }")!
      unless package-json.main?
          throw new Error "cannot find module of #modulename (#fname #package-json})"
      __dirname = rp
      __filename = package-json.main
      T = "#rp/#delim#__filename"
      T += '.js' if T isnt /\.js$/
    | stats.isFile
      T = rp
    | native_fs_.existsSync "#rp.js"
      T = "#rp.js"
    | native_fs_.existsSync "#rp.node"
      T = "#rp.node"
    | @["native_#{modulename}_"]?
        return @["native_#{modulename}_"]
    | _  => continue
    pos = T.lastIndexOf delim
    __dirname = T.substring 0, pos
    __filename = T.substring pos + 1
    switch __filename.substring __filename.lastIndexOf '.'
    | \.js
      m = new module T
      require.loading[rp] = m
      body = native_fs_.readFileSync T
      fn = new Function \module \exports \__dirname \__filename body
      # XXX: shouldn't really chdir, but just calculate logic cwd for require caller
      native_fs_.chdir __dirname
      m.exports = {}
      fn m, m.exports, __dirname, __filename
      require.loaded[rp] = m
      require.loading[rp] = void
      return m.exports
    | \.node
      m = new module T
      native_fs_.loadso T, m.exports
      require.loaded[T] = m
      return m.exports
    | _ => continue # TODO: Load .ls automatically?
  throw new Error "cannot find module of #modulename"

require.resolvePath = (filename) ->
  path_delim = require.path_delim
  return filename if filename.0 is path_delim
  dir = __dirname ? native_fs_.getcwd!
  dirar = dir.split path_delim
  for t in filename.split path_delim
    switch t
    | \.  => continue
    | \.. => dirar.pop!
    | _   => dirar.push t
  dirar.join path_delim

require.path_delim = '/'
require.loading = {}
require.loaded = {}
