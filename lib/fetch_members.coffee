config = require('../config')
request = require('request')
levelup = require('levelup')

# Module globals.
membersDb = {}
group_id = ""

requestMembers = (url) ->
  request(url, (error, response, body) ->
    members = JSON.parse body
    if error
      console.log error
      # Shut everything down if there's an error. Almost certainly it means
      # the token is wrong or Facebook's API is having trouble.
      process.exit()
    else if "error" of members
      console.log members.error
      # Shut everything down if there's an error. Almost certainly it means
      # the token is wrong or Facebook's API is having trouble.
      process.exit()
    for member in members.data
      membersDb.put(member.id, member)
  )

module.exports = (program) ->
  # Explicitly list fields so can set comment limits to 999 which should fetch
  # all comments in one pass.
  url = "https://graph.facebook.com/#{ program.group_id }/members?access_token=#{ program.accessToken }"
  membersDb = levelup(config.dataDir + '/group_members_' + program.group_id, { valueEncoding: 'json' })
  group_id = program.group_id
  requestMembers(url)
