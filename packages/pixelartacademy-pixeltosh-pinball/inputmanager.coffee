LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.InputManager
  @Controls:
    LeftFlipper: 'LeftFlipper'
    RightFlipper: 'RightFlipper'
    Plunger: 'Plunger'
    
  constructor: (@pinball) ->
    @controlActive =
      LeftFlipper: false
      RightFlipper: false
      Plunger: false
    
    $(document).on 'keydown.pixelartacademy-pixeltosh-programs-pinball-inputmanager', (event) =>
      return if @_ignoreKeys event
      return unless control = @_keyCodeToControl event.code
      return if @controlActive[control]

      @controlActive[control] = true
      
      part.activate() for part in @_getParts control
      
    $(document).on 'keyup.pixelartacademy-pixeltosh-programs-pinball-inputmanager', (event) =>
      return if @_ignoreKeys event
      return unless control = @_keyCodeToControl event.code
      return unless @controlActive[control]

      @controlActive[control] = false
      
      part.deactivate() for part in @_getParts control
      
  destroy: ->
    $(document).off '.pixelartacademy-pixeltosh-programs-pinball-inputmanager'
  
  _ignoreKeys: (event) ->
    # Ignore keys when input is focused.
    return true if @pinball.os.interface.inputFocused()
    
    # Outside of edit mode, no ignoring is needed.
    return unless @pinball.gameManager()?.inEdit()
    
    # Ignore keys while editing.
    return true if @pinball.editorManager().editing()
    
    # Ignore command/control keys to allow for shortcut presses.
    event.metaKey or event.ctrlKey
    
  _keyCodeToControl: (code) ->
    switch code
      when 'ShiftLeft', 'ControlLeft', 'ArrowLeft' then @constructor.Controls.LeftFlipper
      when 'ShiftRight', 'ControlRight', 'ArrowRight', 'NumpadEnter' then @constructor.Controls.RightFlipper
      when 'ArrowDown', 'Space', 'Enter' then @constructor.Controls.Plunger
      else
        null

  _getParts: (control) ->
    parts = @pinball.sceneManager().parts()
    
    _.filter parts, (part) =>
      return true if control is @constructor.Controls.Plunger and part instanceof Pinball.Parts.Plunger
      return true if control is @constructor.Controls.LeftFlipper and part instanceof Pinball.Parts.Flipper and not part.data().flipped
      return true if control is @constructor.Controls.RightFlipper and part instanceof Pinball.Parts.Flipper and part.data().flipped
      false
