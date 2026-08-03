FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Helpers.LastCoordinates extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.LastCoordinates'
  @initialize()

  constructor: ->
    super arguments...

    @_coordinatesHistory = []
    @_updatedDependency = new Tracker.Dependency
    @_lastAssetId = null

    @_assetData = new ComputedField => @interface.getEditorForActiveFile()?.assetData?()
    @_assetId = new ComputedField => @_assetData()?._id
    @_historyPosition = new ComputedField => @_assetData()?.historyPosition or 0

    @autorun (computation) =>
      assetId = @_assetId()
      @_historyPosition()

      unless EJSON.equals assetId, @_lastAssetId
        @_lastAssetId = assetId
        @_coordinatesHistory = []
      
      @_updatedDependency.changed()

  value: (coordinates) ->
    if coordinates isnt undefined
      # Since the setter is called right after history position changes, we directly fetch the latest asset data.
      historyPosition = Tracker.nonreactive => @interface.getEditorForActiveFile()?.assetData?().historyPosition or 0
      @_coordinatesHistory.splice historyPosition + 1
      @_coordinatesHistory[historyPosition] = _.clone coordinates
      @_updatedDependency.changed()
      return
    
    @_updatedDependency.depend()
    @_coordinatesHistory[@_historyPosition()]
