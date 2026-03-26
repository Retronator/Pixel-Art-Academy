AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Project extends PAA.Practice.Project.Thing
  # activeProjectId: ID of the project that is currently active
  
  # Project document fields
  # playfield: an object with all the pinball parts on the playfield
  #   {playfieldPartId}: a random ID of this part instance
  #     type: the thing id of the pinball part
  #     position: the position of the part on the playfield in meters, (0, 0) is top-left
  #       x, y
  #     rotationAngle: the angle
  #     flipped: boolean whether the part mesh should be mirrored horizontally
  #     ...
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Project'
  
  @fullName: -> "Pinball"

  @iconUrl: -> @versionedUrl "/pixelartacademy/pixeltosh/programs/pinball/icon-project.png"
  @program: -> Pinball

  @initialize()

  constructor: ->
    super arguments...

    @_assets = {}
    @_assetsUpdatedDependency = new Tracker.Dependency()
    
    @autorun (computation) =>
      activeProjectId = PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
      project = PAA.Practice.Project.documents.findOne activeProjectId
      
      for asset in project.assets when not @_assets[asset.id]
        assetClass = PAA.Practice.Project.Asset.getClassForId asset.id
        @_assets[asset.id] = Tracker.nonreactive => new assetClass @
        
      for assetId, asset of @_assets when not _.find project.assets, (projectAsset) => projectAsset.id is assetId
        asset.destroy()
        delete @_assets[assetId]
      
      @_assetsUpdatedDependency.changed()

  destroy: ->
    super arguments...
    
    asset.destroy() for assetId, asset of @_assets
    
  assets: ->
    @_assetsUpdatedDependency.depend()
    _.values @_assets
    
  content: ->
    return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
    chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Pinball
