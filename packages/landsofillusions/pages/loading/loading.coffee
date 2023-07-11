AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Loading extends AM.Component
  @register 'LandsOfIllusions.Pages.Loading'

  onCreated: ->
    super arguments...

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: 2

  onRendered: ->
    super arguments...
  
    $loadingScreen = @$('.landsofillusions-pages-loading')
    $loadingText = @$('.loading-text')
    
    # Field to minimize reactivity.
    @show = new ComputedField => @data()
    
    @autorun (computation) =>
      # Cancel any previous displaying.
      Meteor.clearTimeout @_displayTimeout
      
      if @show()
        # Activate the loading cursor and prevent clicking.
        $loadingScreen.addClass 'active'
        
        # Show the loading screen after a brief delay to prevent flickering.
        @_displayTimeout = Meteor.setTimeout =>
          $loadingScreen.addClass 'visible'
  
          # Show the loading text as well after a while.
          @_displayTimeout = Meteor.setTimeout =>
            $loadingText.addClass 'visible'
          ,
            1000
        ,
          100
        
      else
        # Immediately hide the loading screen.
        $loadingScreen.removeClass('active').removeClass 'visible'
        $loadingText.removeClass 'visible'

