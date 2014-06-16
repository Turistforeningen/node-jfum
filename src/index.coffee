Form = require('multiparty').Form
createWriteStream = require('fs').createWriteStream
hash = require('crypto').createHash
rand = require('crypto').pseudoRandomBytes

JFUM = module.exports = (opts) ->
  opts ?= {}

  @tmpDir = opts.tmpDir or require('os').tmpdir()
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

  form = new Form()
  form.on 'error', next
  form.on 'close', next
  form.on 'part', (part) =>
    if not part.filename or not @acceptFileTypes.test part.filename
      req.jfum.files.push error: code: 'JFUM-001', msg: 'File type not allowed'
      return part.pipe createWriteStream('/dev/null').on 'error', next

    if @maxFileSize < part.byteCount
      req.jfum.files.push error: code: 'JFUM-002', msg: 'File size too big'
      return part.pipe createWriteStream('/dev/null').on 'error', next

    if @minFileSize > part.byteCount
      req.jfum.files.push error: code: 'JFUM-003', msg: 'File size too small'
      return part.pipe createWriteStream('/dev/null').on 'error', next

    i = req.jfum.files.push
      path: @tmpDir + '/jfum-' + hash('sha1').update(rand(128)).digest('hex')
      name: part.filename
      size: part.byteCount
      mime: part.headers['content-type']

    part.pipe createWriteStream(req.jfum.files[i-1].path).on 'error', next

  form.parse req

