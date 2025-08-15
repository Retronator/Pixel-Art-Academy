import {ComputedField} from "meteor/peerlibrary:computed-field"

AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

DesignDocument = PAA.Pico8.Cartridges.Invasion.DesignDocument

class DesignDocument.Entities extends AM.Component
  @id: -> "PixelArtAcademy.Pico8.Cartridges.Invasion.DesignDocument.Entities"
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @designDocument = @parentComponent()
    
    @value = new ComputedField =>
      choice = @data()
      
      if choice.value
        choice.value()
        
      else if choice.property
        @designDocument.getDesignValue choice.property
      
    @addingEntity = new ReactiveField false
    
    @assetClasses = [
      PAA.Pico8.Cartridges.Invasion.Defender
      PAA.Pico8.Cartridges.Invasion.DefenderProjectile
      PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion
      PAA.Pico8.Cartridges.Invasion.Invader
      PAA.Pico8.Cartridges.Invasion.InvaderProjectile
      PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion
      PAA.Pico8.Cartridges.Invasion.Shield
    ]
    
    @projectThing = new ComputedField =>
      @_projectThing?.destroy()
      return unless projectId = @designDocument.projectId()
      @_projectThing = Tracker.nonreactive => new PAA.Pico8.Cartridges.Invasion.Project projectId
      @_projectThing
    
    @_assets = []
    @assets = new ComputedField =>
      entity.destroy() for entity in @_assets
      return unless projectThing = @projectThing()
      
      @_assets = for entityClass in @assetClasses
        Tracker.nonreactive => new entityClass projectThing
        
      @_assets
      
  onDestroyed: ->
    super arguments...
    
    @_projectThing.destroy()
    entity.destroy() for entity in @_assets
  
  canAddEntity: ->
    return unless project = @designDocument.project()
    return unless project.assets
    
    optionalAssetIds = [
      PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion.id()
      PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion.id()
    ]
    
    for asset in project.assets when asset.id not in optionalAssetIds
      return unless bitmap = LOI.Assets.Bitmap.documents.findOne asset.bitmapId
      
      # We know the player has changed the bitmap if the history position is not zero.
      return unless bitmap.historyPosition
    
    return unless @availableEntities().length
    
    true
    
  availableEntities: ->
    return unless project = @designDocument.project()
    assets = @assets()
    
    defender = _.find assets, (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.Defender.id()
    invader = _.find assets, (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.Invader.id()
    defenderProjectile = _.find assets, (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.DefenderProjectile.id()
    invaderProjectile = _.find assets, (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.InvaderProjectile.id()
    shield = _.find assets, (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.Shield.id()
    
    hasDefender = DesignDocument.Options.Entities.Defender in project.design.entities
    hasInvader = DesignDocument.Options.Entities.Invader in project.design.entities
    hasDefenderProjectile = DesignDocument.Options.Entities.DefenderProjectile in project.design.entities
    hasInvaderProjectile = DesignDocument.Options.Entities.InvaderProjectile in project.design.entities
    hasShield = DesignDocument.Options.Entities.Shield in project.design.entities
    
    entities = [
      defender unless hasDefender
      invader unless hasInvader
      defenderProjectile if hasDefender and not hasDefenderProjectile
      invaderProjectile if hasInvader and not hasInvaderProjectile
      shield if (hasDefenderProjectile or hasInvaderProjectile) and not hasShield
    ]
    
    _.without entities, undefined
  
  chosenText: ->
    choice = @data()
    value = @value()
    
    option = _.find choice.options, (option) => value is option.value
    
    unless option
      console.warn "No option found for value", value, choice
      return
      
    option.text
  
  events: ->
    super(arguments...).concat
      'click .add-entity-button': @onClickAddEntityButton
      'click .entity-button': @onClickEntityButton

  onClickAddEntityButton: (event) ->
    @addingEntity true
    
    Tracker.afterFlush =>
      @designDocument.window.scrollToElement @$('.pixelartacademy-pico8-cartridges-invasion-designdocument-entities')[0]
  
  onClickEntityButton: (event) ->
    asset = @currentData()
    assetId = asset.id()
    
    @addingEntity false
    
    entityId = _.last assetId.split '.'
    entities = @designDocument.getDesignValue('entities') or []
    return if entityId in entities
    
    entities.push entityId
    @designDocument.setDesignValue 'entities', entities
    
    @_addAsset asset
    
    # Projectiles also require the explosion assets to be added.
    if assetId is PAA.Pico8.Cartridges.Invasion.DefenderProjectile.id()
      defenderProjectileExplosion = _.find @assets(), (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion.id()
      @_addAsset defenderProjectileExplosion
      
    if assetId is PAA.Pico8.Cartridges.Invasion.InvaderProjectile.id()
      invaderProjectileExplosion = _.find @assets(), (asset) => asset.id() is PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion.id()
      @_addAsset invaderProjectileExplosion
  
  _addAsset: (asset) ->
    assetId = asset.id()
    
    # Create the asset bitmap.
    projectId = @designDocument.projectId()
    
    # Load the asset image.
    imageUrl = asset.constructor.imageUrl()
    
    assetImage = await new Promise (resolve) =>
      image = new Image
      image.addEventListener 'load', =>
        resolve image
      ,
        false
      
      # Initiate the loading.
      image.src = Meteor.absoluteUrl imageUrl
      
    # Load the PICO-8 palette.
    pico8Palette = await new Promise (resolve) =>
      Tracker.autorun (computation) =>
        LOI.Assets.Palette.forName.subscribeContent LOI.Assets.Palette.SystemPaletteNames.Pico8
        return unless palette = LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.SystemPaletteNames.Pico8
        computation.stop()
        resolve palette

    # Create a bitmap out of the image.
    creationTime = new Date
    width = assetImage.width
    height = assetImage.height
    
    bitmapData =
      versioned: true
      profileId: LOI.adventure.profileId()
      creationTime: creationTime
      lastEditTime: creationTime
      name: asset.displayName()
      bounds:
        fixed: true
        left: 0
        right: width - 1
        top: 0
        bottom: height - 1
      pixelFormat: new LOI.Assets.Bitmap.PixelFormat 'flags', 'paletteColor'
      palette:
        _id: pico8Palette._id
        
    layer = new LOI.Assets.Bitmap.Layer bitmapData, bitmapData,
      bounds:
        x: 0
        y: 0
        width: width
        height: height
    layer.importImage assetImage, pico8Palette
    
    bitmapData.layers = [layer.toPlainObject()]
    
    bitmapId = LOI.Assets.Bitmap.documents.insert bitmapData

    # Add the bitmap to the project assets.
    PAA.Practice.Project.documents.update projectId,
      $push:
        assets:
          id: assetId
          type: asset.constructor.type()
          bitmapId: bitmapId
      $set:
        lastEditTime: creationTime
