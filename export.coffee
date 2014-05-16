#!/usr/bin/env coffee

config = require('./config')
mkdirp = require('mkdirp')
program = require('commander')

fetchPosts = require('./fetch_posts')
fetchMembers = require('./fetch_members')
fetchGroups = require('./fetch_groups')

# Ensure our directory for storing data is setup.
mkdirp.sync(config.dataDir)

# Parse arguments.
program
  .version('0.0.9')
  .option('-o, --oauthToken [value]', 'Facebook oauth token')
  .option('-g, --group_id [value]', 'Facebook group id')
  .option('-d, --download', 'Download posts from Facebook for a specific group_id')
  .option('-l, --list', 'List groups you belong to on Facebook')
  .parse(process.argv)

if program.list
  fetchGroups(program)
else if program.download
  fetchPosts(program)
  fetchMembers(program)
else
  program.help()
