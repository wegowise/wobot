# Description:
#   Retreive information about deploys from Honeybadger.
#
# Dependencies:
#   None
#
# Configuration:
#   HONEYBADGER_API_TOKEN
#
# Commands
#   hubot releases <name>
#
# Author:
#   fixlr

hb_token = process.env.HONEYBADGER_API_TOKEN

parse_results = (body) ->
  JSON.parse(body).results

honeybadger_projects = (msg, application, callback) ->
  msg.robot.http("https://api.honeybadger.io/v1/projects?auth_token=#{hb_token}")
    .get() (err, res, body) ->
      if err
        msg.send "Honeybadger don't care."
        return
      for project in parse_results(body)
        if application == project.name.toLowerCase()
          app_id = project.id
          callback(msg, app_id, application)


honeybadger_releases = (msg, app_id, app_name) ->
  msg.robot.http("https://api.honeybadger.io/v1/projects/#{app_id}/deploys?auth_token=#{hb_token}")
    .get() (err, res, body) ->
      if err
        msg.send "Honeybadger don't care."
        return
      honeybadger_last_release(msg, parse_results(body), app_name)

honeybadger_last_release = (msg, releases, application) ->
  for release in releases
    if release.environment == 'staging'
      user = release.local_username
      created_at = new Date(release.created_at)
      msg.send "#{user} deployed #{application}-staging #{time_since(created_at)} ago."
      return

time_since = (date) ->
  seconds = Math.floor((new Date() - date) / 1000)
  interval = Math.floor(seconds / 86400)
  if (interval > 1)
    return "#{interval} days"

  interval = Math.floor(seconds / 3600)
  if (interval > 1)
    return "#{interval} hours"

  interval = Math.floor(seconds / 60)
  if (interval > 1)
    return "#{interval} minutes"

  return "#{Math.floor(seconds)} seconds"

module.exports = (robot) ->
  robot.respond /releases ([\w]+)/i, (msg) ->
    app_name = msg.match[1]
    honeybadger_projects(msg, app_name, honeybadger_releases)

  robot.hear /(anyone using|anybody using|who deployed) ([\w]+)/i, (msg) ->
    app_name = msg.match[2]
    app_name = process.env.HONEYBADGER_DEFAULT_APP if app_name == 'staging'
    if !app_name.match(/chartio/i)
      msg.send "Stand back, I got this..."
      honeybadger_projects(msg, app_name, honeybadger_releases)
