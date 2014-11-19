config = require('../config')
request = require('request')
levelup = require('levelup')
_ = require 'underscore'
moment = require 'moment'

# Module globals.
postsDb = {}
program = {}
group_id = ""

sortedUpdated = (posts) ->
  return _.pluck(posts.data, 'updated_time').sort()

requestPosts = (url) ->
  request(url, (error, response, body) ->
    posts = JSON.parse body
    if error
      console.log error
      # Shut everything down if there's an error. Almost certainly it means
      # the token is wrong or Facebook's API is having trouble.
      process.exit()
    else if "error" in posts
      console.log posts.error
      # Shut everything down if there's an error. Almost certainly it means
      # the token is wrong or Facebook's API is having trouble.
      process.exit()

    numPostsFetched = posts?.data?.length

    # Take last updated date and get URL with it as "since"
    newUntil =  moment(_.first sortedUpdated(posts)).unix() - 1

    console.log 'fetched', numPostsFetched, 'posts. The oldest post fetched was last updated: ' + moment(_.first sortedUpdated(posts)).format("dddd, MMMM Do YYYY, h:mm:ss a")

    for post in posts.data
      postsDb.put(post.id, post)

    # We've fetched back far enough, quit
    if program.downloadSince >= newUntil
      process.exit()
    # There's still more!
    else if numPostsFetched > 0
      newUrl = getURL(null, newUntil)
      requestPosts(newUrl)
    # There's nothing left for us here, quit.
    else
      process.exit()
  )

getURL = (since = null, untilTime = null) ->
  # Explicitly list fields so can set comment limits to 999 which should fetch
  # all comments in one pass.
  url = "https://graph.facebook.com/#{ program.group_id }/feed?limit=100&access_token=#{ program.accessToken }&
fields=from,to,message,picture,link,name,caption,description,created_time,updated_time,likes,comments.limit(999)"

  unless untilTime?
    url += "&until=#{moment().unix()}"
    untilTime = moment().unix()
  else
    url += "&until=#{untilTime}"

  if since?
    url += "&since=#{since}"
  else
    if program.downloadSince?
      url += "&since=#{program.downloadSince}"
    # Nothing is indicated, set since to the beginning of (UNIX) time.
    else
      url += "&since=0"

  return url

module.exports = (p) ->
  # Assign module global.
  program = p

  config.groupsDb.get(program.group_id, (err, group) ->
    console.log ''
    console.log "Exporting posts and members list for the group \"#{group.name}\""
    console.log ''
    console.log ''
  )

  url = getURL()

  postsDb = levelup(config.dataDir + '/group_' + program.group_id, { valueEncoding: 'json' })
  group_id = program.group_id

  requestPosts(url)
