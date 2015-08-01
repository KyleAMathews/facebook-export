config = require('../config')
levelup = require('levelup')
_ = require 'underscore'
moment = require 'moment'
Table = require 'cli-table'

# What different activities are worth.
# Points have a 1/2 life of six months. So if a member created a post
# exactly six months ago, that action is now worth 2.5 points.
COMMENT = 10
LIKE = 1
POST = 5

module.exports = (program) ->
  # Get list of groups members.
  members = {}
  membersDb = levelup(config.dataDir + '/group_members_' + program.group_id, { valueEncoding: 'json' })
  membersDb.createReadStream()
    .on('data', (data) ->
      id = data.value.id
      members[id] = data.value
      members[id].points = 0
      members[id].comments = 0
      members[id].likes = 0
      members[id].posts = 0
    )
    .on('end', ->
      # Loop through all posts and comments and groups and assign points.
      postsDb = levelup(config.dataDir + '/group_' + program.group_id, { valueEncoding: 'json' })
      postsDb.createReadStream()
        .on('data', (data) ->
          post = data.value
          if moment().diff(moment(post.created_time), 'months') < 3
            within_3_months = true

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
            if within_3_months
              poster.posts += 1

          # Add points for post likes.
          if post.likes?
            for like in post.likes.data
              liker = _.find members, (member) -> member.id is like.id
              if liker?
                liker.points += LIKE * decay
                if within_3_months
                  liker.likes += 1

          # Add points for comments.
          if post.comments?
            for comment in post.comments.data
              commenter = _.find members, (member) -> member.id is comment.from?.id
              if commenter?
                commenter.points += COMMENT * decay
                if within_3_months
                  commenter.comments += 1
        )
        # We've gone through every post, send the results to stdout.
        .on('end', ->
          # Some people inexplicably have multiple facebook ids.
          # Combine by name (yes, this is a bad idea in larger groups as there'll
          # be genuine duplicate names).
          nameKeyed = {}
          mems = _.values members
          for member in mems
            # If name already exists, merge the records.
            if member.name of nameKeyed
              nameKeyed[member.name].points += member.points
              nameKeyed[member.name].posts += member.posts
              nameKeyed[member.name].comments += member.comments
              nameKeyed[member.name].likes += member.likes
            else
              nameKeyed[member.name] = member

          members = _.values nameKeyed

          sortedMembers = _.sortBy(members, (member) -> member.points).reverse()
          table = new Table({
            head: ['name', 'score', '# posts past 6 months', '# comments past 6 months', '# post likes past 6 months']
            colWidths: [25, 15, 15, 15, 15]
          })
          for member in sortedMembers
            table.push [member.name, member.points, member.posts, member.comments, member.likes]

          console.log table.toString()
        )
    )
