# Description:
#   Store and retrieve quotes from the robots brain
#
# Dependencies:
#   N/A
#
# Configuration:
#   N/A
#
# Commands:
#   hubot addquote <quote> - add a new quote
#   hubot quote <pattern> - random quote if quote is empty, otherwise matching pattern
#
# Author
#   krakerag (based on work by pezholio)

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
    quote = new Quote robot
    quote.allAsArray (quotes) ->
      msg.reply msg.random quotes


  robot.respond /quote (.*)/i, (msg) ->
    # Return a matching random quote
    pattern = msg.match[1]
    quote = new Quote robot
    if pattern
      quote.find pattern, (err, message) ->
        if err?
          msg.reply "#{err}"
        else
          msg.reply message
    else


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
    @all().forEach (entry) ->
      entries.push entry
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

  find: (description, callback) ->
    result = []
    @all().forEach (quote) ->
      if quote
        if RegExp(description, "i").test quote
          result.push quote
    if result.length > 0
      callback null, result[Math.floor(Math.random() * result.length)]
    else
      callback "No results found"

