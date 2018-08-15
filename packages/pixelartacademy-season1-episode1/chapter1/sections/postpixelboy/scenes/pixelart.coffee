LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.PostPixelBoy.PixelArt extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.PostPixelBoy.PixelArt'

  @location: -> HQ.Store

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/postpixelboy/scenes/pixelart.script'

  @initialize()

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
      AdvancedSetupPhotoshop: (complete) => openWebsite 'https://www.youtube.com/watch?v=hEGeveEsg0Q', complete
      AdvancedSetupGIMP: (complete) => openWebsite 'https://www.youtube.com/watch?v=PONe4IIYSnQ', complete
      AdvancedSetupAseprite: (complete) => openWebsite 'https://www.youtube.com/playlist?list=PLPHvHCBMlIQ0FEEh0QM7MZlnVMoRGgUql', complete
      AdvancedSetupPyxelEdit: (complete) => openWebsite 'https://www.youtube.com/playlist?list=PLG0tvJ_jRDIXVXKmOFfWtN_I58SaZEDoS', complete

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
    return unless choicePlaceholderResponse.scriptId is HQ.Store.RetroListener.CharacterScript.id()
    return unless choicePlaceholderResponse.placeholderId is 'MainQuestion'

    # Prerequisite is that the player has talked about pixel art software before.
    return unless HQ.Actors.Retro.Listener.Script.state 'SoftwareQuestions'

    labels = [
      'UsePixelBoyEditorChoice'
      'UseExternalSoftwareChoice'
      'ChosenSoftwareChoice'
      'ChosenOtherSoftwareChoice'
      'ExternalSoftwareTutorialChoice'
      'ExternalSoftwareReminderChoice'
      'AdvancedToolsAndReferencesChoice'
      'ReferencesChoice'
      'GridChoice'
      'BasicsDoneChoice'
      'AdvancedSetupChoice'
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
      @script.ephemeralState 'externalSoftware', externalSoftware
      @script.ephemeralState 'externalSoftwareName', externalSoftwareName
