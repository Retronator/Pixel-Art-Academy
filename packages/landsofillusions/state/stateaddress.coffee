LOI = LandsOfIllusions

class LOI.StateAddress
  constructor: (@_string) ->

  string: ->
    @_string

  child: (field) ->
    new @constructor "#{@_string}.#{field}"
