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

  dataAttributes: ->
    'data-value': EJSON.stringify @value()
    'data-format': EJSON.stringify @format()

  @registerBlot: (options) ->
    parent = @
  
    class @Blot extends BlockEmbed
      @blotName = options.name
      @tagName = options.tag
      @className = options.class

      @create: (value) ->
        # Create a temporary node and render the component to it.
        $div = $('<div>')
        Blaze.renderWithData parent.renderComponent(), value, $div[0]

        # Return the top component node.
        $div.find('*')[0]

      @value: (node) ->
        # We use attr instead of data so that we can stringify the object ourselves
        # with EJSON instead of the default that would do it with JSON.
        return unless valueString = $(node).attr('data-value')
        EJSON.parse valueString

      @formats: (node) ->
        return unless formatString = $(node).attr('data-format')
        EJSON.parse formatString

      format: (name, value) ->
        component = BlazeComponent.getComponentForElement @domNode
        
        # Update the format object.
        component.updateFormat name, value

    # Register the blot with Quill.
    Quill.register @Blot
