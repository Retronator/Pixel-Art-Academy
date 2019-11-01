AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

Quill = require 'quill'
BlockEmbed = Quill.import 'blots/block/embed'

class Entry.Object extends AM.Component
  constructor: (@node, @_initialValue) ->
    super arguments...
    
    @entryComponent = new ReactiveField null, (a, b) => a is b

    console.log "Constructed component", @ if Entry.debug
    
  onCreated: ->
    super arguments...

    @value = new ReactiveField @_initialValue
    @formats = new ReactiveField {}

    @readOnly = new ComputedField =>
      # Treat the object as read-only until we know what the entry says.
      return true unless entryComponent = @entryComponent()
        
      entryComponent.journalDesign.options.readOnly

    console.log "Created component", @ if Entry.debug

  onRendered: ->
    super arguments...
    
    # Reactively update data attributes.
    @autorun (computation) =>
      value = @value()

      console.log "Writing value data attribute", value, @ if Entry.debug

      @node.setAttribute 'data-value', EJSON.stringify value
    
    @autorun (computation) =>
      formats = @formats()

      console.log "Writing formats data attribute", formats, @ if Entry.debug

      @node.setAttribute 'data-formats', EJSON.stringify formats

    console.log "Rendered component", @ if Entry.debug

  @registerBlot: (options) ->
    parent = @
  
    class @Blot extends BlockEmbed
      @blotName = options.name
      @tagName = options.tag
      @className = options.class

      @create: (value) ->
        console.log "Creating blot", @blotName, value if Entry.debug

        # Create node and component and link them together. We need to use the provided node and
        # not a temporary one since otherwise we won't be able to detect events inside the component.
        node = super arguments...
        node.setAttribute 'contenteditable', false

        component = new parent node, value
        node.component = component

        # Render component into the node.
        Blaze.render component.renderComponent(), node

        console.log "Created blot", node, component if Entry.debug

        # Return the node.
        node

      @value: (node) ->
        console.log "Parsing value from node", node if Entry.debug
        
        return unless valueString = node.getAttribute 'data-value'
        value = EJSON.parse valueString

        console.log "Value is", value if Entry.debug
        
        value
  
      @formats: (node) ->
        console.log "Parsing formats from node", node if Entry.debug

        return unless formatsString = node.getAttribute 'data-formats'
        formats = EJSON.parse formatsString

        console.log "Formats is", formats if Entry.debug

        formats
        
      value: ->
        value = @domNode.component.value()

        console.log "Returning value from blot", @domNode, value if Entry.debug

        "#{@constructor.blotName}": value

      formats: ->
        formats = @domNode.component.formats()

        console.log "Returning formats from blot", @domNode, formats if Entry.debug
        
        formats

      format: (name, value) ->
        console.log "Setting format to blot", @domNode, name, value if Entry.debug

        formats = @domNode.component.formats()
    
        if value
          formats[name] = value
    
        else
          delete formats[name]
    
        # Update formats on component for reactivity.
        @domNode.component.formats formats

        console.log "New formats are", formats if Entry.debug

    # Register the blot with Quill.
    Quill.register @Blot
