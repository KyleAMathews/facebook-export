facebook-export
===============

Export data from your timeline or groups you belong to

[![NPM](https://nodei.co/npm/facebook-export.png?downloads=true)](https://nodei.co/npm/facebook-export/)

### Install
First install node.js then run in your terminal:

`npm install -g facebook-export`

### Export data from Facebook.

First get an OAuth token from Facebook. The easiest way I've found is to grab one from Facebook's API explorer https://developers.facebook.com/tools/explorer?method=GET&path=338164739567715%2Ffeed

Then to export all the posts and comments from a group, run this command.

`facebook-export -o <YOUR-OAUTH-TOKEN> -g <YOUR-GROUP-ID> -d`

All posts will be downloaded and saved in a LevelDB DB at ~/.facebook-export

### Playing with your data
facebook-export can write your data out as JSON. E.g. `facebook-export -w` will write all posts to STDOUT. You can limit posts that are exported by month and year. E.g. to save all posts from 2013 run `facebook-export -y 2013 -w >> posts_2013.json`
