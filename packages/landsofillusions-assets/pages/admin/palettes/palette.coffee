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
    
  class @Category extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Pages.Admin.Palettes.Palette.Category'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Select
    
    options: ->
      options = [name: '', value: null]
      
      for category of LOI.Assets.Palette.Categories
        options.push name: category, value: category
        
      options
    
    load: ->
      @data()?.category
    
    save: (value) ->
      LOI.Assets.Palette.update @data()._id,
        category: value
