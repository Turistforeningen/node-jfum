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
    'Access-Control-Allow-Origin': '*'
    'Access-Control-Allow-Methods': 'OPTIONS, POST'
    'Access-Control-Allow-Headers': 'Content-Type'
  next()

JFUM.prototype.postHandler = (req, res, next) ->
  res.set 'Access-Control-Allow-Origin', '*'

  form = new Form()
  form.on 'error', next
  form.on 'close', next
  form.on 'part', (part) =>
    if not part.filename or not @acceptFileTypes.test part.filename
      req.jfum = error: code: 'JFUM-001', msg: 'File type not allowed'
      return part.pipe createWriteStream '/dev/null'

    if not @maxFileSize <= part.byteCount <= @minFileSize
      req.jfum = error: code: 'JFUM-002', msg: 'File size not allowed'
      return part.pipe createWriteStream '/dev/null'

    req.jfum =
      name: part.filename
      file: @tmpDir + '/jfum-' + hash('sha1').update(rand(128)).digest('hex')
      size: part.byteCount
      type: part.headers['content-type']

    write = createWriteStream req.jfum.file
    write.on 'error', next
    part.pipe write

  form.parse req

