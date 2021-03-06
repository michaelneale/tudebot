# Because it's so much fun
#
# abuse <name> - Abuse someone, for fun and profit.

welcomes = [
  "Welcome back",
  "Thanks for turning up",
  "Decided to make the effort hey",
  "G'day",
  "Fuck you",
  "Fuck off"
]

nameOf = (subject, robot, msg) ->
  subject = subject.trim()
  switch subject.toLowerCase()
    when "me", "i" then msg.message.user.name
    when "yourself", robot.name.toLowerCase() then robot.name
    when msg.message.user.name.toLowerCase() then msg.message.user.name
    else subject

phrasePrefixedWithIndefiniteArticle = (phrase) ->
  if phrase.match /^h?[aeiou]/i
    "an #{phrase}"
  else
    "a #{phrase}"

personalizedPhrase = (phrase) ->
  if phrase.match /(^i('?ve| have|'?m| am|'?ll| will)|you$)/i
    phrase
  else
    "you #{phrase}"

insult = (msg, callback) ->
  msg.http("http://www.insultsandabuse.com/generate_and_send.php")
    .headers
      "Accept": "*/*"
      "Content-Type": "application/x-www-form-urlencoded"
    .post("create_insult=\n") (err, res, body) ->
      matches = body.match /Your specially rolled insult is:.*?<h1>(.*?)<\/h1>/i
      if matches
        callback matches[1].toLowerCase()
      else
        callback body

module.exports = (robot) ->

  robot.enter (msg) ->
    return if msg.message.user.name == robot.name

    insult msg, (phrase) ->
      msg.send "#{msg.random welcomes}, you #{phrase}"

  robot.respond /what (?:do|did) you think (?:of|about) ([^?]+)\??$/i, (msg) ->
    insult msg, (phrase) ->
      name = nameOf(msg.match[1], robot, msg)
      switch name
        when robot.name then msg.reply "Enough about me, let's talk about you. You're #{phrasePrefixedWithIndefiniteArticle(phrase)}"
        when msg.message.user.name then msg.reply "You're #{phrasePrefixedWithIndefiniteArticle(phrase)}"
        else msg.reply "#{name} is #{phrasePrefixedWithIndefiniteArticle(phrase)}"

  robot.respond /sudo .*/i, (msg) ->
    insult msg, (phrase) ->
      msg.reply "Nice try, you #{phrase}"

  robot.respond /(abuse|insult|mock) (.+)$/i, (msg) ->
    insult msg, (phrase) ->
      name = nameOf(msg.match[2], robot, msg)
      switch name
        when robot.name then msg.reply "Nice try, you #{phrase}"
        when msg.message.user.name then msg.reply "What kind of #{phrase} tries to #{msg.match[1].toLowerCase()} themselves?"
        else msg.send "#{name}: You are #{phrasePrefixedWithIndefiniteArticle(phrase)}"

  robot.respond /(?:I think )?(?:you(?:'?re?)?|is) /i, (msg) ->
    insult msg, (phrase) ->
      msg.reply "And you're #{phrasePrefixedWithIndefiniteArticle(phrase)}"

  robot.respond /((?:get|fuck|suck|blow|lick|poke|eat|make|do|give|take|ride|go|.* your|keep|why) (?:.*))/i, (msg) ->
    insult msg, (phrase) ->
      msg.reply "No, #{personalizedPhrase(msg.match[1].toLowerCase())}, you #{phrase}"
