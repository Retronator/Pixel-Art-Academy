AM = Artificial.Mirage
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

class Entry.Object.Task.Manual extends Entry.Object.Task.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Task.Manual'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  showConfirmButton: ->
    @ready() and not @task.completed()

  events: ->
    super.concat
      'click .confirm-button': @onClickConfirmButton

  onClickConfirmButton: (event) ->
    PAA.Learning.Task.Entry.insert LOI.characterId(), @parent.task.id()
