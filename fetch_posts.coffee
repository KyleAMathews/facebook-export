request = require('request')
config = require('./config')

requestPosts = (url) ->
  request(url, (error, response, body) ->
    if error
      console.log error
      # Shut everything down if there's an error. Almost certainly it means
      # the token is wrong or Facebook's API is having trouble.
      process.exit()
    posts = JSON.parse body
    console.log '# of posts retrieved', posts?.data?.length
    # If there's previous posts still, keep fetching.
    if posts.paging?.next?
      requestPosts(posts.paging.next)
    for post in posts.data
      config.postsDb.put(post.id, post)
  )

module.exports = (program) ->
  console.log "Starting Facebook Export…"
  # Explicitly list fields so can set comment limits to 999 which should fetch
  # all comments in one pass.
  url = "https://graph.facebook.com/#{ program.group_id }/feed?limit=500&access_token=#{ program.oauthToken }&
fields=from,to,message,picture,link,name,caption,description,created_time,updated_time,likes,comments.limit(999)"
  requestPosts(url)
