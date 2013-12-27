request = require('request')
levelup = require('levelup')

# Setup Posts Leveldb db.
postsDb = levelup(process.env.DATA_DIR + '/postsdb', { valueEncoding: 'json' })

requestPosts = (url) ->
  request(url, (error, response, body) ->
    posts = JSON.parse body
    console.log '# of posts retrieved', posts?.data?.length
    # If there's previous posts still, keep fetching.
    if posts.paging?.next?
      console.log 'fetching still more posts', posts.paging.next
      requestPosts(posts.paging.next)
    for post in posts.data
      postsDb.put(post.id, post)
  )

module.exports = (program) ->
  url = "https://graph.facebook.com/#{ program.group_id }/feed?limit=500&access_token=#{ program.oauthToken }"
  requestPosts(url)
