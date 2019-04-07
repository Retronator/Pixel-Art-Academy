AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.ArrayField
  constructor: (@parent, @field, @array, @contentClass) ->
    @_updatedDependency = new Tracker.Dependency
    @_arrayChangedDependency = new Tracker.Dependency
    
    if @contentClass and @array
      # Make rich objects.
      @array = _.clone @array

      for data, index in @array when data
        @array[index] = new @contentClass @, index, data

    @_itemFields = {}

  save: (saveData) ->
    if @array
      array = _.clone @array

      if @contentClass
        array[index] = item?.toPlainObject() for item, index in array

      saveData[@field] = array

  getAll: ->
    @_updatedDependency.depend()
    @_getAll()
    
  getAllWithoutUpdates: ->
    @_arrayChangedDependency.depend()
    @_getAll()
    
  _getAll: ->
    _.without @array, undefined, null

  getFirst: ->
    @_arrayChangedDependency.depend()
    return unless @array

    # Find first existing item and retrieve it.
    for item, index in @array when item
      return @get index

    null

  get: (index) ->
    @_arrayChangedDependency.depend()
    return unless @array
    return unless item = @array[index]

    item.depend?()
    item

  find: (query) ->
    itemIndex = _.findIndex @array, (item) =>
      return unless item

      # See if all fields of the query match this item.
      for key, value of query
        return unless _.propertyValue(item, key) is value

      true

    @get itemIndex

  insert: (data = {}, index) ->
    index ?= @array?.length or 0
    @array ?= []
    
    if @contentClass
      @array[index] = new @contentClass @, index, data
      
    else
      @array[index] = data

    @contentUpdated()
    @_arrayChangedDependency.changed()

    # Return index of the new item.
    index

  remove: (index, splice) ->
    if splice
      # We remove the item with splice. This is only OK for arrays that are never referenced by index.
      @array.splice index, 1
      
    else
      # We just clear the position in the array.
      @array[index] = null

    @contentUpdated()
    @_arrayChangedDependency.changed()

  clear: ->
    @array = []

    @contentUpdated()
    @_arrayChangedDependency.changed()

  contentUpdated: ->
    @_updatedDependency.changed()
    @parent.contentUpdated()
