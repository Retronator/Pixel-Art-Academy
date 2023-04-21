AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection.CustomComponent extends AM.Component
  @register 'PixelArtAcademy.Challenges.Drawing.PixelArtSoftware.ReferenceSelection.CustomComponent'
  
  @cardSize = width: 75, height: 113
  @cardThickness = 0.5
  @stackOffset = 85
  @maxShadowWidth = 50
  @boundary =
    x: (480 + @cardSize.width) / 2 + @maxShadowWidth
    y: (360 + @cardSize.height) / 2
    
  @Choices =
    MonochromeColor:
      prompt: "One color or more?"
      left:
        name: "Monochrome"
        filter: (id) -> id[0] is 'M'
        nextChoiceKey: 'SmallBig'
      right:
        name: "Multiple"
        filter: (id) -> id[0] is 'C'
        nextChoiceKey: 'SmallBig'
    SmallBig:
      prompt: "Big or small?"
      left:
        name: "Small"
        filter: (id) -> id[1] is 'S'
        nextChoiceKey: 'CharacterThing'
      right:
        name: "Big"
        filter:  (id) -> id[1] is 'B'
        nextChoiceKey: 'CharacterThing'
    CharacterThing:
      prompt: "What would you like to draw?"
      left:
        name: "Character"
        filter: (id) -> id[2] in ['H', 'E']
        nextChoiceKey: 'HeroEnemy'
      right:
        name: "Something else"
        filter: (id) -> id[2] in ['V', 'O']
        nextChoiceKey: 'VehicleOtherObject'
    HeroEnemy:
      prompt: "Good or bad?"
      left:
        name: "Hero"
        filter: (id) -> id[2] is 'H'
      right:
        name: "Enemy"
        filter: (id) -> id[2] is 'E'
    VehicleOtherObject:
      prompt: "Vehicles or other objects?"
      left:
        name: "Vehicle"
        filter: (id) -> id[2] is 'V'
      right:
        name: "Other"
        filter: (id) -> id[2] is 'O'
  
  onCreated: ->
    super arguments...
    
    @cardsVisible = new ReactiveField false
    @_wasActive = false
    @active = new ReactiveField false
    
    @drawingApp = @ancestorComponentOfType PAA.PixelBoy.Apps.Drawing
    
    # Create all the cards
    cards = for id, copyReferenceClass of PAA.Challenges.Drawing.PixelArtSoftware.copyReferenceClasses
      new @constructor.Card id, copyReferenceClass
    
    @cards = new ReactiveField cards
    @selectedCard = new ReactiveField null
    @selectedCardRevealed = new ReactiveField false
    
    @currentChoice = new ReactiveField null
    
    @finalSelection = new ReactiveField false
    @selectionFinished = new ReactiveField false
    
    @_timeouts = []
    
  onRendered: ->
    super arguments...
  
    @autorun (computation) =>
      active = @drawingApp.activeAssetClass()?
      
      Meteor.setTimeout =>
        @active active
      ,
        0

    @autorun (computation) =>
      shouldBeActive = @active()
  
      if shouldBeActive and not @_wasActive
        @cardsVisible shouldBeActive
        
        Tracker.afterFlush =>
          @_initialize()
          @cardsVisible shouldBeActive
      
      else if @_wasActive and not shouldBeActive
        @_moveOut()
        
        Meteor.clearTimeout timeout for timeout in @_timeouts
  
        Meteor.setTimeout =>
          @cardsVisible shouldBeActive
        ,
          1000
  
      @_wasActive = shouldBeActive
  
  setPixelBoySize: (drawingApp) ->
    drawingApp.setMaximumPixelBoySize fullscreen: true
  
  _initialize: ->
    @currentChoice null
    @finalSelection false
    @selectedCard null
    @selectedCardRevealed false
    @selectionFinished false
    @choices = []
    @_timeouts = []
    @nextChoice = @constructor.Choices.MonochromeColor
  
    remainingReferenceClassIds = (copyReferenceClass.id() for copyReferenceClass in PAA.Challenges.Drawing.PixelArtSoftware.remainingCopyReferenceClasses())
    
    cards = @cards()
    @remainingCards = _.shuffle _.filter cards, (card) => card.copyReferenceClass.id() in remainingReferenceClassIds
    
    cardThickness = @constructor.cardThickness
  
    for card, index in cards
      if card.copyReferenceClass.id() in remainingReferenceClassIds
        # Remaining cards get shuffled from the bottom-right.
        card.setPosition @constructor.boundary.x, @constructor.boundary.y, @remainingCards.length * cardThickness
 
      else
        # Move cards that were already added to the top so they don't appear in closing transitions.
        card.setPosition 0, -@constructor.boundary.y, 0
        
    #@remainingCards = _.filter @remainingCards, (card) => _.startsWith card.id, 'CBEM'
    
    Tracker.afterFlush =>
      # Bring the cards in faster and faster.
      delay = 1000
      for card, index in @remainingCards
        do (card, index) =>
          @_timeouts.push Meteor.setTimeout =>
            card.setPosition 0, 0, index * cardThickness
          ,
            delay
          
          delay += Math.max 50, @_gradualDelay index
          
      delay += 1000
  
      @_timeouts.push Meteor.setTimeout =>
        @_presentChoice()
        #@_presentFinalSelection()
      ,
        delay
  
  _presentChoice: ->
    choice = @nextChoice
    
    # Separate the cards based on the choice filter.
    cardThickness = @constructor.cardThickness
    stackOffset = @constructor.stackOffset
  
    delay = 0
    stackCount = {}
    stackCount[-1] = 0
    stackCount[1] = 0
    cardsMoved = 0
  
    for card in @remainingCards by -1
      sign = 0
      sign = -1 if choice.left.filter card.id
      sign = 1 if choice.right.filter card.id
      
      if sign
        stackPosition = stackCount[sign]
        
        do (card, sign, stackPosition) =>
          @_timeouts.push Meteor.setTimeout =>
            card.setPosition stackOffset * sign, 0, stackPosition * cardThickness
          ,
            delay

        delay += @_gradualDelay cardsMoved
        cardsMoved++
        stackCount[sign]++
  
    delay += 500
  
    @_timeouts.push Meteor.setTimeout =>
      @currentChoice choice
    ,
      delay
  
  _presentFinalSelection: ->
    cardAreaWidth = 320 / @remainingCards.length
    
    for card, index in @remainingCards by -1
      card.setPosition -160 + cardAreaWidth * (index + 0.5), 0, 0
  
    @_timeouts.push Meteor.setTimeout =>
      @finalSelection true
    ,
      600
  
  _moveOut: ->
    @currentChoice null
    
    cards = @cards()
    
    for card, index in cards
      card.setPosition 0, -@constructor.boundary.y, 10
      
  _gradualDelay: (index) ->
    Math.pow(index + 1, -0.7) * 250
    
  _makeChoice: (madeChoice) ->
    choice = @currentChoice()
    @currentChoice null
  
    nextChoiceKey = choice[madeChoice].nextChoiceKey

    # Move chosen cards to the center.
    newRemainingCards = []
    
    for card in @remainingCards
      if choice[madeChoice].filter card.id
        card.setPosition 0
        newRemainingCards.unshift card
        
      else
        card.setPosition @constructor.boundary.x * Math.sign card.position.x
  
    @remainingCards = newRemainingCards
  
    @_timeouts.push Meteor.setTimeout =>
      if @remainingCards.length is 1
        # Automatically choose the card.
        @_revealSelectedCard()
        
      else
        if nextChoiceKey
          @nextChoice = @constructor.Choices[nextChoiceKey]
          @_presentChoice()
  
        else
          # Present the final selection.
          @_presentFinalSelection()
    ,
      if @remainingCards.length is 1 then 600 else 1000
  
  _makeFinalSelection: (selection) ->
    @finalSelection false
    
    Tracker.afterFlush =>
      for card in @remainingCards
        if card is selection
          card.setPosition 0, 0, 1
          @remainingCards = [card]
      
        else
          card.setPosition 0, -@constructor.boundary.y, 0
  
    @_timeouts.push Meteor.setTimeout =>
      @_revealSelectedCard()
    ,
      600
      
  _revealSelectedCard: ->
    selectedCard = @remainingCards[0]
    @selectedCard selectedCard
  
    selectedCard.setPosition 0, 20, 20
    
    Tracker.afterFlush =>
      @selectedCardRevealed true
      
      # Add the card to assets.
      PAA.Challenges.Drawing.PixelArtSoftware.addCopyReferenceAsset selectedCard.id
  
      @_timeouts.push Meteor.setTimeout =>
        @selectionFinished true
      ,
        600

  activeClass: ->
    'active' if @active()
  
  finalSelectionClass: ->
    'final-selection' if @finalSelection()
  
  selectionFinishedClass: ->
    'selection-finished' if @selectionFinished()

  revealedClass: ->
    card = @currentData()
    
    'revealed' if card is @selectedCard() and @selectedCardRevealed()

  events: ->
    super(arguments...).concat
      'click .left.choice': @onClickLeftChoice
      'click .right.choice': @onClickRightChoice
      'click .card': @onClickCard
  
  onClickLeftChoice: (event) ->
    @_makeChoice 'left'

  onClickRightChoice: (event) ->
    @_makeChoice 'right'
    
  onClickCard: (event) ->
    if @finalSelection()
      @_makeFinalSelection @currentData()
      
    else if @selectionFinished()
      AB.Router.setParameter 'parameter3', null
