config = require '../config'
fs = require 'fs'

module.exports = ->
  directories = fs.readdirSync(config.dataDir).filter (directory) ->
    fs.statSync(config.dataDir + '/' + directory).isDirectory()

  directories = directories.map (directory) ->
    splits = directory.split('_')
    splits[splits.length - 1]

  groups = []
  config.groupsDb.createReadStream()
    .on('data', (data) ->
      groups.push data
    )
    .on('end', ->
      console.log ''
      console.log ''
      console.log "Groups with fetched information"
      groups = groups.map((group) -> group.value)
      for id in directories
        group = groups.filter((group) -> group.id is id)[0]
        if group?
          console.log "* #{group.name} [#{group.id}]"
      console.log ''
      console.log ''
    )
