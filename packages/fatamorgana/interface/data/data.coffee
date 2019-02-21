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

  findChildOfType: (classOrId) ->
    id = classOrId?.id() or classOrId
    value = @value()

    # We have found the child if we have a type or contentComponentId that matches.
    return @ if value.type is id or value.contentComponentId is id

    # Search all the fields in the data.
    for field of value
      result = @child(field).findChildOfType id
      return result if result

    # We could not find the data position of this type.
    null
