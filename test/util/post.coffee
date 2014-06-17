rand = require('crypto').pseudoRandomBytes

module.exports = (app, path, files) ->
  opts =
    hostname: app.server.address().address
    port: app.server.address().port
    path: path
    method: 'POST'
    headers:
      'Content-Type': [
        'multipart/form-data;
        boundary=---------------------------287032381131322'
      ].join(' ')
      'Content-Length': 0

  arr = ['']
  for file in files
    arr.push [
      '-----------------------------287032381131322'
      'Content-Disposition: form-data; name="files[]"; filename="' + file.name + '"'
      'Content-Type: ' + file.mime
      ''
      rand(file.size).toString('base64') + ';'
    ].join('\r\n')
  arr.push '-----------------------------287032381131322--'

  buff = new Buffer arr.join('\r\n') + '\r\n'
  opts.headers['Content-Length'] = buff.length

  return [opts, buff]

