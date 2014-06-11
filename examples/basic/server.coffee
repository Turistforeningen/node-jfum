exists = require('fs').exists
app = module.exports = require('express')()
JFUM = require '../../src/index.coffee'
jfum = new JFUM
  minFileSize: 0
  maxFileSize: 10000000000
  acceptFileTypes: /\.(gif|jpe?g|png)$/i

app.options '/upload', jfum.optionsHandler.bind(jfum)
app.post '/upload', jfum.postHandler.bind(jfum), (req, res, next) ->
  console.log req.jfum
  return res.json foo: 'bar' if req.jfum is null

  exists req.jfum.file, (exist) ->
    console.log "File #{if exist then 'exists' else 'does not exist'}!"
    res.end()

app.listen 8080 if not module.parent

