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
    tag: 'div'
    class: 'pixelartacademy-pixelboy-apps-journal-journalview-entry-object-timestamp'

  onCreated: ->
    super

    value = @value()

    # Display current time if not specified.
    unless value.time
      time = new Date()
      timezoneOffset = time.getTimezoneOffset()

      @value {time, timezoneOffset}

    format = @format()

    # Use current language if not specified.
    unless format.language
      format.language = AB.currentLanguage()
      @format format

  timestamp: ->
    return unless @isRendered()
    
    value = @value()
    format = @format()

    # We want to show the same date/hour as it was visible for the author when they made the entry.
    # For that we need to offset the time by the difference between the current timezone and the original one.
    currentTimezoneOffset = value.time.getTimezoneOffset()
    timezoneDifference = currentTimezoneOffset - value.timezoneOffset

    time = new Date value.time.getTime() + timezoneDifference * 60 * 1000

    time.toLocaleString format.language,
      month: 'long'
      day: 'numeric'
      year: 'numeric'
      hour: 'numeric'
