LOI = LandsOfIllusions
AB = Artificial.Base
AM = Artificial.Mummification

class LOI.Assets
  @debug = false

  @exportPaths = []

  @addToExport: (path) ->
    @exportPaths.push path

    for assetClassName in ['Sprite', 'Bitmap', 'Mesh', 'Audio']
      do (assetClassName) ->
        AM.DatabaseContent.addToExport ->
          LOI.Assets[assetClassName].documents.fetch name: ///^#{path}///

  constructor: ->
    AB.Router.addRoute '/sprite-editor', @constructor.Layout, @constructor.SpriteEditor
    AB.Router.addRoute '/mesh-editor', @constructor.Layout, @constructor.MeshEditor
    AB.Router.addRoute '/audio-editor', @constructor.Layout, @constructor.AudioEditor
    Artificial.Pages.addAdminPage '/admin/landsofillusions/assets', @constructor.Pages.Admin
    Artificial.Pages.addAdminPage '/admin/landsofillusions/assets/palettes/:documentId?', @constructor.Pages.Admin.Palettes

if Meteor.isServer
  # Export assets in the landsofillusions folder.
  LOI.Assets.addToExport 'landsofillusions'
