AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Yearbook extends PAA.PixelPad.App
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Yearbook'
  @url: -> 'yearbook'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Yearbook"
  @description: ->
    "
      Learn about your classmates at the Academy.
    "

  @initialize()

  # Subscriptions

  @students: new AB.Subscription name: "#{@id()}.students"
  @studentsCollectionName: "#{@id()}.students"

  if Meteor.isClient
    # Create a reference to the Yearbook class since @ will refer to Student in the code below. Note that
    # we can't just name this Yearbook since the class is already called that and it would issue a warning.
    yearbookClass = @

    class @Student extends LOI.Character
      @id: -> 'PixelArtAcademy.PixelPad.Apps.Yearbook.Student'

      @Meta
        name: @id()
        collection: new Meteor.Collection yearbookClass.studentsCollectionName
  
  constructor: ->
    super arguments...

    @setFixedPixelPadSize 384, 274

    @front = new ReactiveField null
    @middle = new ReactiveField null
    @profileForm = new ReactiveField null

  mixins: -> [
    PAA.PixelPad.Components.Mixins.PageTurner
  ]

  onCreated: ->
    super arguments...

    @showFront = new ReactiveField true
    @showProfileForm = new ReactiveField false

    @front new @constructor.Front @
    @middle new @constructor.Middle @
    @profileForm new @constructor.ProfileForm @

    # Subscribe to all regions and the translations of their names.
    Artificial.Babel.Region.all.subscribe @

    @constructor.students.subscribe @

    @studentsPerSpread = 24

    # First page has a title that takes 2 names.
    @yearTitleHeight = 2

    @studentsByYear = new ComputedField =>
      students = @constructor.Student.documents.find().fetch()
      characterId = LOI.characterId()

      # Name can't be empty for a student to display.
      students = _.filter students, (student) => student.avatar.fullName?.translate().text

      studentsByYear = {}

      for student in students
        student.hasPortrait = student.avatar.body?
        student.isPlayerCharacter = true if student._id is characterId
        student.sortingName = _.deburr student.avatar.fullName.translate().text.toLowerCase()

        studentsByYear[student.classYear] ?=
          students: []
          spreads: []

        studentsByYear[student.classYear].students.push student

      startingPage = 1

      for year, studentsInYear of studentsByYear
        studentsInYear.students = _.sortBy studentsInYear.students, 'sortingName'

        placesLeftInSpread = @studentsPerSpread - @yearTitleHeight
        currentSpread = 0

        for student in studentsInYear.students
          studentsInYear.spreads[currentSpread] ?= []
          studentsInYear.spreads[currentSpread].push student
          placesLeftInSpread--
          unless placesLeftInSpread
            placesLeftInSpread = @studentsPerSpread
            currentSpread++

        studentsInYear.startingPage = startingPage
        startingPage += studentsInYear.spreads.length * 2 # pages per spread

      studentsByYear
      
    @playerCharacterPage = new ComputedField =>
      studentsByYear = @studentsByYear()
      characterId = LOI.characterId()
  
      for year, studentsInYear of studentsByYear
        for spread, spreadIndex in studentsInYear.spreads
          characterIndex = _.findIndex spread, (character) => character._id is characterId
  
          if characterIndex > -1
            studentsOnLeftPage = @studentsPerSpread / 2
            studentsOnLeftPage -= @yearTitleHeight unless spreadIndex
            
            page = studentsInYear.startingPage + spreadIndex * 2
            page++ if characterIndex >= studentsOnLeftPage
  
            return page
  
      # Synced character was not found as it's probably still loading (or its name is not set)
      # so just pretend it's on page 2 so that the form will appear opposite on page 1.
      2

  currentView: ->
    if @showFront() then @front() else @middle()

  previousPage: ->
    # Don't allow to change pages when profile form is shown.
    return if @showProfileForm()

    @currentView().previousPage?()

  nextPage: ->
    # Don't allow to change pages when profile form is shown.
    return if @showProfileForm()

    @currentView().nextPage?()

  goToFront: ->
    @showFront true
    @showProfileForm false

  onBackButton: ->
    # Normally quit if we're already on the front page.
    return if @showFront()

    @goToFront()

    # Inform that we've handled the back button.
    true
