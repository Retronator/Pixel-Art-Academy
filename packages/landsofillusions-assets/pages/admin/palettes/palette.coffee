AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Pages.Admin.Palettes.Palette extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'LandsOfIllusions.Assets.Pages.Admin.Palettes.Palette'
  @register @id()
  
  shadeStyle: ->
    shade = @currentData()
    
    backgroundColor: "##{THREE.Color.fromObject(shade).getHexString()}"

  events: ->
    super(arguments...).concat
      'click .convert-ramps-to-shades-button': @onClickConvertRampsToShadesButton
  
  onClickConvertRampsToShadesButton: (event) ->
    palette = @data()
    
    LOI.Assets.Pages.Admin.Palettes.Scripts.convertRampsToShades palette._id
