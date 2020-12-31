AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

class PAA.PixelBoy.Apps.StudyPlan.GoalSearch extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.StudyPlan.GoalSearch'
  @register @id()

  constructor: (@studyPlan) ->
    super arguments...

  onCreated: ->
    super arguments...

    # Instantiate all goals.
    @_goals = []
    @goals = new ComputedField =>
      goal.destroy() for goal in @_goals
      @_goals = (new goalClass for goalClass in PAA.Learning.Goal.getClasses())
      @_goals

    @interestSearchTerm = new ReactiveField ''

    @goalsWithInterest = new ComputedField =>
      return unless searchTerm = _.lowerCase @interestSearchTerm()

      _.filter @goals(), (goal) =>
        # See if any of goal's interests matches the searched interest.
        for interest in goal.interests()
          # Find the interest document and see if our search term matches its interests. If we can't find
          # the interest it's because the interest isn't matching the term so we're not subscribed to it.
          continue unless interestDocument = IL.Interest.find interest
          return true if searchTerm in interestDocument.searchTerms

        false

    # Subscribe to interests.
    @autorun (computation) =>
      IL.Interest.forSearchTerm.subscribe @interestSearchTerm()

    @autocompleteInterests = new ComputedField =>
      IL.Interest.forSearchTerm.query(@interestSearchTerm())?.fetch()

    @activeAutocompleteInterest = new ReactiveField null

    @interestsSearchInputFocused = new ReactiveField false

  onDestroyed: ->
    goal.destroy() for goal in @_goals

  setInterest: (interest) ->
    name = AB.translate(interest.name).text
    @interestSearchTerm name
    @$('.interests .search .input').blur()

  autocompleteInterestActiveClass: ->
    interest = @currentData()

    'active' if interest is @activeAutocompleteInterest()

  showAutocompleteInterests: ->
    # Show autocomplete when on search input and we have any results
    @interestsSearchInputFocused() and @autocompleteInterests()?.length

  goalExistingClass: ->
    goal = @currentData()
    'existing' if @studyPlan.hasGoal goal.id()

  events: ->
    super(arguments...).concat
      'mousedown .pixelartacademy-pixelboy-apps-studyplan-goal': @onMouseDownGoal
      'input .interests .search .input': @onInputInterestsSearchInput
      'focus .interests .search .input': @onFocusInterestsSearchInput
      'blur .interests .search .input': @onBlurInterestsSearchInput
      'click .interests .search .clear-input-button': @onInterestsSearchClickClearInputButton
      'mousedown .interests .search .autocomplete .interest': @onMouseDownInterestsSearchAutocompleteInterest
      'mouseenter .interests .search .autocomplete .interest': @onMouseEnterInterestsSearchAutocompleteInterest
      'keydown': @onKeyDown

  onMouseDownGoal: (event) ->
    goal = @currentData()

    # Prevent browser select/dragging behavior
    event.preventDefault()

    # Add this goal to the canvas.
    @studyPlan.addGoal
      goal: goal
      element: event.currentTarget
      event: event

    @interestSearchTerm ''

  onInputInterestsSearchInput: (event) ->
    @interestSearchTerm $(event.target).val()

  onFocusInterestsSearchInput: (event) ->
    @interestsSearchInputFocused true

  onBlurInterestsSearchInput: (event) ->
    @interestsSearchInputFocused false
    @activeAutocompleteInterest null

  onInterestsSearchClickClearInputButton: (event) ->
    @interestSearchTerm ''

  onMouseDownInterestsSearchAutocompleteInterest: (event) ->
    # We use mouse down because click won't happen since the autocomplete interface will already hide due to input blur.
    interest = @currentData()
    @setInterest interest

  onMouseEnterInterestsSearchAutocompleteInterest: (event) ->
    interest = @currentData()
    @activeAutocompleteInterest interest

  onKeyDown: (event) ->
    currentActiveInterest = @activeAutocompleteInterest()

    switch event.which
      when AC.Keys.down then delta = 1
      when AC.Keys.up then delta = -1
      when AC.Keys.enter
        @setInterest currentActiveInterest if currentActiveInterest
        return

      else
        return

    return unless interests = @autocompleteInterests()
    currentActiveIndex = _.indexOf interests, currentActiveInterest

    newActiveIndex = Math.max -1, currentActiveIndex + delta
    newActiveIndex = (newActiveIndex + interests.length) % interests.length

    @activeAutocompleteInterest interests[newActiveIndex]
    event.preventDefault()
