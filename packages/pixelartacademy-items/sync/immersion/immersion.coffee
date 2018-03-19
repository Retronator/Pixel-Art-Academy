AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Sync.Immersion extends PAA.Items.Sync.Tab
  @id: -> 'PixelArtAcademy.Items.Sync.Immersion'
  @register @id()

  @url: -> 'immersion'
  @displayName: -> 'Immersion'
    
  @initialize()

  onCreated: ->
    super
  
    # Subscribe to user's activated characters.
    @_charactersSubscription = LOI.Character.activatedForCurrentUser.subscribe()
  
    @activatedCharacters = new ComputedField =>
      return [] unless user = Retronator.user()
      return [] unless user.characters

      LOI.Character.getInstance character for character in user.characters

    # Which character is shown left-most. Allows to scroll through options.
    @firstCharacterOffset = new ReactiveField 0

    # Listen to changes in number of activated characters, so we can move the offset if needed.
    @autorun (computation) =>
      newIndex = _.clamp @firstCharacterOffset(), 0, @activatedCharacters().length - 2

      Tracker.nonreactive => @firstCharacterOffset newIndex

    @selectedCharacter = new ReactiveField null

    # Listen to changes in activated characters, so we can deselect a character that is not activated anymore.
    @autorun (computation) =>
      selectedCharacter = @selectedCharacter
      activatedCharacters = @activatedCharacters()

      unless selectedCharacter in activatedCharacters
        Tracker.nonreactive => @selectedCharacter null

  linksStyle: ->
    offset = @firstCharacterOffset()

    left: "-#{offset * 75}rem"

  characterActiveClass: ->
    characterInstance = @currentData()

    'active' if LOI.characterId() is characterInstance._id

  landsOfIllusionsActiveClass: ->
    'active' if LOI.adventure.currentLocationId() is LOI.Construct.Loading.id()

  nextButtonVisibleClass: ->
    'visible' if @firstCharacterOffset() < @activatedCharacters().length - 2

  previousButtonVisibleClass: ->
    'visible' if @firstCharacterOffset() > 0

  showDisconnect: ->
    LOI.characterId() or LOI.adventure.currentLocationId() is LOI.Construct.Loading.id()

  events: ->
    super.concat
      'click .character': @onClickCharacter
      'click .lands-of-illusions': @onClickLandsOfIllusions
      'click .disconnect': @onClickDisconnect
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickCharacter: (event) ->
    characterInstance = @currentData()

    LOI.adventure.loadCharacter characterInstance._id

  onClickLandsOfIllusions: (event) ->
    LOI.adventure.loadConstruct()

  onClickDisconnect: (event) ->
    if LOI.characterId()
      LOI.adventure.unloadCharacter()

    else
      LOI.adventure.unloadConstruct()

  onClickPreviousButton: (event) ->
    newIndex = Math.max 0, @firstCharacterOffset() - 1

    @firstCharacterOffset newIndex

  onClickNextButton: (event) ->
    newIndex = Math.min @activatedCharacters().length - 2, @firstCharacterOffset() + 1

    @firstCharacterOffset newIndex
