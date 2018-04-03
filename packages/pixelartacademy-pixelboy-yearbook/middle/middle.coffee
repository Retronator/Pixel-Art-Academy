AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Yearbook = PAA.PixelBoy.Apps.Yearbook

class Yearbook.Middle extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.Middle'
  @register @id()

  constructor: (@yearbook) ->
    super

  onCreated: ->
    super

    Yearbook.classOf2016.subscribe @
    
    @students = new ComputedField =>
      characters = Yearbook.ClassOf2016Character.documents.find().fetch()

      # Name can't be empty for a student to display.
      students = for character in characters when character.avatar.fullName.translate().text
        character: character
        name: character.avatar.fullName.translate().text
        hasPortrait: character.avatar.body?

      _.sortBy students, (student) -> student.name.toLowerCase()

    @currentSpreadIndex = new ReactiveField 0
    @studentsPerSpread = 24

    @_avatars = {}

    @currentPageStudents = new ComputedField =>
      students = @students()

      currentSpread = @currentSpreadIndex()
      startStudentIndex = currentSpread * @studentsPerSpread

      students[startStudentIndex...startStudentIndex + @studentsPerSpread]

  onDestroyed: ->
    super

    # Clean up character instances.
    avatar.destroy() for characterId, avatar of @_avatars

  avatar: ->
    student = @currentData()
    return unless student.hasPortrait

    @_getAvatarForCharacter student.character

  _getAvatarForCharacter: (character) ->
    # Create the instance if needed.
    @_avatars[character._id] ?= new LOI.Character.Avatar character
    @_avatars[character._id]

  leftPageNumber: ->
    @currentSpreadIndex() * 2 + 1

  rightPageNumber: ->
    @currentSpreadIndex() * 2 + 2

  visibleClass: ->
    'visible' unless @yearbook.showFront()

  previousPageVisibleClass: ->
    'visible' if @currentSpreadIndex() > 0

  nextPageVisibleClass: ->
    'visible' if @currentSpreadIndex() + 1 < @students().length / @studentsPerSpread

  events: ->
    super.concat
      'click .previous.page-button': @onClickPreviousPageButton
      'click .next.page-button': @onClickNextPageButton

  onClickPreviousPageButton: (event) ->
    @currentSpreadIndex @currentSpreadIndex() - 1

  onClickNextPageButton: (event) ->
    @currentSpreadIndex @currentSpreadIndex() + 1
