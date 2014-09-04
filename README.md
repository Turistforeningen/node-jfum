jQuery File Upload Middleware [![Build Status](https://drone.io/github.com/Turistforeningen/node-jfum/status.png)](https://drone.io/github.com/Turistforeningen/node-jfum/latest)
=============================

[![NPM](https://nodei.co/npm/jfum.png?downloads=true)](https://www.npmjs.org/package/jfum)

## Features

* File upload handling
* File size validation
* File type validation
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
var JFUM = require('jfum');
var jfum = new JFUM({
  minFileSize: 204800,                      // 200 kB
  maxFileSize: 5242880,                     // 5 mB
  acceptFileTypes: /\.(gif|jpe?g|png)$/i    // gif, jpg, jpeg, png
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
  // Check if upload failed or was aborted
  if (req.jfum.error) {
    // req.jfum.error

  } else {
    // Here are the uploaded files
    for (var i = 0; i < req.jfum.files.length; i++) {
      var file = req.jfum.files[i];

      // Check if file has errors
      if (file.errors.length > 0) {
        for (var j = 0; i < file.errors.length; i++) {
          // file.errors[j].code
          // file.errors[j].message
        }

      } else {
        // file.field - form field name
        // file.path - full path to file on disk
        // file.name - original file name
        // file.size - file size on disk
        // file.mime - file mime type
      }
    }
  }
});
```

#### Error Codes

The `req.jfum.files[]` object can have the following error codes:

* `JFUM-001` - File type not allowed
* `JFUM-002` - File size too big
* `JFUM-003` - File size too small

