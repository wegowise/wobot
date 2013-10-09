# Fetch the list of recent heroku releases
#
# heroku releases <app name>
sprintf = require("sprintf").sprintf

heroku_releases = (msg, application, callback) ->
  apiKey = process.env.HEROKU_APIKEY
  uri = 'https://api.heroku.com/apps/' + application + '/releases'
  msg.robot.http(uri)
    .headers(Authorization: "Basic #{new Buffer(":#{apiKey}").toString("base64")}", Accept: "application/json")
    .get() (err, res, body) ->
      if res.statusCode is 404
        msg.send "Application not found"
        return

      results = JSON.parse(body)
      if res.statusCode != 200
        msg.send results.error
        return

      callback(msg, results, application)

who_last_deployed = (msg, releases, application) ->
  release = releases.pop()
  user = release.user
  username = switch
    when /stawarz/.test(user) then '@ryan'
    when /dewyea/.test(user) then '@jed'
    when /method/.test(user) then '@method'
    when /nathan/.test(user) then '@nathan'
    when /singh/.test(user) then '@barun'
    when /cutler/.test(user) then '@cutler'
    when /infras/.test(user) then "the masked man known as 'infrastructure'"
    else release.user

  msg.send(user + " deployed " + application + " last at " + sprintf("%-s", release.created_at))

  if /@/.test(user) && /staging/.test(application)
    msg.send("Hey " + username + " are you still using " + application + "?")

show_releases = (msg, releases, application) ->
  output = "Here are the most recent releases of '"+application+"'\n"
  output += "Rel   Change                          By                    When\n"
  output += "----  ------------------------------  --------------------  -------------------\n"
  for release in releases.slice(-4).reverse()
    output += sprintf("%-4s  %-30s  %-20s  %-s", release.name, release.descr, release.user, release.created_at) + "\n"
  msg.send output

detect_applicaiton_name = (msg) ->
  return 'wego-staging' unless msg.match && msg.match[1]
  application = msg.match[1]
  application = 'wego-staging' if application == 'staging'
  application


module.exports = (robot) ->
  robot.hear /heroku releases\s?(.*)?/i, (msg) ->
    application = detect_applicaiton_name(msg)
    heroku_releases(msg, application, show_releases)
    return

  robot.hear /using staging|.*staging.*free/i, (msg) ->
    msg.send "Stand back, I got this..."
    heroku_releases(msg, 'wego-staging', who_last_deployed)
    msg.finish()

  robot.hear /anyone using ([\w-]*)/i, (msg) ->
    msg.send "Stand back, I got this..."

    application = detect_applicaiton_name(msg)
    heroku_releases(msg, application, who_last_deployed)
    msg.finish()

  robot.hear /who deployed ([\w-]*)/i, (msg) ->
    msg.send "A wobot's job is never done..."

    application = detect_applicaiton_name(msg)
    msg.send "ok ok, I'll check the releases of " + application
    heroku_releases(msg, application, who_last_deployed)
