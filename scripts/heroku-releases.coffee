# Fetch the list of recent heroku releases
#
# heroku releases <app name>
sprintf = require("sprintf").sprintf

module.exports = (robot) ->
  robot.respond /heroku releases (.*)/i, (msg) ->
    apiKey = process.env.HEROKU_APIKEY
    application = msg.match[1]
    uri = 'https://api.heroku.com/apps/' + application + '/releases'

    msg.http(uri)
      .headers(Authorization: "Basic #{new Buffer(":#{apiKey}").toString("base64")}", Accept: "application/json")
      .get() (err, res, body) ->
        if res.statusCode is 404
          msg.send "Application not found"
          return

        results = JSON.parse(body)

        if res.statusCode is 403
          msg.send results.error
          return

        output = "\n"
        output += "Rel   Change                          By                    When\n"
        output += "----  ------------------------------  --------------------  -------------------\n"

        for release in results.slice(-4)
          output += sprintf("%-4s  %-30s  %-20s  %-s", release.name, release.descr, release.user, release.created_at) + "\n"
        msg.send output
