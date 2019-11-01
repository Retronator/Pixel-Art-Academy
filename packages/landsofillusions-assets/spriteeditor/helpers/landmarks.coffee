LOI = LandsOfIllusions
FM = FataMorgana

class LOI.Assets.SpriteEditor.Helpers.Landmarks extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Helpers.Landmarks'
  @initialize()
    
  constructor: ->
    super arguments...

    @sprite = new ComputedField =>
      @interface.getEditorForActiveFile()?.spriteData()

    @landmarks = new ComputedField =>
      sprite = @sprite()
      return unless sprite?.landmarks

      for landmark, index in sprite.landmarks
        # Add index to named color data.
        _.extend {}, landmark,
          index: index
          number: index + 1
          
  value: ->
    @landmarks()
