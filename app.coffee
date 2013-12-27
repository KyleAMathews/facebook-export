#!/usr/bin/env coffee

config = require('./config')
mkdirp = require('mkdirp')
program = require('commander')

fetchPosts = require('./fetch_posts')
writePosts = require('./write_posts')

# Ensure our directory for storing data is setup.
mkdirp.sync(config.dataDir)

# Parse arguments.
program
  .version('0.0.1')
  .option('-o, --oauthToken [value]', 'Facebook oauth token')
  .option('-g, --group_id [value]', 'Facebook group id')
  .option('-d, --download', 'Download posts from Facebook')
  .option('-w, --write', 'write downloaded posts to stdout')
  .option('-y, --year [value]', 'Only write to stdout posts created within a year', parseInt)
  .option('-m, --month [value]', 'Only write to stdout posts created within a month (usually paired with a year). Jan = 1, Feb = 2, etc.', parseInt)
  .parse(process.argv)

if program.download
  fetchPosts(program)
else if program.write
  writePosts(program)
else
  program.help()
