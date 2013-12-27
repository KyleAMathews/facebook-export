#!/usr/bin/env coffee

mkdirp = require('mkdirp')
program = require('commander')

# Set a . directory for storing data that works cross-platform.
homeDir = process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']
process.env['DATA_DIR'] = homeDir + "/.facebook_export"

fetchPosts = require('./fetch_posts')

# Ensure our directory for storing data is setup.
mkdirp.sync(process.env.DATA_DIR)

# Parse arguments.
program
  .version('0.0.1')
  .option('-o, --oauthToken [value]', 'Facebook oauth token')
  .option('-g, --group_id [value]', 'Facebook group id')
  .parse(process.argv)

fetchPosts(program)
