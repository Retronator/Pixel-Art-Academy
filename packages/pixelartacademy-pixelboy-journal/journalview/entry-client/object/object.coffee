AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

Quill = require 'quill'
BlockEmbed = Quill.import 'blots/block/embed'

class Entry.Object extends AM.Component
  onCreated: ->
    super

    @value = new ReactiveField @data()
    @format = new ReactiveField {}

  updateFormat: (name, value) ->
    format = @format()

    if value
      format[name] = value
      
    else
      delete format[name]
      
    @format format

  @registerBlot: (blotName) ->
    parent = @
  
    class @Blot extends BlockEmbed
      @blotName = blotName
  
      @create: (value) ->
        # Create a temporary node and render the component to it.
        $div = $('<div>')
        Blaze.renderWithData parent.renderComponent(BlazeComponent.currentComponent()), value, $div[0]

        # Return the top component node.
        $div.find('div')[0]
  
      @value: (node) ->
        component = BlazeComponent.getComponentForElement node
        
        # Retrieve the current value object.
        component.value()
  
      @formats: (node) ->
        component = BlazeComponent.getComponentForElement node
        
        # Retrieve the current format object.
        component.format()
  
      format: (name, value) ->
        component = BlazeComponent.getComponentForElement @domNode
        
        # Update the format object.
        component.updateFormat name, value

    # Register the blot with Quill.
    Quill.register @Blot
