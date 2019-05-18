LOI = LandsOfIllusions
AB = Artificial.Base
AM = Artificial.Mummification

class LOI.Assets
  constructor: ->
    AB.Router.addRoute '/sprite-editor', @constructor.Layout, @constructor.SpriteEditor
    AB.Router.addRoute '/mesh-editor', @constructor.Layout, @constructor.MeshEditor
    AB.Router.addRoute '/audio-editor', @constructor.Layout, @constructor.AudioEditor

if Meteor.isServer
  Meteor.startup ->
    # Export assets in the landsofillusions folder.
    for assetClassName in ['Sprite', 'Mesh', 'Audio']
      AM.DatabaseContent.addToExport ->
        LOI.Assets[assetClassName].documents.fetch name: /^landsofillusions/
