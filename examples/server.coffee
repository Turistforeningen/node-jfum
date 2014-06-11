exists = require('fs').exists
express = require('express')
logger = require('morgan')

app = module.exports = express()

JFUM = require '../src/index.coffee'
jfum = new JFUM
  minFileSize: 0
  maxFileSize: 10000000000
  acceptFileTypes: /\.(gif|jpe?g|png)$/i

app.use(logger('dev'))
app.use express.static __dirname
app.use (req, res, next) ->
  res.set 'Access-Control-Allow-Origin', '*'
  next()

app.options '/upload', jfum.optionsHandler.bind(jfum)
app.post '/upload', jfum.postHandler.bind(jfum), (req, res, next) ->
  console.log 'app.post.upload'
  console.log file for file in req.jfum.files
  res.json req.jfum

app.listen 8080 if not module.parent

