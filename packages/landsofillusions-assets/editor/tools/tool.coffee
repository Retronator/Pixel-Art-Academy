AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Tools.Tool extends FM.Tool
  @icon: -> "/landsofillusions/assets/editor/tools/#{_.kebabCase @displayName()}.png"

  constructor: ->
    super arguments...

    @editor = new ComputedField =>
      @interface.getEditorForActiveFile()
    ,
      (a, b) => a is b
