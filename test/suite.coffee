assert = require 'assert'
http = require 'http'

express = require 'express'

JFUM = require '../src'
post = require './util/post'

jfum = app = null

beforeEach (done) ->
  jfum = new JFUM
    minFileSize: 1
    maxFileSize: 5242880
    acceptFileTypes: /\.(gif|jpe?g|png)$/i

  app = express()
  app.server = app.listen done

afterEach (done) ->
  app.server.close
  setTimeout done, 100

describe 'JFUM', ->
  files = null
  beforeEach ->
    files = [{
      name: 'foo.jpg'
      mime: 'image/jpeg'
      size: 1024
    },{
      name: 'bar.gif'
      mime: 'image/gif'
      size: 2048
    }]

  it 'should handle single file', (done) ->
    app.post '/upload1', jfum.postHandler.bind(jfum), (req, res, next) ->
      assert.equal req.jfum.error, undefined
      assert.equal req.jfum.files.length, 1
      for file, i in req.jfum.files
        assert.deepEqual Object.keys(file), ['name', 'mime', 'path']
        assert.equal typeof file.path, 'string'
        assert.equal file.name, files[i].name
        assert.equal file.mime, files[i].mime
      res.end()
      done()

    [opts, body] = post app, '/upload1', [files[0]]

    http.request(opts).on('error', (err) -> assert.equal err.code, 'ECONNRESET').end(body)

  it 'should handle multiple files', (done) ->
    app.post '/upload2', jfum.postHandler.bind(jfum), (req, res, next) ->
      assert.equal req.jfum.error, undefined
      assert.equal req.jfum.files.length, 2
      for file, i in req.jfum.files
        assert.deepEqual Object.keys(file), ['name', 'mime', 'path']
        assert.equal typeof file.path, 'string'
        assert.equal file.name, files[i].name
        assert.equal file.mime, files[i].mime
      res.end()
      done()

    [opts, body] = post app, '/upload2', files

    http.request(opts).on('error', assert.ifError).end(body)

  it 'should handle connection abort', (done) ->
    # Make sure the upload is not too fast
    files[0].size = 5000000
    files[1].size = 5000000

    app.post '/upload3', jfum.postHandler.bind(jfum), (req, res, next) ->
      assert.equal req.jfum.error, 'Request aborted'
      # there may be processed files in req.jfum.files
      res.end()
      done()

    [opts, body] = post app, '/upload3', files

    req = http.request opts
    req.on 'error', (err) ->
      assert.equal err.code, 'ECONNRESET'

    req.write(body)
    setTimeout req.abort.bind(req), 50 # send some data before aborting

    req = null

  it 'should handle invalid file', (done) ->
    files[0].name = 'foo.tiff'
    files[0].mime = 'image/tiff'

    app.post '/upload4', jfum.postHandler.bind(jfum), (req, res, next) ->
      assert.equal typeof req.jfum.error, 'undefined'
      assert.deepEqual req.jfum.files, [{
        name: files[0].name
        mime: files[0].mime
        error: code: 'JFUM-001', msg: 'File type not allowed'
      }]
      res.end()
      done()

    [opts, body] = post app, '/upload4', [files[0]]

    req = http.request opts
    req.on 'error', assert.ifError
    req.write body
    req.end()

