LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
DIY = C1.Goals.PixelArtSoftware.DIY

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.PixelArt extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.PixelArt'

  @location: -> HQ.Store

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/pixelart.script'

  @initialize()

  constructor: ->
    super

    @pixelArtSoftware = new C1.Goals.PixelArtSoftware

    @taskClassNames = [
      'GetReference'
      'CopyReference'
    ]

    @diyTaskClassNames = [
      'Doodling'
      'WatchTutorial'
      'AdvancedTools'
      'Reference'
      'Grid'
    ]

    @taskClasses = []

    for taskClassName in @taskClassNames
      @taskClasses.push
        name: taskClassName
        class: C1.Goals.PixelArtSoftware[taskClassName]

    for taskClassName in @diyTaskClassNames
      @taskClasses.push
        name: taskClassName
        class: DIY[taskClassName]

    taskClassIds = (taskClass.class.id() for taskClass in @taskClasses)

    # We need to know the status of Pixel Art Software related tasks.
    @_taskEntriesSubscription = PAA.Learning.Task.Entry.forCharacterTaskIds.subscribe LOI.characterId(), taskClassIds

  destroy: ->
    super

    @pixelArtSoftware.destroy()
    @_taskEntriesSubscription.stop()

  # Script

  initializeScript: ->
    openWebsite = (url, complete) ->
      website = window.open url, '_blank'
      website.focus()
  
      # Wait for our window to get focus.
      $(window).on 'focus.open-website', =>
        complete()
        $(window).off '.open-website'
        
    @setCurrentThings
      retro: HQ.Actors.Retro

    @setCallbacks
      WatchTutorialPhotoshop: (complete) => openWebsite 'https://www.youtube.com/watch?v=hEGeveEsg0Q', complete
      WatchTutorialGIMP: (complete) => openWebsite 'https://www.youtube.com/watch?v=PONe4IIYSnQ', complete
      WatchTutorialAseprite: (complete) => openWebsite 'https://www.youtube.com/playlist?list=PLPHvHCBMlIQ0FEEh0QM7MZlnVMoRGgUql', complete
      WatchTutorialPyxelEdit: (complete) => openWebsite 'https://www.youtube.com/playlist?list=PLG0tvJ_jRDIXVXKmOFfWtN_I58SaZEDoS', complete

      YouTubeSearch: (complete) =>
        softwareName = @ephemeralState 'externalSoftwareName'
        searchParts = softwareName.split(' ').concat ['pixel', 'art', 'setup']
        openWebsite "https://www.youtube.com/results?search_query=#{searchParts.join '+'}", complete

      Return: (complete) =>
        # Hook back into the Retro's main questions.
        store = LOI.adventure.getCurrentThing HQ.Store
        characterScript = store.getListener(HQ.Store.RetroListener).characterScript
        LOI.adventure.director.startScript characterScript, label: 'MainQuestion'

        complete()

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    scene = @options.parent

    return unless choicePlaceholderResponse.scriptId is HQ.Store.RetroListener.CharacterScript.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestion'

    # Prerequisite is that the player has talked about pixel art software while having the PixelBoy.
    return unless HQ.Actors.Retro.Listener.Script.state 'HavePixelBoy'

    labels = [
      'UsePixelBoyEditorChoice'
      'UseExternalSoftwareChoice'
      'ChosenSoftwareChoice'
      'ChosenOtherSoftwareChoice'
      'ExternalSoftwareTutorialChoice'
      'ExternalSoftwareReminderChoice'
      'WatchTutorialChoice'
      'WatchTutorialChoiceChangeMind'
      'DoodlingQuestion'
      'DoodlingQuestionAgain'
      'AdvancedToolsAndReferencesChoice'
      'ReferencesChoice'
      'GridChoice'
      'BasicsDoneChoice'
    ]

    choicePlaceholderResponse.addChoice @script.startNode.labels[label].next for label in labels

    # We need to know if the player has the drawing app.
    pixelBoy = LOI.adventure.getCurrentThing PAA.PixelBoy
    hasDrawingApp = PAA.PixelBoy.Apps.Drawing in pixelBoy.os.currentAppsSituation().things()
    Tracker.nonreactive => @script.ephemeralState 'hasDrawingApp', hasDrawingApp

    # We want to know if and which software they are using.
    externalSoftware = PAA.PixelBoy.Apps.Drawing.state 'externalSoftware'
    externalSoftwareName = PAA.PixelBoy.Apps.Drawing.Portfolio.ExternalSoftware[externalSoftware]
    Tracker.nonreactive =>
      # Note, we force null instead of undefined to clean up the variable if needed.
      @script.ephemeralState 'externalSoftware', externalSoftware or null
      @script.ephemeralState 'externalSoftwareName', externalSoftwareName or null

    # We need to know which tasks the user has completed.
    completedTasks = {}
    tasks = scene.pixelArtSoftware.tasks()

    for taskClass in scene.taskClasses
      task = _.find tasks, (task) => task instanceof taskClass.class
      completedTasks[taskClass.name] = true if task.completed()

    Tracker.nonreactive =>
      @script.ephemeralState 'completedTasks', completedTasks
