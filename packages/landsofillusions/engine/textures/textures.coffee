LOI = LandsOfIllusions

class LOI.Engine.Textures
  @getTextures: (options) ->
    if options.spriteId
      LOI.Engine.Textures.Sprite.getTextures options

    else if options.spriteName
      if _.endsWith options.spriteName, '.mip'
        LOI.Engine.Textures.Mip.getTextures options

      else
        LOI.Engine.Textures.Sprite.getTextures options
