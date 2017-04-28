AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Shelves extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Store.Shelves'
  @fullName: -> "shelves"

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor2/store/shelf/shelves.script'

  @initialize()

  constructor: ->
    super

  # This is a listener-only object.
  isVisible: -> false

  # Script
  
  initializeScript: ->
    @setCallbacks
      GoToShelf: (complete) =>
        shelf = @ephemeralState().shelf
        LOI.adventure.goToItem HQ.Store.Shelf[shelf]
        complete()
        
  # Listener

  onCommand: (commandResponse) ->
    shelves = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], shelves.avatar]
      priority: 1
      action: =>
        @startScript()
