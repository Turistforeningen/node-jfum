Form = require('multiparty').Form

JFUM = module.exports = (opts) ->
  opts ?= {}

  @multiparty  = opts.multiparty
  @minFileSize = opts.minFileSize or 204800
  @maxFileSize = opts.maxFileSize or 5242880
  @acceptFileTypes = opts.acceptFileTypes or /\.(gif|jpe?g|png)$/i

  @

JFUM.prototype.optionsHandler = (req, res, next) ->
  res.set
    'Access-Control-Allow-Methods': 'OPTIONS, POST'
    'Access-Control-Allow-Headers': 'Content-Type'
  next()

JFUM.prototype.postHandler = (req, res, next) ->
  req.jfum = files: []

  new Form()

  .on 'error', (err) ->
    req.jfum.error = err.message
    next()

  .on 'close', next

  .on 'file', (field, file) =>
    file =
      field: field
      name: file.originalFilename
      path: file.path
      size: file.size
      mime: file.headers['content-type']
      errors: []

    if not file.name or not @acceptFileTypes.test file.name
      file.errors.push code: 'JFUM-001', message: 'File type not allowed'

    if @maxFileSize < file.size
      file.errors.push code: 'JFUM-002', message: 'File size too big'

    if @minFileSize > file.size
      file.errors.push code: 'JFUM-003', message: 'File size too small'

    if file.errors.length isnt 0
      delete file.path

    req.jfum.files.push file

  .parse req

