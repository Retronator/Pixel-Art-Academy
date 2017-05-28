AM = Artificial.Mummification

class AM.Hierarchy.Address
  constructor: (@_string) ->

  string: ->
    @_string

  fieldChild: (field) ->
    prefix = if @_string then "#{@_string}." else ''
    new @constructor "#{prefix}fields.#{field}"

  nodeChild: ->
    new @constructor "#{@_string}.node"
