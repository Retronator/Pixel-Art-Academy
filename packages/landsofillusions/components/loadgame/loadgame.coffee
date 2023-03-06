AB = Artificial.Babel
AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Components.LoadGame extends AM.Component
  @id: -> 'LandsOfIllusions.Components.LoadGame'
  @register @id()

  @url: -> 'loadgame'
  
  @version: -> '0.0.1'
  
  constructor: (@options) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable()
  
  onCreated: ->
    super arguments...

  linksStyle: ->
    offset = @firstCharacterOffset()

    left: "-#{offset * 75}rem"

  characterActiveClass: ->
    characterInstance = @currentData()

    'active' if LOI.characterId() is characterInstance._id

  avatarPreviewOptions: ->
    characterInstance = Template.parentData()
    character = characterInstance.document()

    previewOptions =
      rendererOptions:
        renderingSides: [LOI.Engine.RenderingSides.Keys.Front]

    # Draw characters with revoked design in silhouette.
    unless character?.designApproved
      previewOptions.silhouette =
        ramp: LOI.Assets.Palette.Atari2600.hues.cyan
        shade: 2

    previewOptions

  landsOfIllusionsActiveClass: ->
    'active' if LOI.adventure.currentTimelineId() is LOI.TimelineIds.Construct

  nextButtonVisibleClass: ->
    # We need to accommodate Lands of Illusions and Disconnect links.
    extraOptionsCount = if @showDisconnect() then 1 else 2
    'visible' if @firstCharacterOffset() < @activatedCharacters().length - 1 - extraOptionsCount

  previousButtonVisibleClass: ->
    'visible' if @firstCharacterOffset() > 0

  showDisconnect: ->
    LOI.characterId() or LOI.adventure.currentLocationId() is LOI.Construct.Loading.id()

  events: ->
    super(arguments...).concat
      'click .character': @onClickCharacter
      'click .lands-of-illusions': @onClickLandsOfIllusions
      'click .disconnect': @onClickDisconnect
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickCharacter: (event) ->
    characterInstance = @currentData()
    character = characterInstance.document()

    unless character.designApproved
      LOI.adventure.showActivatableModalDialog
        dialog: new LOI.Components.Dialog
          message: "Character unavailable"
          moreInfo: "#{AB.Rules.English.createPossessive characterInstance.name()} design has been revoked. Please visit Cyborg Construction Center to redesign the character."
          buttons: [
            text: "OK"
          ]

      return

    @sync.fadeToWhite()

    Meteor.setTimeout =>
      LOI.adventure.loadCharacter characterInstance._id

      @sync.close()
    ,
      1000
    
  onClickLandsOfIllusions: (event) ->
    # Don't go into construct if already there.
    return if @landsOfIllusionsActiveClass()
    
    @sync.fadeToWhite()

    Meteor.setTimeout =>
      LOI.adventure.loadConstruct()

      @sync.close()
    ,
      1000

  onClickDisconnect: (event) ->
    @sync.fadeToWhite()

    Meteor.setTimeout =>
      if LOI.characterId()
        LOI.adventure.unloadCharacter()

      else
        LOI.adventure.unloadConstruct()

      @sync.close()
    ,
      1000

  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstCharacterOffset() - 1

    @firstCharacterOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @activatedCharacters().length - 2, @firstCharacterOffset() + 1

    @firstCharacterOffset newIndex
