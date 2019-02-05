AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.ArrayField
  constructor: (@parent, @field, @array, @contentClass) ->
    @_updatedDependency = new Tracker.Dependency
    @_arrayChangedDependency = new Tracker.Dependency
    
    if @contentClass and @array
      # Make rich objects.
      @array[index] = new @contentClass @, index, data for data, index in @array when data

    @_itemFields = {}

  save: (saveData) ->
    if @array
      array = _.clone @array

      if @contentClass
        array[index] = item?.toPlainObject() for item, index in array

      saveData[@field] = array

  getAll: ->
    @_updatedDependency.depend()
    _.without @array, undefined, null
    
  getAllWithoutUpdates: ->
    @_arrayChangedDependency.depend()
    _.without @array, undefined, null

  get: (index) ->
    @_arrayChangedDependency.depend()
    return unless @array
    return unless item = @array[index]

    item.depend?()
    item

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

  contentUpdated: ->
    @_updatedDependency.changed()
    @parent.contentUpdated()
