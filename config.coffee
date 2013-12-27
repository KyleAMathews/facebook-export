levelup = require('levelup')
homeDir = process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']
dataDir = homeDir + "/.facebook_export"

module.exports =
  homeDir: homeDir
  dataDir: dataDir
  postsDb: levelup(dataDir + '/postsdb', { valueEncoding: 'json' })
