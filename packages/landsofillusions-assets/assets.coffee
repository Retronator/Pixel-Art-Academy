LOI = LandsOfIllusions
AB = Artificial.Base

class LOI.Assets
  constructor: ->
    AB.Router.addRoute '/sprite-editor/:spriteId?', @constructor.Layout, @constructor.SpriteEditor
    AB.Router.addRoute '/audio-editor/:audioId?', @constructor.Layout, @constructor.AudioEditor
