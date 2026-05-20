AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Project extends PAA.Practice.Project.Thing
  # Project document fields
  # interfaceTheme: enum, which theme to display the program interface in when this project is active
  # chessboardTheme: enum, which theme to display the chessboard in when this project is active
  @program: -> Chess

  constructor: ->
    super arguments...

    @_assets = {}
    @_assetsUpdatedDependency = new Tracker.Dependency()
    
    @autorun (computation) =>
      activeProjectId = @constructor.state 'activeProjectId'
      project = PAA.Practice.Project.documents.findOne activeProjectId
      return unless project
      
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
    
  class @TwoDimensional extends Project
    # activeProjectId: ID of the project that is currently active
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Project'
    
    @fullName: -> "Chess 2D"
  
    @initialize()

    content: ->
      return unless chapter = LOI.adventure.getCurrentChapter PAA.LearnMode.PixelArtFundamentals.Fundamentals
      chapter.getContent PAA.LearnMode.PixelArtFundamentals.Fundamentals.Content.Projects.Chess.TwoDimensional
