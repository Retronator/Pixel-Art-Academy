# Operations that deal with URL strings.

_.mixin
  waitForSeconds: (seconds) ->
    new Promise (resolve) => Meteor.setTimeout resolve, seconds * 1000

  waitForNextFrame: ->
    _.waitForSeconds 0

  waitForFlush: ->
    new Promise (resolve) => Tracker.afterFlush resolve
