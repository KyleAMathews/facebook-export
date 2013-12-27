moment = require('moment')
config = require('./config')
util = require('util')

module.exports = (program) ->
  posts = []
  config.postsDb.createReadStream()
    .on('data', (data) ->
      write = true
      if program.year?
        unless moment(data.value.created_time).year() is program.year
          write = false
      if program.month?
        unless moment(data.value.created_time).month() is (program.month - 1) # Stupid JS dates
          write = false
      if write
        posts.push data.value
    )
    .on('error',  (err) ->
      console.log('LevelDB Error', err)
    )
    .on('close',  (err) ->
      console.log util.inspect(posts, { depth: null })
    )
