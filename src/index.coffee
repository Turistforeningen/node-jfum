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

  cnt = 0
  done = (err) -> next(err) if ++cnt is 1

  new Form()

  .on 'error', (err) ->
    req.jfum.error = err.message
    done()

  .on 'close', done

  .on 'part', (part) =>
    req.jfum.files.push
      name: part.filename
      #size: part.byteCount
      mime: part.headers['content-type']

    file = req.jfum.files[req.jfum.files.length - 1]

    if not part.filename or not @acceptFileTypes.test part.filename
      file.error =
        code: 'JFUM-001'
        msg: 'File type not allowed'
      return part.pipe createWriteStream('/dev/null').on 'error', done

    #if @maxFileSize < part.byteCount
    #  req.jfum.files.push error: code: 'JFUM-002', msg: 'File size too big'
    #  return part.pipe createWriteStream('/dev/null').on 'error', done

    #if @minFileSize > part.byteCount
    #  req.jfum.files.push error: code: 'JFUM-003', msg: 'File size too small'
    #  return part.pipe createWriteStream('/dev/null').on 'error', done

    file.path = @tmpDir + '/jfum-' + hash('sha1').update(rand(128)).digest('hex')

    part.pipe createWriteStream(file.path).on 'error', done

  .parse req

