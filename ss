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
  'ogv'  :'video/ogv',
  'mp4'  :'video/mp4'
};

http.createServer(function(request, response) {

  var uri = url.parse(request.url).pathname,
  filename = path.join(www_root, uri),
  filetype = uri.toLowerCase().split('.').pop(),
  mimetype = (filetype && MIME_TYPES[filetype] ? MIME_TYPES[filetype] : MIME_TYPES['html']);
  
  
  // console.log("uri:"+uri+"\nfilename:"+filename+"\nfiletype:"+filetype+"\nmimetype:"+mimetype)
  // check if uri's last character is '/', if it does, redirect
  if (uri[uri.length-1] == "/"){
    response.writeHead(302, {
      'Location': uri.substr(0,uri.length-1)
      //add other headers here...
    });
    response.end();
  }
  // check if it's first level path and has no extension, if it is, then change it to './'
  names = filename.split("/")
  names = names.filter(function(element, index, array){return (element != "")}) //take out empty string
  first_name = names[0]
  // console.log('~~~~~~'+names, names.length)
  if (names.length == 1){
    if (first_name.indexOf(".") == -1){
      uri = "/"
      filename = "./"
      filetype = "/"
      mimetype = "text/html"
    }///if
  }///if
  
  
  fs.exists(filename, function(exists) {
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
