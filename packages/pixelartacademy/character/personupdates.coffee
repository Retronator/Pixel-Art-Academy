AB = Artificial.Babel
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
            return if @_options.readyField and not @_options.readyField()
            computation.stop()

            # We've now got all documents we need to carry out this conversation.
            # Find the actions this person made since earliest time.
            actions = @_options.person.recentActions true
            tasks = @_options.person.recentTaskEntries()

            updates = [actions..., tasks...]
            updates = _.sortBy updates, (update) => update.time.getTime()

            for update, index in updates when update.type
              updates[index] = update.cast()

            # Apply update filters
            relevantUpdateClasses = @_options.relevantUpdateClasses or [
              PAA.Practice.Journal.Entry.Action
              LOI.Memory.Actions.Say
              PAA.Learning.Task.Entry
            ]

            _.remove updates, (action) -> action.constructor not in relevantUpdateClasses

            relevantUpdatesCount = 0
            knownUpdatesCount = 0

            # Journal entries
            journalEntries =
              entries: []

            @ephemeralState 'journalEntries', journalEntries

            for update in updates when update instanceof PAA.Practice.Journal.Entry.Action
              relevantUpdatesCount++
              
              journalEntries.entries.push
                # Note: journalEntry is wrapped in an array since it's a reverse field.
                entry: update.content.journalEntry[0]

            # Learning tasks
            learningTasks =
              tasks: []
              goals: []

            @ephemeralState 'learningTasks', learningTasks

            for update in updates when update instanceof PAA.Learning.Task.Entry
              relevantUpdatesCount++

              continue unless task = PAA.Learning.Task.getAdventureInstanceForId update.taskId

              goal = _.find learningTasks.goals, (goal) => goal.id is task.goal.id()

              unless goal
                goal =
                  id: task.goal.id()
                  displayName: "'#{task.goal.displayName()}'"

                learningTasks.goals.push goal

              learningTasks.tasks.push
                directive: "'#{task.directive()}'"
                goal: goal

            learningTasks.taskDirectives = AB.Rules.English.createNounSeries (task.directive for task in learningTasks.tasks)
            learningTasks.goalNames = AB.Rules.English.createNounSeries (goal.displayName for goal in learningTasks.goals)

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

            # We only need to add each conversation once so we keep track of processed memories.
            processedMemoryIds = []

            for update in updates when update instanceof LOI.Memory.Actions.Say
              continue if update.memory._id in processedMemoryIds
              processedMemoryIds.push update.memory._id

              relevantUpdatesCount++

              # Figure out the participants.
              memory = LOI.Memory.documents.findOne update.memory._id

              unless memory
                console.warn "Memory was not found."
                continue

              characters = (update.character for update in memory.actions)
              characters = _.uniqBy characters, '_id'

              # Don't include the person itself.
              _.remove characters, (character) => character._id is @_options.person._id

              # Skip conversations where the player character is already part of.
              if (_.find characters, (character) => character._id is LOI.characterId())
                knownUpdatesCount++
                continue

              participants = (summarizeCharacter character for character in characters)

              conversation =
                participants: participants
                memoryId: memory._id

              # See what this conversation is about.
              if memory.journalEntry
                # This is a conversation about someone's journal entry.
                author = memory.journalEntry[0].journal.character

                # Skip conversations where the player character is the author.
                if author._id is LOI.characterId()
                  knownUpdatesCount++
                  continue

                conversation.journalEntry =
                  own: author._id is @_options.person._id
                  author: summarizeCharacter author

                journalEntryConversations.conversations.push conversation

              else
                # This is a plain conversation. In these skip the ones where the person was the only participant.
                unless characters.length
                  # Don't even count such conversations.
                  relevantUpdatesCount--
                  continue

                plainConversations.conversations.push conversation

            @ephemeralState 'relevantUpdatesCount', relevantUpdatesCount
            @ephemeralState 'knownUpdatesCount', knownUpdatesCount

            complete()

        ReadFirstJournalEntry: (complete) =>
          journalEntries = @ephemeralState 'journalEntries'

          journalEntry = journalEntries.entries[0].entry

          # Create the journal view context for this entry's journal
          context = new PAA.PixelBoy.Apps.Journal.JournalView.Context
            journalId: journalEntry.journal._id
            entryId: journalEntry._id

          # Pause current callback node so context interactions can execute.
          LOI.adventure.director.pauseCurrentNode()

          LOI.adventure.enterContext context

          # Add a hint to interact with the journal.
          Meteor.setTimeout =>
            LOI.adventure.director.startScript @, label: 'JournalEntryHint'
          ,
            100

          # Wait until the context is closed.
          Tracker.autorun (computation) =>
            return if LOI.adventure.currentContext()
            computation.stop()

            complete()

        GoOverJournalEntryConversations: (complete) =>
          @options.listener._goOverConversations complete, 'journalEntryConversations', hintLabel: 'JournalEntryHint'

        GoOverConversations: (complete) =>
          @options.listener._goOverConversations complete, 'plainConversations', hintLabel: 'ConversationHint'

        NextConversation: => # Dummy callback as it will be set from GoOverConversations.

        EndUpdate: (complete) =>
          @_options.endUpdateCallback?()

          complete()

  _goOverConversations: (complete, conversationsFieldName, hintLabel) ->
    conversationsToGoOver = _.clone @script.ephemeralState(conversationsFieldName).conversations

    # Pause current callback node so context interactions can execute.
    LOI.adventure.director.pauseCurrentNode()

    handleNextConversation = =>
      # Enter the next conversation.
      conversation = conversationsToGoOver.shift()
      LOI.adventure.enterMemory conversation.memoryId

      # Show the hint for conversation interaction.
      Meteor.setTimeout =>
        LOI.adventure.director.startScript @script, label: hintLabel
      ,
        100

      # Wait until the context is closed.
      Tracker.autorun (computation) =>
        return if LOI.adventure.currentMemoryId()
        computation.stop()

        # Give adventure the chance to recompute timeline and location (since those will clean up script nodes).
        Tracker.afterFlush =>
          # See if we have any conversations left.
          if conversationsToGoOver.length
            LOI.adventure.director.startScript @script, label: 'NextConversation'

          else
            # We're done!
            complete()

    # Set next conversation callback.
    @script.setCallbacks
      NextConversation: (complete) =>
        complete()

        # Handle remaining conversations.
        handleNextConversation()

    # Start the handling.
    handleNextConversation()

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
    
    # Set if we're doing just the update or just follow up.
    @script.ephemeralState 'justUpdate', options.justUpdate is true
    @script.ephemeralState 'justFollowUp', options.justFollowUp is true

    @script
