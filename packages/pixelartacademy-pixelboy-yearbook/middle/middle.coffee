AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Yearbook = PAA.PixelBoy.Apps.Yearbook

class Yearbook.Middle extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.Middle'
  @register @id()

  constructor: (@yearbook) ->
    super arguments...

  onCreated: ->
    super arguments...

    @currentSpreadIndex = new ReactiveField 0

    @autorun (computation) =>
      return unless @yearbook.showProfileForm()

      playerCharacterPage = @yearbook.playerCharacterPage()

      @currentSpreadIndex Math.floor (playerCharacterPage - 1) / 2

    @_avatars = {}

    @currentYear = new ComputedField =>
      # Determine which year we're on.
      studentsByYear = @yearbook.studentsByYear()
      currentSpreadIndex = @currentSpreadIndex()
      currentPage = currentSpreadIndex * 2 + 1

      for year, studentsInYear of studentsByYear
        currentYear = year if studentsInYear.startingPage <= currentPage

      # Since year was an object key, we need to convert it from a string to an integer.
      parseInt currentYear

    @currentSpreadIndexInYear = new ComputedField =>
      # Determine which year we're on.
      studentsByYear = @yearbook.studentsByYear()
      currentSpreadIndex = @currentSpreadIndex()
      return unless currentYear = @currentYear()

      studentsInYear = studentsByYear[currentYear]
      previousSpreadsCount = (studentsInYear.startingPage - 1) / 2

      currentSpreadIndex - previousSpreadsCount

    @currentSpreadStudents = new ComputedField =>
      studentsByYear = @yearbook.studentsByYear()
      currentYear = @currentYear()
      currentSpreadIndexInYear = @currentSpreadIndexInYear()
      return unless currentSpreadIndexInYear?

      studentsByYear[currentYear].spreads[currentSpreadIndexInYear]

  onDestroyed: ->
    super arguments...

    # Clean up character instances.
    avatar().destroy() for characterId, avatar of @_avatars

  previousPage: ->
    currentSpreadIndex = @currentSpreadIndex()

    if currentSpreadIndex
      @currentSpreadIndex @currentSpreadIndex() - 1

    else
      @yearbook.showFront true

  nextPage: ->
    return unless @nextPageExists()
    @currentSpreadIndex @currentSpreadIndex() + 1

  nextPageExists: ->
    studentsByYear = @yearbook.studentsByYear()
    return unless currentYear = @currentYear()

    # You can go forward if we're not on the last year.
    return 'visible' if studentsByYear[currentYear + 1]

    currentSpreadIndexInYear = @currentSpreadIndexInYear()

    # You can go forward if there is another spread left.
    studentsByYear[currentYear].spreads[currentSpreadIndexInYear + 1]

  avatar: ->
    # Don't start rendering avatars when on the front page.
    return if @yearbook.showFront()

    student = @currentData()
    return unless student.hasPortrait

    # Create the instance if needed, but do it with a delay.
    unless @_avatars[student._id]
      @_avatars[student._id] = new ReactiveField null

      Meteor.setTimeout =>
        return if @isDestroyed()
        @_avatars[student._id] new LOI.Character.Avatar student

    @_avatars[student._id]()

  name: ->
    student = @currentData()
    student.avatar.fullName.translate().text

  badges: ->
    student = @currentData()
    badges = []
    
    if student.isBacker
      badges.push
        class: 'kickstarter'
        description: "Kickstarter backer"
        
    if student.isPatron
      badges.push
        class: 'patreon'
        description: "Patreon patron"
    
    if student.hasAlphaAccess
      badges.push
        class: 'alpha'
        description: "Alpha access"

    for badge in badges
      badge.iconPath = @yearbook.versionedUrl "/pixelartacademy/pixelboy/apps/yearbook/badges/#{badge.class}.png"
      
    badges

  leftPageNumber: ->
    @currentSpreadIndex() * 2 + 1

  rightPageNumber: ->
    @currentSpreadIndex() * 2 + 2

  visibleClass: ->
    'visible' unless @yearbook.showFront()
    
  previousPageVisibleClass: ->
    # Don't allow to change pages when profile form is shown.
    return if @yearbook.showProfileForm()

    'visible'
    
  nextPageVisibleClass: ->
    # Don't allow to change pages when profile form is shown.
    return if @yearbook.showProfileForm()

    'visible' if @nextPageExists()

  highlightedPlayerCharacterClass: ->
    # Highlight the player character when we're editing the form.
    return unless @yearbook.showProfileForm()

    student = @currentData()
    'highlighted' if student.isPlayerCharacter

  events: ->
    super(arguments...).concat
      'click .previous.page-button': @onClickPreviousPageButton
      'click .next.page-button': @onClickNextPageButton
      'click .front.page-button': @onClickFrontPageButton

  onClickPreviousPageButton: (event) ->
    @previousPage()

  onClickNextPageButton: (event) ->
    @nextPage()

  onClickFrontPageButton: (event) ->
    @yearbook.goToFront()
