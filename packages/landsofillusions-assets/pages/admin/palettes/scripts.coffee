AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Pages.Admin.Palettes.Scripts extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'LandsOfIllusions.Assets.Pages.Admin.Palettes.Scripts'
  @register @id()

  @importLospec: new AB.Method name: "#{@id()}.importLospec"
  @convertRampsToShades: new AB.Method name: "#{@id()}.convertRampsToShades"

  events: ->
    super(arguments...).concat
      'submit .import-lospec': @onSubmitImportLospec
  
  onSubmitImportLospec: (event) ->
    event.preventDefault()
    
    slug = @$('.lospec-slug').val()
    @$('.lospec-slug').val ''
    
    @constructor.importLospec slug, (error, paletteId) =>
      return console.error if error
      
      AB.Router.setParameters documentId: paletteId
