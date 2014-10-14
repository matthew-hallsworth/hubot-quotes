# Description:
#   Store and retrieve quotes from the robots brain
#
# Dependencies:
#   "cron": "0.3.3"
#   "time": "0.8.2"
#   auth.coffee and an installed role called 'quote' to delete quotes.
#
# Configuration:
#   The relevant HUBOT_AUTH_ADMIN entries to allow adding of roles to people for quote management
#
# Commands:
#   hubot addquote <quote> - add a new quote
#   hubot quote <pattern> - random quote if quote is empty, otherwise matching pattern
#   hubot delquote <number> - delete a quote if you have 'quote' role
#   hubot numquotes - return the number of quotes in the system
#   hubot qotd - assign a random quote to the topic if you have 'quote' role
#
# Note:
#   The script also has a way to automatically populate the topic with a random quote.
#   You can change this by changing the cronTimestamp and quoteRoom parameters
#   ( or just remove completely the code on lines 26-30 and 35-39 inclusive.
#
# Author
#   krakerag (based on work by pezholio's pinboard script)
#   https://github.com/matthew-hallsworth/hubot-quotes/blob/master/scripts/quotes.coffee

timezone = "Australia/Melbourne"
cronTimestamp = '*/2 * * * *' # M-F 5pm
quoteRoom = "#tempest"

cronJob = require('cron').CronJob

module.exports = (robot) ->
  # Time to do some quoting
  
  quoteOfTheDay = new cronJob cronTimestamp, 
    ->
      quote = new Quote robot
      quote.allAsArray (quotes) ->
        robot.topic quoteRoom msg.random quotes
    null
    true
    timezone

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

  robot.respond /qotd$/i, (msg) ->
    # Set a random quote from the list as topic
    if robot.Auth and robot.Auth.hasRole(msg.message.user.name, "quotes")
      quote = new Quote robot
      quote.allAsArray (quotes) ->
        msg.topic msg.random quotes
    else
      msg.send "You do not have the 'quotes' role to delete quotes"

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

	  
  robot.respond /numquotes/i, (msg) ->
    quote = new Quote robot
    quote.countQuotes (message) ->
      msg.reply "#{message}"


class Quote
  constructor: (robot) ->
    robot.brain.data.quotes ?= []
    @quotes_ = robot.brain.data.quotes

  all: (quote) ->
    if quote
      @quotes_.push quote
    else
      @quotes_

  countQuotes: (callback) ->
    i = 0
    @all().forEach (entry) ->
      i++
    callback i

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
