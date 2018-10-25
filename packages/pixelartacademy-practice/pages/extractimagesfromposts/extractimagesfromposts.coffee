AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Pages.ExtractImagesFromPosts extends AM.Component
  @register 'PixelArtAcademy.Practice.Pages.ExtractImagesFromPosts'

  events: ->
    super(arguments...).concat
      'click .process-button': @onClickProcessButton

  onClickProcessButton: (event) ->
    Meteor.call 'PixelArtAcademy.Practice.CheckIn.extractImagesFromPosts'
