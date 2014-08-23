#!/usr/bin/env coffee

config = require('../config')
mkdirp = require('mkdirp')
program = require('commander')

fetchPosts = require('../lib/fetch_posts')
fetchMembers = require('../lib/fetch_members')
fetchGroups = require('../lib/fetch_groups')

# Ensure our directory for storing data is setup.
mkdirp.sync(config.dataDir)

# Parse arguments.
program
  .version('0.0.13')
  .option('-a, --accessToken [value]', 'Facebook access token')
  .option('-g, --group_id [value]', 'Facebook group id')
  .option('-d, --download', 'Download posts from Facebook for the specified group_id')
  .option('-s, --download-since [value]', 'Download posts from Facebook for the specified group_id since a unix timestamp e.g. --download-since 1408320000')
  .option('-l, --list', 'List groups you belong to on Facebook')
  .parse(process.argv)

if program.list
  fetchGroups(program)
else if program.download or program.downloadSince
  fetchPosts(program)
  fetchMembers(program)
else
  program.help()
