AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Editor.References.DisplayComponent extends LOI.Assets.Components.References
  @id: -> 'LandsOfIllusions.Assets.Editor.References.DisplayComponent'
  @register @id()

  constructor: ->
    super arguments...

    @draggingDisplayed true

  onCreated: ->
    super arguments...

    @draggingScale = new ComputedField =>
      @options.embeddedTransform().scale
