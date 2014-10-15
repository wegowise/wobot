# Description:
#   CoffeeMe gets you a cup of coffee.
#
# Dependencies:
#   None
#
# Commands:
#   hubot coffee me

module.exports = (robot) ->

  robot.respond /coffee me/i, (msg) ->
    msg.send '(coffee)'
