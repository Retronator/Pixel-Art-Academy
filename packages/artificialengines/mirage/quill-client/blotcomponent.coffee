AM = Artificial.Mirage

BlockEmbed = AM.Quill.import 'blots/block/embed'

class AM.Quill.BlotComponent extends AM.Component
  @debug = false

  constructor: (@node, @_initialValue) ->
    super arguments...

    @quillComponent = new ReactiveField null, (a, b) => a is b

    console.log "Constructed component", @ if @constructor.Debug

  onCreated: ->
    super arguments...

    @value = new ReactiveField @_initialValue
    @formats = new ReactiveField {}

    @quill = new ComputedField => @quillComponent()?.quill()
    @readOnly = new ComputedField => @quill()?.options.readOnly ? true

    console.log "Created component", @ if @constructor.Debug

  onRendered: ->
    super arguments...
    
    # Reactively update data attributes.
    @autorun (computation) =>
      value = @value()

      console.log "Writing value data attribute", value, @ if @constructor.debug

      @node.setAttribute 'data-value', EJSON.stringify value
    
    @autorun (computation) =>
      formats = @formats()

      console.log "Writing formats data attribute", formats, @ if @constructor.debug

      @node.setAttribute 'data-formats', EJSON.stringify formats

    console.log "Rendered component", @ if @constructor.Debug

  @registerBlot: (options) ->
    parent = @

    class @Blot extends BlockEmbed
      @blotName = options.name
      @tagName = options.tag
      @className = options.class

      @create: (value) ->
        console.log "Creating blot", @blotName, value if AM.Quill.BlotComponent.debug

        # Create a node and a component and link them together. We need to use the provided node and
        # not a temporary one since otherwise we won't be able to detect events inside the component.
        node = super arguments...
        node.setAttribute 'contenteditable', false

        component = new parent node, value
        node.component = component

        # Render component into the node.
        Blaze.render component.renderComponent(), node

        console.log "Created blot", node, component if AM.Quill.BlotComponent.debug

        # Return the node.
        node

      @value: (node) ->
        console.log "Parsing value from node", node if AM.Quill.BlotComponent.debug
        
        return unless valueString = node.getAttribute 'data-value'
        value = EJSON.parse valueString

        console.log "Value is", value if AM.Quill.BlotComponent.debug
        
        value
  
      @formats: (node) ->
        console.log "Parsing formats from node", node if AM.Quill.BlotComponent.debug

        return unless formatsString = node.getAttribute 'data-formats'
        formats = EJSON.parse formatsString

        console.log "Formats is", formats if AM.Quill.BlotComponent.debug

        formats
        
      value: ->
        value = @domNode.component.value()

        console.log "Returning value from blot", @domNode, value if AM.Quill.BlotComponent.debug

        "#{@constructor.blotName}": value

      formats: ->
        formats = @domNode.component.formats()

        console.log "Returning formats from blot", @domNode, formats if AM.Quill.BlotComponent.debug
        
        formats

      format: (name, value) ->
        console.log "Setting format to blot", @domNode, name, value if AM.Quill.BlotComponent.debug

        formats = @domNode.component.formats()
    
        if value
          formats[name] = value
    
        else
          delete formats[name]
    
        # Update formats on component for reactivity.
        @domNode.component.formats formats

        console.log "New formats are", formats if AM.Quill.BlotComponent.debug

    # Register the blot with Quill.
    AM.Quill.register @Blot
