#!/usr/bin/env node
//
// Simple server to serve static pages
// Intended to be used for quick testing
//
// Takes two params: port, root directory
//
// visit the /kill path to exit
//

var http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs"),
    www_root = process.argv[3] || '.',
    port = process.argv[2] || 8000,
    MIME_TYPES = {
      'css'  :'text/css',
      'gif'  :'image/gif',
      'htm'  :'text/html',
      'html' :'text/html',
      'ico'  :'image/x-icon',
      'jpeg' :'image/jpeg',
      'jpg'  :'image/jpeg',
      'js'   :'text/javascript',
      'json' :'application/json',
      'png'  :'image/png',
      'txt'  :'text/text',
      'svg'  :'image/svg+xml',
      'json' :'application/json',
      'pdf'  :'application/pdf',
      'wmv'  :'video/x-ms-wmv',
      'ogg'  :'video/ogg',
      'mp4'  :'video/mp4'
    };

http.createServer(function(request, response) {

  var uri = url.parse(request.url).pathname,
      filename = path.join(www_root, uri),
      filetype = uri.toLowerCase().split('.').pop(),
      mimetype = (filetype && MIME_TYPES[filetype] ? MIME_TYPES[filetype] : MIME_TYPES['html']);


  path.exists(filename, function(exists) {
    if(!exists) {
      response.writeHead(404, {"Content-Type": "text/plain"});
      response.write("404 Not Found\n");
      response.end();
      return;
    }

    if (fs.statSync(filename).isDirectory()) filename += '/index.html';

    fs.readFile(filename, "binary", function(err, file) {
      if(err) {
  response.writeHead(500, {"Content-Type": "text/plain"});
	response.write(err + "\n");
	response.end();
        console.log('Error serving file: ' + filename);
	return;
      }

      response.writeHead(200, {
        "Content-Length": file.length,
        "Content-Type": mimetype
      });
      response.write(file, "binary");
      response.end();
      console.log('Served file: ', filename);
    });
  });
}).listen(parseInt(port, 10));

console.log("Static file server running at\n  => http://127.0.0.1:" + port + "/\nCTRL + C to shutdown");
