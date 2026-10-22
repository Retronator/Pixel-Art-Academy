AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.Project.AssetsProvider extends PAA.Practice.Project.AssetsProvider
  constructor: ->
    super arguments...

    @_designDocumentAsset = Tracker.nonreactive => new PAA.Pico8.Cartridges.Invasion.DesignDocument.Asset @

  destroy: ->
    super arguments...
    
    @_designDocumentAsset.destroy()
    
  assets: -> [super(arguments)..., @_designDocumentAsset]
