#!/usr/bin/env coffee

config = require('../config')
writePosts = require('../lib/write_posts_stdout')
listFetchedGroups = require '../lib/list_fetched_groups'
calculateMemberActivity = require '../lib/calculate_member_activity'

program = require('commander')

program
  .version('0.0.13')
  .option('-g, --group_id [value]', 'Facebook group id')
  .option('-l, --list', 'List groups you\'ve synced with Facebook')
  .option('-a, --member-activity', 'Calculate an activity score for each group member')
  .option('-s, --stdout', 'write downloaded posts to stdout')
  .option('-y, --year [value]', 'Only write to stdout posts created within a year', parseInt)
  .option('-m, --month [value]', 'Only write to stdout posts created within a month (usually paired with a year). Jan = 1, Feb = 2, etc.', parseInt)
  .parse(process.argv)

if program.list
  listFetchedGroups()
else if program.memberActivity
  calculateMemberActivity(program)
else if program.stdout
  writePosts(program)
else
  program.help()
