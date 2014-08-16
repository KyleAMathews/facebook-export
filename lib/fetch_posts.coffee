config = require('../config')
request = require('request')
levelup = require('levelup')

# Module globals.
postsDb = {}
group_id = ""

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

    console.log 'fetched', posts?.data?.length, 'posts'
    # If there's previous posts still, keep fetching.
    if posts.paging?.next?
      requestPosts(posts.paging.next)
    for post in posts.data
      postsDb.put(post.id, post)
  )

module.exports = (program) ->
  config.groupsDb.get(program.group_id, (err, group) ->
    console.log ''
    console.log "Exporting posts and members list for the group \"#{group.name}\""
    console.log ''
    console.log ''
  )
  # Explicitly list fields so can set comment limits to 999 which should fetch
  # all comments in one pass.
  url = "https://graph.facebook.com/#{ program.group_id }/feed?limit=100&access_token=#{ program.accessToken }&
fields=from,to,message,picture,link,name,caption,description,created_time,updated_time,likes,comments.limit(999)"
  postsDb = levelup(config.dataDir + '/group_' + program.group_id, { valueEncoding: 'json' })
  group_id = program.group_id
  requestPosts(url)
