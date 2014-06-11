jQuery File Upload Middleware
=============================

`Warning` this module is currently in active development and will change without
notice!

## Features

* Bare minimal – no extra stuff
* Made for Express 4.x

## Requirements

* Node.JS >= 0.10
* Express >= 4

## Install

```
npm install jfum --save
```

## Usage

```javascript
var JFUM = require('JFUM');
var jfum = new JFUM({
  tmpDir: '/tmp',
  minFileSize: 1,
  maxFileSize: 10000000000,
  acceptFileTypes: /\.(gif|jpe?g|png)$/i
});
```

### OPTIONS

jQuery File Upload makes an OPTIONS request to the server before starting the
uppload to make sure that it can upload to the given server.

```javascript
app.options('/upload', jfum.optionsHandler.bind(jfum));
```

### POST

```javascript
app.post('/upload', jfum.postHandler.bind(jfum), function(req, res) {
  if (typeof req.jfum === 'object' && typeof req.jfum.error === 'undefined') {
    // req.jfum.file - file location on disk
    // req.jfum.name - original file name
    // req.jfum.size - file size on disk
    // req.jfum.type - mime type for the file
  } else {
    // the file was rejected or not uploaded correctly
    // error message will be in req.jfum.error
  }
});
```

