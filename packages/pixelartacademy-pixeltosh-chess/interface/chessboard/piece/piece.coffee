AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Chessboard.Piece extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Chessboard.Piece'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @bitmapId = new ComputedField =>
      piece = @currentData()
      assetId = Chess.Assets.TwoDimensional[piece.type][piece.color].id()
      
      return unless project = PAA.Practice.Project.documents.findOne Chess.chessSet2D()
      return unless asset = _.find project.assets, (asset) => asset.id is assetId
      
      asset.bitmapId

    @bitmap = new ComputedField =>
      return unless bitmapId = @bitmapId()
      LOI.Assets.Bitmap.versionedDocuments.getDocumentForId bitmapId, false

  bitmapImageOptions: ->
    bitmap: => @bitmap()
    loadPalette: true
