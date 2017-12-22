LOI = LandsOfIllusions
AB = Artificial.Base

class LOI.Assets
  constructor: ->
    AB.Router.addRoute '/sprite-editor/:spriteId?', @constructor.Layout, @constructor.SpriteEditor
