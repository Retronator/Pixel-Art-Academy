AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset
  @Types:
    Sprite: 'Sprite'
    Photo: 'Photo'

  @_assetClassesById = {}

  @getClassForId: (id) ->
    @_assetClassesById[id]

  @getClasses: ->
    _.values @_assetClassesById

  # Id string for this asset used to identify the asset in code.
  @id: -> throw new AE.NotImplementedException "You must specify asset's id."

  # Type of this asset.
  @type: -> throw new AE.NotImplementedException "You must specify asset's type."

  # String to represent the asset in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the asset name."

  # String with more information about what this asset represents.
  @description: -> throw new AE.NotImplementedException "You must specify the asset's description."

  @initialize: ->
    # Store asset class by ID.
    @_assetClassesById[@id()] = @

    # On the server, create this assets's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName', 'description']
