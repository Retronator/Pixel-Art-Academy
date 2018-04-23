AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

Quill = require 'quill'
BlockEmbed = Quill.import 'blots/block/embed'

class Entry.Object.Timestamp extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Timestamp'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'timestamp'
    tag: 'p'
    class: 'pixelartacademy-pixelboy-apps-journal-journalview-entry-object-timestamp'

  timestamp: ->
    return unless @isRendered()
    
    value = @value()
    formats = @formats()

    # We want to show the same date/hour as it was visible for the author when they made the entry.
    # For that we need to offset the time by the difference between the current timezone and the original one.
    currentTimezoneOffset = value.time.getTimezoneOffset()
    timezoneDifference = currentTimezoneOffset - value.timezoneOffset

    time = new Date value.time.getTime() + timezoneDifference * 60 * 1000

    language = formats.language or 'en-US'

    time.toLocaleString language,
      month: 'long'
      day: 'numeric'
      year: 'numeric'
      hour: 'numeric'
