AE = Artificial.Everywhere
AB = Artificial.Base

class AB.Subscription
  constructor: (@options) ->
    @query = @options.query

  subscribe: ->
    subscribeProvider = Meteor
    parameters = arguments

    if arguments[0]?.subscribe
      # First argument is the subscribe method provider, so pop it off.
      subscribeProvider = arguments[0]
      parameters = _.tail arguments

    subscribeProvider.subscribe @options.name, parameters...

  # Method that publishes the handler.
  publish: (handler) ->
    if Artificial.debug
      originalHandler = handler
      name = @options.name

      handler = ->
        console.log "Publishing", name, arguments
        originalHandler.call @, arguments...

    Meteor.publish @options.name, handler
