AE = Artificial.Everywhere
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  
  # Project document fields
  # design: the design options
  #   theme: a theme ID used to provide references
  #   [entities]: an array of entity IDs added to the game
  #   defender:
  #     movement: whether the defender moves horizontally, vertically, or in all 4 directions
  #     startingAlignment: where does the defender appear
  #       horizontal, vertical
  # designDocument: data related to the display of the design document
  #   [writtenUnits]: an array of unit IDs that have already been written
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Project'
  
  @fullName: -> "Invasion game"

  @initialize()

  constructor: ->
    super arguments...
    
    @pico8Cartridge = new PAA.Pico8.Cartridges.Invasion

    @_assets = {}
    @_assetsUpdatedDependency = new Tracker.Dependency()
    
    @autorun (computation) =>
      return unless activeProjectId = PAA.Pico8.Cartridges.Invasion.Project.state 'activeProjectId'
      return unless project = PAA.Practice.Project.documents.findOne activeProjectId
      
      for asset in project.assets when not @_assets[asset.id]
        assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
        @_assets[asset.id] = Tracker.nonreactive => new assetClass @
        
      for assetId, asset of @_assets when not _.find project.assets, (projectAsset) => projectAsset.id is assetId
        asset.destroy()
        delete @_assets[assetId]
      
      @_assetsUpdatedDependency.changed()

  destroy: ->
    super arguments...
    
    @pico8Cartridge.destroy()

    asset.destroy() for assetId, asset of @_assets
    
  assets: ->
    @_assetsUpdatedDependency.depend()
    _.values @_assets
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter LM.Design.Fundamentals
    chapter.getContent LM.Design.Fundamentals.Content.Projects.Invasion
