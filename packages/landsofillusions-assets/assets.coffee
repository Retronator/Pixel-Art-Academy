LOI = LandsOfIllusions
AB = Artificial.Base

class LOI.Assets
  constructor: ->
    AB.addRoute '/sprite-editor/:spriteId?', @constructor.Layout, @constructor.SpriteEditor
