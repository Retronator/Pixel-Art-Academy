LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Marker extends LOI.Adventure.Thing
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Marker'
  @register @id()

  @fullName: -> "marker"

  @description: ->
    "
      It's good for writing in big letters.
    "

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/mixer/items/marker.script'

  @initialize()

  displayInLocation: -> false

  # Listener
  
  @avatars: ->
    sticker: C1.Mixer.Sticker
    stickers: C1.Mixer.Stickers
    nameTag: C1.Mixer.NameTag

  onCommand: (commandResponse) ->
    return unless marker = LOI.adventure.getCurrentThing C1.Mixer.Marker

    # See if we have the marker in inventory.
    if LOI.adventure.getCurrentInventoryThing C1.Mixer.Marker
      # See if we have stickers in inventory.
      if LOI.adventure.getCurrentInventoryThing C1.Mixer.Stickers
        # See if we have a name tag in inventory.
        if LOI.adventure.getCurrentInventoryThing C1.Mixer.NameTag
          nameTagAction = => @startScript label: 'AlreadyHasNameTag'

        else
          nameTagAction = => @startScript label: 'MakeNameTag'

      else
        # We don't have stickers.
        nameTagAction = => @startScript label: 'StickersNotInInventory'

    else
      # We don't have the marker.
      nameTagAction = => @startScript label: 'MarkerNotInInventory'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, marker]
      action: nameTagAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, [@avatars.sticker, @avatars.stickers]]
      action: nameTagAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.UseWith, marker, [@avatars.sticker, @avatars.stickers]]
      action: nameTagAction

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Create, Vocabulary.Keys.Verbs.Write], @avatars.nameTag]
      action: nameTagAction
