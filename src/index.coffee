Form = require('multiparty').Form
createWriteStream = require('fs').createWriteStream
hash = require('crypto').createHash
rand = require('crypto').pseudoRandomBytes

JFUM = module.exports = (opts) ->
  opts ?= {}

  @tmpDir = opts.tmpDir or require('os').tmpdir()
  @minFileSize = opts.minFileSize or 1
  @maxFileSize = opts.maxFileSize or 10000000000
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
      name: part.filename
      file: @tmpDir + '/jfum-' + hash('sha1').update(rand(128)).digest('hex')
      size: part.byteCount
      type: part.headers['content-type']

    part.pipe createWriteStream(req.jfum.files[i-1].file).on 'error', next

  form.parse req

