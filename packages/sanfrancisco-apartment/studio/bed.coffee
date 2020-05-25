LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

Vocabulary = LOI.Parser.Vocabulary

class Studio.Bed extends LOI.Adventure.Thing
  @id: -> 'SanFrancisco.Apartment.Studio.Bed'

  @fullName: -> "bed"
  @descriptiveName: -> "Comfy ![bed](look at bed)."
  @description: ->
    "
      It's _char's_ bed. You can ![sleep](sleep) in it to skip to the next day.
    "

  @initialize()

  @defaultScriptUrl: -> 'retronator_sanfrancisco-apartment/studio/bed.script'

  # Script

  initializeScript: ->
    bed = @options.parent

    @setCallbacks
      EndDay: (complete) =>
        LOI.adventure.endDay()
        complete()

  # Listener

  onCommand: (commandResponse) ->
    bed = @options.parent

    sleepAction = =>
      @startScript label: 'Sleep'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, bed]
      action: sleepAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Sleep]
      action: sleepAction
