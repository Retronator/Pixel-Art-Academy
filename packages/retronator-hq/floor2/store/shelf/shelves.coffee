AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Shelves extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Store.Shelves'
  @fullName: -> "store shelves"
  @shortName: -> "shelves"
  @descriptiveName: -> "Store ![shelves](look at shelves)."

  @description: ->
    "
      The shelves holding various items sold in the Retronator store.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor2/store/shelf/shelves.script'

  @initialize()

  constructor: ->
    super arguments...

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
