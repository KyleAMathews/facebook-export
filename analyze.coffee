#!/usr/bin/env coffee

config = require('./config')
program = require('commander')

writePosts = require('./write_posts')
listFetchedGroups = require './list_fetched_groups'

program
  .version('0.0.9')
  .option('-g, --group_id [value]', 'Facebook group id')
  .option('-l, --list', 'List groups you\'ve synced with Facebook')
  .option('-s, --stdout', 'write downloaded posts to stdout')
  .option('-y, --year [value]', 'Only write to stdout posts created within a year', parseInt)
  .option('-m, --month [value]', 'Only write to stdout posts created within a month (usually paired with a year). Jan = 1, Feb = 2, etc.', parseInt)
  .parse(process.argv)

if program.list
  listFetchedGroups()
else if program.stdout
  writePosts(program)
else
  program.help()
