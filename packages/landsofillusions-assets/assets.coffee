LOI = LandsOfIllusions
AB = Artificial.Base
AM = Artificial.Mummification

class LOI.Assets
  @debug = true

  @exportPaths = []

  @addToExport: (path) ->
    @exportPaths.push path

    for assetClassName in ['Sprite', 'Mesh', 'Audio']
      do (assetClassName) ->
        AM.DatabaseContent.addToExport ->
          LOI.Assets[assetClassName].documents.fetch name: ///^#{path}///

  constructor: ->
    AB.Router.addRoute '/sprite-editor', @constructor.Layout, @constructor.SpriteEditor
    AB.Router.addRoute '/mesh-editor', @constructor.Layout, @constructor.MeshEditor
    AB.Router.addRoute '/audio-editor', @constructor.Layout, @constructor.AudioEditor

if Meteor.isServer
  # Add highest priority for importing translations since they're always used from other documents.
  AM.DatabaseContent.setDocumentImportPriority Artificial.Babel.Translation.id(), 100

  # Export assets in the landsofillusions folder.
  LOI.Assets.addToExport 'landsofillusions'
