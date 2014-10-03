# Description:
#   Display the it's happening gif
#
# Commands:
#   it's happening - Display the gif

module.exports = (robot) ->

  robot.hear /it\'s happening$/i, (msg) ->
    msg.send "http://uboachan.net/yn/src/1360549114983.gif"
