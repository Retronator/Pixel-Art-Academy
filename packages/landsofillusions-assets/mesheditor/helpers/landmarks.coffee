LOI = LandsOfIllusions
FM = FataMorgana

class LOI.Assets.MeshEditor.Helpers.Landmarks extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.Landmarks'
  @initialize()
    
  constructor: ->
    super arguments...

    @asset = new ComputedField =>
      LOI.Assets.Mesh.documents.findOne @fileId,
        fields:
          landmarks: 1

    @landmarks = new ComputedField =>
      asset = @asset()
      return unless asset?.landmarks

      for landmark, index in asset.landmarks
        # Add index to named color data.
        _.extend {}, landmark,
          index: index
          number: index + 1
          
  value: ->
    @landmarks()
