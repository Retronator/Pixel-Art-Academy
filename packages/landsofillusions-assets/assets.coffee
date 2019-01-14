LOI = LandsOfIllusions
AB = Artificial.Base

class LOI.Assets
  constructor: ->
    AB.Router.addRoute '/sprite-editor', @constructor.Layout, @constructor.SpriteEditor
    AB.Router.addRoute '/mesh-editor', @constructor.Layout, @constructor.MeshEditor
    AB.Router.addRoute '/audio-editor', @constructor.Layout, @constructor.AudioEditor
