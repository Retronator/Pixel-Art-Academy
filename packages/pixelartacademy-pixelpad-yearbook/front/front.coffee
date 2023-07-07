AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Yearbook.Front extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Yearbook.Front'
  @register @id()

  constructor: (@yearbook) ->
    super arguments...

  onCreated: ->
    super arguments...

  nextPage: ->
    @yearbook.middle().currentSpreadIndex 0
    @yearbook.showFront false

  visibleClass: ->
    'visible' if @yearbook.showFront()

  sections: ->
    studentsByYear = @yearbook.studentsByYear()
   
    for year in [2016..2018] when studentsByYear[year]
      switch year
        when 2016 then categories = ["Alpha backers", "Alpha pre-orders"]
        when 2017 then categories = ["Regular backers", "Pre-orders", "Patrons"]
        when 2018 then categories = ["Pre-orders", "Patrons"]

      year: year
      categories: categories
      startingPage: studentsByYear[year].startingPage

  events: ->
    super(arguments...).concat
      'click .next.page-button': @onClickNextPageButton
      'click .section': @onClickSection
      'click .pixelartacademy-pixelpad-apps-yearbook-profileform': @onClickEditProfile

  onClickNextPageButton: (event) ->
    @nextPage()

  onClickSection: (event) ->
    section = @currentData()

    @yearbook.middle().currentSpreadIndex (section.startingPage - 1) / 2
    @yearbook.showFront false

  onClickEditProfile: (event) ->
    @yearbook.showFront false
    @yearbook.showProfileForm true
