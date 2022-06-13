AE = Artificial.Everywhere
LOI = LandsOfIllusions
History = LOI.Assets.MeshEditor.Helpers.History

class History.Operation.SetPixels extends History.Operation
  @operationName: -> 'SetPixels'
  @initialize()
  
  @generate: (picture, pixels, relative) ->
    new @ {
      pictureAddress: picture.getAddress()
      pixels
      relative
    }
    
  execute: (mesh) ->
    picture = mesh.resolveAddress @data.pictureAddress
    picture.setPixels @data.pixels, @data.relative
