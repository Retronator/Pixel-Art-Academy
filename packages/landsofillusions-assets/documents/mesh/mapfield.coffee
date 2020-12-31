AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.MapField
  constructor: (@parent, @field, @map, @contentClass) ->
    @_updatedDependency = new Tracker.Dependency
    @_mapChangedDependency = new Tracker.Dependency
    
    if @contentClass and @map
      # Make rich objects.
      @map[id] = new @contentClass @, id, data for id, data of @map when data

    @_itemFields = {}

  save: (saveData) ->
    if @map
      map = _.clone @map

      if @contentClass
        map[id] = item?.toPlainObject() for id, item of map

      saveData[@field] = map

  getAll: ->
    @_updatedDependency.depend()
    @_getAll()
    
  getAllWithoutUpdates: ->
    @_mapChangedDependency.depend()
    @_getAll()

  _getAll: ->
    _.pickBy @map, (item) => item?

  get: (id) ->
    @_mapChangedDependency.depend()
    return unless @map
    return unless item = @map[id]

    item.depend?()
    item

  insert: (id, data = {}) ->
    @map ?= {}
    
    if @contentClass
      @map[id] = new @contentClass @, id, data
      
    else
      @map[id] = data

    @contentUpdated()
    @_mapChangedDependency.changed()

    # Return id of the new item.
    id

  remove: (id) ->
    delete @map[id]

    @contentUpdated()
    @_mapChangedDependency.changed()

  clear: ->
    @map = {}

    @contentUpdated()
    @_mapChangedDependency.changed()

  contentUpdated: ->
    @_updatedDependency.changed()
    @parent.contentUpdated()
