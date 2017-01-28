AE = Artificial.Everywhere
AB = Artificial.Base

class AB.Method
  constructor: (options) ->
    # We want the method to behave as a function that calls the Meteor method.
    method = (args...) -> Meteor.call options.name, args...

    # Method that registers the handler.
    method.method = (handler) ->
      Meteor.methods
        "#{options.name}": handler

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf method, @constructor.prototype

    # Return the method function (return must be explicit).
    return method
