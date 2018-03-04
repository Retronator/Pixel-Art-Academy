AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

Quill = require 'quill'
BlockEmbed = Quill.import 'blots/block/embed'

class Entry.Object.EntryTime extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.EntryTime'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  onCreated: ->
    super

    @entryComponent = @ancestorComponentOfType PAA.PixelBoy.Apps.Journal.JournalView.Entry
    @format = new ReactiveField {}

  entryTime: ->
    entry = @entryComponent.entry()
    time = entry?.time or new Date()

    if entry
      # We want to show the same date/hour as it was visible for the author when they made the entry.
      # For that we need to offset the time by the difference between the current timezone and the original one.
      currentTimezoneOffset = time.getTimezoneOffset()
      timezoneDifference = currentTimezoneOffset - entry.timezoneOffset

      time = new Date time.getTime() + timezoneDifference * 60 * 1000

    language = entry?.language or AB.currentLanguage()
    time.toLocaleString language,
      month: 'long'
      day: 'numeric'
      year: 'numeric'
      hour: 'numeric'

  @registerBlot 'entryTime'
