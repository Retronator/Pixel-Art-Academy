LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.MainMenu extends LOI.Adventure.Location
  @id: -> 'PixelArtAcademy.LearnMode.MainMenu'
  @url: -> ''
  @region: -> PAA.LearnMode.Region
  
  @register @id()
  template: -> @constructor.id()
  
  @version: -> '0.0.1'

  @fullName: -> "Main Menu"
  
  @initialize()
  
  isLandingPage: -> true

  constructor: ->
    super arguments...
  
    @menuItems = new LM.Menu.Items
      landingPage: true
      
  isLandingPage: -> true
  
  onCreated: ->
    super arguments...
  
    # Prevent default menu handling on escape.
    LOI.adventure.menu.customShowMenu => # Nothing needs to happen as the menu is always displayed.
  
  onRendered: ->
    super arguments...
  
    # Reactively resize elements.
    @autorun (computation) => @onResize()
    
  onDestroyed: ->
    super arguments...
  
    LOI.adventure.menu.customShowMenu null

  onResize: (options) ->
    display = LOI.adventure.interface.display
    scale = display.scale()
    viewport = display.viewport()

    # The place for content is as wide as the safe area, but fills the full viewport height.
    contentAreaSize = viewport.viewportBounds.toDimensions()
    contentAreaSize.left += viewport.safeArea.x()
    contentAreaSize.width = viewport.safeArea.width()

    @$('.pixelartacademy-learnmode-mainmenu > .content-area').css contentAreaSize
  
    # Place menu in the center. We use a constant height that will accommodate the main menu and sub-menus.
    menuAreaHeight = 100
    menuAreaTop = contentAreaSize.height / scale / 2 - menuAreaHeight / 2
    
    @$('.menu-area').css
      top: "#{menuAreaTop}rem"
      height: "#{menuAreaHeight}rem"
      lineHeight: "#{menuAreaHeight}rem"
      
    # Place header in the top section above the menu
    headerAreaHeight = menuAreaTop
    
    @$('.header-area').css
      height: "#{headerAreaHeight}rem"
      lineHeight: "#{headerAreaHeight}rem"
