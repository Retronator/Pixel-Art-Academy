AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset
  @Types:
    None: 'None'
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
  
  # Component to represent the asset in the portfolio.
  @portfolioComponentClass: -> throw new AE.NotImplementedException "You must specify the portfolio component class."
  
  # Component to show for the asset on the clipboard.
  @clipboardComponentClass: -> throw new AE.NotImplementedException "You must specify the clipboard component class."
  
  @initialize: ->
    # Store asset class by ID.
    @_assetClassesById[@id()] = @

    # On the server, create this assets's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName', 'description']

  constructor: (@project) ->
    # Subscribe to this asset's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace

    @data = new ComputedField =>
      return unless assets = @project.assetsData()
      _.find assets, (asset) => asset.id is @id()
    ,
      true
  
    portfolioComponentClass = @constructor.portfolioComponentClass()
    @portfolioComponent = new portfolioComponentClass @
    
    clipboardComponentClass = @constructor.clipboardComponentClass()
    @clipboardComponent = new clipboardComponentClass @
    
  destroy: ->
    @_translationSubscription.stop()
    @data.stop()

  id: -> @constructor.id()
  
  urlParameter: -> throw new AE.NotImplementedException "You must provide the parameter to used in the URL to identify this asset."

  ready: -> throw new AE.NotImplementedException "You must report when all asset's information is ready to be used."

  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'

  description: -> AB.translate(@_translationSubscription, 'description').text
  descriptionTranslation: -> AB.translation @_translationSubscription, 'description'

  styleClasses: -> '' # Override to provide a string with class names for styling the asset.

  editorStyleClasses: -> '' # Override to provide a string with class names for styling the surrounding editor.

  editorOptions: -> null # Override to provide an object that is sent to the editor and relevant components.
