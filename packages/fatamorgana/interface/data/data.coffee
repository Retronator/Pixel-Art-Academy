FM = FataMorgana

class FM.Interface.Data
  constructor: (@options) ->
    @options.address ?= ''
    @value = Tracker.nonreactive => new @constructor.Value @options

    @_children = {}

  destroy: ->
    @value.stop()
    child.destroy() for name, child of @_children

  child: (field) ->
    unless @_children[field]
      childAddress = if @options.address.length then "#{@options.address}.#{field}" else field

      @_children[field] = new @constructor
        address: childAddress
        load: => _.nestedProperty @value(), field
        save: @options.save
        parent: @

    @_children[field]

  get: (field) ->
    if field?
      child = @child field
      child.value()

    else
      # We support not supplying a field to have get as an alias of value in template helpers.
      @value()

  set: (field, value) ->
    child = @child field
    child.value value

  # Returns the raw value for children nodes of desired type.
  findValuesOfChildrenOfType: (classOrId) ->
    id = classOrId?.id() or classOrId
    value = @value()
    results = []

    @_findValuesOfChildrenOfType id, value, results

    results

  _findValuesOfChildrenOfType: (id, value, resultArray) ->
    return unless _.isObject value

    # We have found the child if we have a type or contentComponentId that matches.
    if value.type is id or value.contentComponentId is id
      resultArray.push value
      return

    # Search all the fields in the data.
    for field, child of value
      @_findValuesOfChildrenOfType id, child, resultArray
