AM = Artificial.Mirage
PAA = PixelArtAcademy
Entry = PAA.PixelPad.Apps.Journal.JournalView.Entry

class Entry.Object.Task.Manual extends Entry.Object.Task.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Journal.JournalView.Entry.Object.Task.Manual'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  events: ->
    super(arguments...).concat
      'click .enabled.confirmation': @onClickConfirmation

  onClickConfirmation: (event) ->
    PAA.Learning.Task.Entry.insert LOI.characterId(), LOI.adventure.currentSituationParameters(), @parent.task.id()
