# Description:
#   Store and retrieve quotes from the robots brain
#
# Dependencies:
#   auth.coffee and an installed role called 'quote' to delete quotes.
#
# Configuration:
#   The relevant HUBOT_AUTH_ADMIN entries to allow adding of roles to people for quote management
#
# Commands:
#   hubot addquote <quote> - add a new quote
#   hubot quote <pattern> - random quote if quote is empty, otherwise matching pattern
#
# Author
#   krakerag (based on work by pezholio @ https://github.com/github/hubot-scripts/blob/master/src/scripts/pinboard.coffee)

module.exports = (robot) ->
  # Time to do some quoting

  robot.respond /addquote (.*)/i, (msg) ->
    # Save a new quote
    newquote = msg.match[1]
    quote = new Quote robot
    quote.add newquote, (err, message) ->
      if err?
        msg.reply "That quote exists already."
      else
        msg.reply "Quote added"


  robot.respond /quote$/i, (msg) ->
    # Return a random quote from the list
    quote = new Quote robot
    quote.allAsArray (quotes) ->
      msg.reply msg.random quotes


  robot.respond /quote (.*)/i, (msg) ->
    # Return a matching random quote
    pattern = msg.match[1]
    quote = new Quote robot
    if `!isNaN(pattern)`
      quote.findByNum pattern, (err, message) ->
        if err?
          msg.reply "#{err}"
        else
          msg.reply message
    else
      quote.find pattern, (err, message) ->
        if err?
          msg.reply "#{err}"
        else
          msg.reply message


  robot.respond /delquote ([0-9]+)/i, (msg) ->
    # Delete a quote if you have permission
    if robot.Auth and robot.Auth.hasRole(msg.message.user.name, "quotes")
      quoteId = msg.match[1]
      quote = new Quote robot
      quote.remove quoteId, (err, message) ->
        if err?
          msg.reply "#{err}"
        else
          msg.reply message
    else
      msg.send "You do not have the 'quotes' role to delete quotes"

class Quote
  constructor: (robot) ->
    robot.brain.data.quotes ?= []
    @quotes_ = robot.brain.data.quotes

  all: (quote) ->
    if quote
      @quotes_.push quote
    else
      @quotes_

  allAsArray: (callback) ->
    entries = []
    i = 0
    @all().forEach (entry) ->
      i++
      entries.push "(" + i + "): " + entry
    callback entries

  add: (quote, callback) ->
    result = []
    @all().forEach (entry) ->
      if entry
        if entry is quote
          result.push quote
    if result.length > 0
      callback "Quote already exists"
    else
      @all quote
      callback null, "Quote added"

  remove: (removeId, callback) ->
    delKey = removeId - 1
    for key, value of @quotes_
      if `delKey == key`
        @quotes_.splice(key, 1)
        result = true
    if result is true
      callback null, "Quote deleted"
    else
      callback "Could not find quote id #{removeId} to delete"


  find: (description, callback) ->
    result = []
    i = 0
    @all().forEach (quote) ->
      i++
      if quote
        if RegExp(description, "i").test quote
          result.push "(" + i + "): " + quote
    if result.length > 0
      randNum = Math.floor(Math.random() * result.length)
      callback null, result[randNum]
    else
      callback "No results found"

  findByNum: (number, callback) ->
    result = []
    i = 0
    @all().forEach (quote) ->
      i++
      if quote
        if `i == number`
          result.push "(" + i + "): " + quote
    if result.length > 0
      callback null, result[0]
    else
      callback "No results found"
