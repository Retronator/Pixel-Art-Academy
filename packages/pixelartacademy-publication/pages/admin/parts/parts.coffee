AM = Artificial.Mirage
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Publication.Pages.Admin.Parts extends Artificial.Mummification.Admin.Components.AdminPage
  @id: -> 'PixelArtAcademy.Publication.Pages.Admin.Parts'
  @register @id()
  
  constructor: ->
    super
      documentClass: PAA.Publication.Part
      adminComponentClass: PAA.Publication.Pages.Admin.Parts.Part
      nameFunction: (part) =>
        parts = part.referenceId.split('.')
        publicationsPartIndex = _.indexOf parts, 'Publications'
        parts[publicationsPartIndex + 1..].join ' '
      singularName: 'publication part'
      pluralName: 'publication parts'

  events: ->
    super(arguments...).concat
      'input .preview-classes': @onInputPreviewClasses
      
  onInputPreviewClasses: (event) ->
    @$('.publication')[0].className = "publication #{event.target.value} #{document?.design?.class}"
