AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mummification

class AM.DatabaseContent.Subscription extends AB.Subscription
  subscribeContent: ->
    subscribeProvider = Meteor
    parameters = arguments
  
    if arguments[0]?.subscribeContent
      # First argument is the subscribeContent method provider, so pop it off.
      subscribeProvider = arguments[0]
      parameters = _.tail arguments
      subscribeProvider.subscribeContent @options.name, parameters...
  
    else
      AM.DatabaseContent.subscribe @options.name, parameters...
  
  publish: (handler) ->
    if Meteor.isServer
      super arguments...

    else
      AM.DatabaseContent.publish @options.name, handler
