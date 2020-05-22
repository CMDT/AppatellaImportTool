var glob = require('glob')
var path = require('path')
var fs = require('fs')

var read = function (filePath) {
    var contents = fs.readFileSync(filePath, 'utf8')
    var name = path.basename(filePath, '.sql')
    return {
        name: name,
        contents: contents
    }
}

var readAll = function (path) {
    var files = glob.sync(path + '/**/*.sql')
    return files.map(read)
}

var Gen = function (path) {
    var queries = this.queries = {}
    readAll(path).forEach(function (q) {
        queries[q.name] = q
    })
}

Gen.prototype.get = function (name) {
    return (this.queries[name] || 0).contents || false
}

Gen.prototype.gen = function (name, qValues) {
    var result = null;
    var qText = this.get(name)
    if (qText) {
        result = {
            name: name,
            text: qText,
            values: qValues
        }
        return result;

    }
}

module.exports = function (path) {
    return new Gen(path)
}