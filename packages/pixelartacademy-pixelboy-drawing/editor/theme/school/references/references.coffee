AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School.References extends LOI.Assets.Components.References
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.References'
  @register @id()

  onCreated: ->
    super

    @opened = new ReactiveField false

  styleClasses: ->
    classes = [
      'opened' if @opened()
    ]

    _.without(classes, undefined).join ' '
    
  events: ->
    super.concat
      'click .stored-references': @onClickStoredReferences

  onClickStoredReferences: (event) ->
    @opened not @opened()
