config = require('../config')
levelup = require('levelup')
_ = require 'underscore'
moment = require 'moment'

# What different activities are worth.
# Points have a 1/2 life of six months. So if a member created a post
# exactly six months ago, that action is now worth 2.5 points.
COMMENT = 10
LIKE = 1
POST = 5

module.exports = (program) ->
  # Get list of groups members.
  members = []
  membersDb = levelup(config.dataDir + '/group_members_' + program.group_id, { valueEncoding: 'json' })
  membersDb.createReadStream()
    .on('data', (data) ->
      member = data.value
      member.points = 0
      members.push member
    )
    .on('end', ->
      # Loop through all posts and comments and groups and assign points.
      postsDb = levelup(config.dataDir + '/group_' + program.group_id, { valueEncoding: 'json' })
      postsDb.createReadStream()
        .on('data', (data) ->
          post = data.value

          # Calculate exponential decay.
          # Points have a 1/2 life of six months. So if a member created a post
          # exactly six months ago, that action is now worth 2.5 points.
          SIX_MONTHS = 182.5
          days_old = moment().diff(moment(post.created_time), 'days')
          decay = 1 / Math.pow(2, (days_old / SIX_MONTHS))

          # Add points to the poster.
          poster = _.find members, (member) -> member.id is post.from?.id
          if poster?
            poster.points += POST * decay

          # Add points for post likes.
          if post.likes?
            for like in post.likes.data
              liker = _.find members, (member) -> member.id is like.id
              if liker?
                liker.points += LIKE * decay

          # Add points for comments.
          if post.comments?
            for comment in post.comments.data
              commenter = _.find members, (member) -> member.id is comment.from?.id
              if commenter?
                commenter.points += COMMENT * decay
        )
        # We've gone through every post, send the results to stdout.
        .on('end', ->
          sortedMembers = _.sortBy(members, (member) -> member.points).reverse()
          for member in sortedMembers
            console.log "#{member.name}, #{member.points}"
        )
    )
