homeDir = process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']
dataDir = homeDir + "/.facebook_export"
levelup = require('levelup')

module.exports =
  homeDir: homeDir
  dataDir: dataDir
  groupsDb: levelup(dataDir + '/groupsMetaData', { valueEncoding: 'json' })
