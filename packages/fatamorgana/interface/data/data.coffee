FM = FataMorgana

class FM.Interface.Data
  constructor: (@options) ->
    @options.address ?= ''
    @value = new @constructor.Value @options

    @_children = {}

  destroy: ->
    @value.stop()
    child.destroy() for name, child of @_children

  child: (field) ->
    unless @_children[field]
      childAddress = if @options.address.length then "#{@options.address}.#{field}" else field

      @_children[field] = new @constructor
        address: childAddress
        load: @options.load
        save: @options.save

    @_children[field]

  get: (field) ->
    if field
      child = @child field
      child.value()

    else
      # We support not supplying a field to have get as an alias of value in template helpers.
      @value()

  set: (field, value) ->
    child = @child field
    child.value value
