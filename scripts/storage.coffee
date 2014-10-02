# Description:
#   Inspect the data in redis easily
#
# Commands:
#   hubot show users - Display all users that hubot knows about
#   hubot show storage - Display the contents that are persisted in the brain


Util = require "util"

module.exports = (robot) ->

  admin = process.env.HUBOT_AUTH_ADMIN

  robot.respond /show storage$/i, (msg) ->
    if msg.message.user.name.toLowerCase() in admin.toLowerCase().split(',')
      output = Util.inspect(robot.brain.data, false, 4)
      msg.send output
    else
      msg.send "You must be an admin for this"

  robot.respond /show users$/i, (msg) ->
    response = ""

    for own key, user of robot.brain.data.users
      response += "#{user.id} #{user.name}"
      response += " <#{user.email_address}>" if user.email_address
      response += "\n"

    msg.send response

