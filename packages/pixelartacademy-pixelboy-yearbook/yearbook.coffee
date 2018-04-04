AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Yearbook extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook'
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
    Yearbook = @

    class @Student extends LOI.Character
      @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.Student'

      @Meta
        name: @id()
        collection: new Meteor.Collection Yearbook.studentsCollectionName
  
  constructor: ->
    super

    @setFixedPixelBoySize 384, 274

    @front = new ReactiveField null
    @middle = new ReactiveField null

  mixins: -> [
    PAA.PixelBoy.Components.Mixins.PageTurner
  ]

  onCreated: ->
    super

    @showFront = new ReactiveField true

    @front new @constructor.Front @
    @middle new @constructor.Middle @

    @constructor.students.subscribe @

    @studentsPerSpread = 24

    @studentsByYear = new ComputedField =>
      students = @constructor.Student.documents.find().fetch()

      # Name can't be empty for a student to display.
      students = _.filter students, (student) => student.avatar.fullName.translate().text

      studentsByYear = {}

      for student in students
        student.hasPortrait = student.avatar.body?
        student.sortingName = _.deburr student.avatar.fullName.translate().text.toLowerCase()

        studentsByYear[student.classYear] ?=
          students: []
          spreads: []

        studentsByYear[student.classYear].students.push student

      startingPage = 1

      for year, studentsInYear of studentsByYear
        studentsInYear.students = _.sortBy studentsInYear.students, 'sortingName'

        # First page has a title that takes 2 names.
        placesLeftInSpread = @studentsPerSpread - 2
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

  currentView: ->
    if @showFront() then @front() else @middle()

  previousPage: ->
    @currentView().previousPage?()

  nextPage: ->
    @currentView().nextPage?()

  onBackButton: ->
    # Normally quit if we're already on the front page.
    return if @showFront()

    @showFront true

    # Inform that we've handled the back button.
    true
