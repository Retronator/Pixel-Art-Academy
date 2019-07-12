LOI = LandsOfIllusions

class LOI.Engine.Materials.Material extends THREE.ShaderMaterial
  @id: -> throw new AE.NotImplementedException "Material must have an ID."
  id: -> @constructor.id()

  @_materialClassesById = {}

  @getClasses: ->
    _.values @_materialClassesById

  @getIds: ->
    _.keys @_materialClassesById

  @getClassForId: (id) ->
    @_materialClassesById[id]

  @initialize: ->
    # Store material class by ID.
    @_materialClassesById[@id()] = @

  constructor: ->
    super arguments...

    @_dependency = new Tracker.Dependency

  depend: ->
    @_dependency.depend()
