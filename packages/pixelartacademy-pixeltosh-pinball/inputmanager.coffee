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
      return unless control = @_keyCodeToControl event.code
      return if @controlActive[control]

      @controlActive[control] = true
      
      part.activate() for part in @_getParts control
      
    $(document).on 'keyup.pixelartacademy-pixeltosh-programs-pinball-inputmanager', (event) =>
      return unless control = @_keyCodeToControl event.code
      return unless @controlActive[control]

      @controlActive[control] = false
      
      part.deactivate() for part in @_getParts control
      
  destroy: ->
    $(document).off 'keydown.pixelartacademy-pixeltosh-programs-pinball-inputmanager'
  
  _keyCodeToControl: (code) ->
    switch code
      when 'ShiftLeft', 'ControlLeft', 'AltLeft', 'MetaLeft', 'ArrowLeft' then @constructor.Controls.LeftFlipper
      when 'ShiftRight', 'ControlRight', 'AltRight', 'MetaRight', 'ArrowRight', 'NumpadEnter' then @constructor.Controls.RightFlipper
      when 'ArrowDown', 'Space', 'Enter' then @constructor.Controls.Plunger
      else
        null

  _getParts: (control) ->
    parts = @pinball.sceneManager().parts()
    
    _.filter parts, (part) =>
      return true if control is @constructor.Controls.Plunger and part instanceof Pinball.Parts.Plunger
      false
