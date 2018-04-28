LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PersonUpdates extends LOI.Adventure.Listener
  @id: -> "PixelArtAcademy.PersonUpdates"

  @scriptUrls: -> [
    'retronator_pixelartacademy/character/personupdates.script'
  ]
  
  class @Script extends LOI.Adventure.Script
    @id: -> "PixelArtAcademy.PersonUpdates"
    @initialize()
  
    initialize: ->
      @setCallbacks
        WaitToLoad: (complete) =>
          Tracker.autorun (computation) =>
            return if @_options.ready and not @_options.ready()
            computation.stop()

            # We've now got all documents we need to carry out this conversation.
            # Find the actions this person made since earliest time.
            actions = @_options.person.recentActions @_options.earliestTime
            actions = (action.cast() for action in actions)

            relevantActionsCount = 0
            knownActionsCount = 0

            # Journal entries
            journalEntries =
              entries: []

            @ephemeralState 'journalEntries', journalEntries

            for action in actions when action instanceof PAA.Practice.Journal.Entry.Action
              relevantActionsCount++
              
              journalEntries.entries.push
                entry: action.content.journalEntry

            # Conversations
            createConversations = => conversations: []

            summarizeCharacter = (character) =>
              name: if character._id is LOI.characterId() then "you" else character.avatar.fullName.translate().text

            journalEntryConversations = createConversations()
            plainConversations = createConversations()
            dailyConversations = createConversations()

            @ephemeralState 'journalEntryConversations', journalEntryConversations
            @ephemeralState 'plainConversations', plainConversations
            @ephemeralState 'dailyConversations', dailyConversations

            for action in actions when action instanceof LOI.Memory.Actions.Say
              relevantActionsCount++

              # Figure out the participants.
              memory = LOI.Memory.documents.findOne action.memory._id

              unless memory
                console.warn "Memory was not found."
                continue

              characters = (action.character for action in memory.actions)
              characters = _.uniqBy characters, '_id'

              # Don't include the person itself.
              _.remove characters, (character) => character._id is @_options.person._id

              # Skip conversations where the player character is already part of.
              if (_.find characters, (character) => character._id is LOI.characterId())
                knownActionsCount++
                continue

              participants = (summarizeCharacter character for character in characters)

              conversation =
                participants: participants

              # See what this conversation is about.
              if memory.journalEntry
                # This is a conversation about someone's journal entry.
                author = memory.journalEntry[0].journal.character

                # Skip conversations where the player character is the author.
                if author._id is LOI.characterId()
                  knownActionsCount++
                  continue

                conversation.journalEntry =
                  own: author._id is @_options.person._id
                  author: summarizeCharacter author

                journalEntryConversations.conversations.push conversation

              else
                # This is a plain conversation.
                plainConversations.conversations.push conversation

            @ephemeralState 'relevantActionsCount', relevantActionsCount
            @ephemeralState 'knownActionsCount', knownActionsCount

            complete()
          
  @initialize()

  onScriptsLoaded: ->
    @script = @scripts[@constructor.Script.id()]

  getScript: (options) ->
    # Set person.
    @script.setThings person: options.person

    # Set the node we should transition back to after this script is done.
    @script.startNode.labels.End.next = options.nextNode

    # Save the options to script as we need them when constructing the data once the documents are ready.
    @script._options = options

    @script
