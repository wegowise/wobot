# Description:
#   Retrieve information about db refreshes
#
# Dependencies:
#   None
#
# Configuration:
#   DB_REFRESH_URL
#
# Commands
#   hubot db:refresh:status
#
# Author:
#   fixlr

db_refresh_url = process.env.DB_REFRESH_URL

module.exports = (robot) ->
  robot.respond /db:refresh:status/, (msg) ->
    msg
      .http('http://s3.amazonaws.com/wegowise-database-exports/staging-updated')
      .get() (err, res, body) ->
        throw err if err
        date = new Date(body*1000)
