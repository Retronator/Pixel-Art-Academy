AE = Artificial.Everywhere
LOI = LandsOfIllusions
History = LOI.Assets.MeshEditor.Helpers.History

class History.Operation.ClearPixels extends History.Operation
  @operationName: -> 'ClearPixels'
  @initialize()
  
  @generate: (picture, pixels, relative) ->
    new @ {
      pictureAddress: picture.getAddress()
      pixels
      relative
    }
    
  execute: (mesh) ->
    picture = mesh.resolveAddress @data.pictureAddress
    picture.clearPixels @data.pixels, @data.relative
