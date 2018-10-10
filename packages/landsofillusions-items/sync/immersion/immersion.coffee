AC = Artificial.Control
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Items.Sync.Immersion extends LOI.Items.Sync.Tab
  @id: -> 'LandsOfIllusions.Items.Sync.Immersion'
  @register @id()

  @url: -> 'immersion'
  @displayName: -> 'Immersion'
    
  @initialize()

  onCreated: ->
    super

    @activatedCharacters = new ComputedField =>
      return [] unless characters = Retronator.user()?.characters

      LOI.Character.getInstance character for character in characters when character.activated

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
    super.concat
      'click .character': @onClickCharacter
      'click .lands-of-illusions': @onClickLandsOfIllusions
      'click .disconnect': @onClickDisconnect
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onClickCharacter: (event) ->
    characterInstance = @currentData()

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
