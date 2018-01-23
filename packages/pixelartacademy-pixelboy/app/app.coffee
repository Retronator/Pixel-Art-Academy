AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.App extends LOI.Adventure.Item
  @_appClassesByUrl = {}

  @getClassForUrl: (url) ->
    @_appClassesByUrl[url]

  @initialize: ->
    super

    url = @url()
    @_appClassesByUrl[url] = @ if url?
        
  iconUrl: ->
    @versionedUrl "/pixelartacademy/pixelboy/apps/#{@url()}/icon.png"

  constructor: (@os) ->
    super

    # Does this app lets the device resize?
    @resizable = new ReactiveField true

    # The minimum size the device should be let to resize.
    @minWidth = new ReactiveField null
    @minHeight = new ReactiveField null

    # The maximum size the device should be let to resize.
    @maxWidth = new ReactiveField null
    @maxHeight = new ReactiveField null

  onRendered: ->
    super
    
    $appWrapper = $('.app-wrapper')
    $appWrapper.velocity 'transition.slideUpIn', complete: ->
      $appWrapper.css('transform', '')

  setDefaultPixelBoySize: ->
    @minWidth 310
    @minHeight 230

    @maxWidth null
    @maxHeight null

    @resizable true
