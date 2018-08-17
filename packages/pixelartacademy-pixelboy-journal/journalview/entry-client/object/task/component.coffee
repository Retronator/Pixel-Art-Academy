AM = Artificial.Mirage
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry
IL = Illustrapedia

class Entry.Object.Task.Component extends AM.Component
  constructor: (@parent) ->
    super

    @task = @parent.task

  ready: ->
    @parent.ready()
