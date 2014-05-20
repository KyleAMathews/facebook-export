facebook-export
===============

Export data from your Facebok groups.

[![NPM](https://nodei.co/npm/facebook-export.png?downloads=true)](https://nodei.co/npm/facebook-export/)

### Install
This program comes with two executables: `facebook-export` which handles downloading and saving your information from Facebook and `facebook-analyze` which provides several ways for you to inspect and analyze your data.

To install:

First install [node.js](http://nodejs.org/).

Then run in your terminal:

`npm install -g facebook-export`

### Export data from Facebook.

To access your data through the Facebook API, Facebook requires you to use an access token. This must be included when you run `facebook-export`. The easiest way I've found is to grab one from Facebook's API explorer https://developers.facebook.com/tools/explorer

There click on the "Get Access Token" button and make sure you check the "user_groups" data permission. Once you've approved this app, copy the long random alphanumeric Access Token. We'll use it next to export your Facebook data.

![screen shot 2014-05-16 at 4 45 40 pm](https://cloud.githubusercontent.com/assets/71047/3003503/5c1ef460-dd54-11e3-8f79-7b53da728e87.png)

![screen shot 2014-05-16 at 4 46 06 pm](https://cloud.githubusercontent.com/assets/71047/3003502/5c0a3b24-dd54-11e3-8c2a-edd79035dfd0.png)

You need to know the Group ID of the group you wish to export data from. To see a list of all your groups and their Group IDs run:

`facebook-export -a <YOUR-ACCESS-TOKEN> -l`

This should return a list something like:

````
FACEBOOK GROUPS
* The Vinyl Club [122351275176234206]
* The Stanford 2nd Ward [1881523481214555]
* Frisbee [1462342888234234]
* etc.
````

To export the information (posts and members) for one of these groups run:

`facebook-export -a <ACCESS-TOKEN> -g <GROUP-ID> -d`

The downloaded information will be saved in LevelDB DBs at ~/.facebook-export

### Playing with your data
Once you've saved your information locally, you'll probably want to have a look at it. You'll use the `facebook-analyze` command for this.

To get a raw dump of the JSON encoded information from the API run:

`facebook-analyze -g <GROUP-ID> -s`

This will write all the group's posts to STDOUT.

You can filter posts by the year and month they were created in. E.g. to grab all posts from 2013 and save them to a file run:

`facebook-analyze -g <GROUP-ID> -y 2013 -s >> posts_2013.json`

I've also added a script which calculates an activity score for each member of the group. Members get points when they post/comment/like. To emphasize more recent activity, points have a 1/2 life of six months. Generate the activity chart by running:

`facebook-analyze -g <GROUP-ID> -a`
