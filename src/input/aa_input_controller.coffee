###

Top down Input Controller class.
Specifies an aggregated controller.

Written by Bryce Summers on 1 - 31 - 2017.

FIXME: Allow people to toggle certain sub-controllers on and off.

###

class TSAG.Input_Controller

    constructor: () ->
    
        @_mouse_input_controllers    = []
        @_keyboard_input_controllers = []
        @_time_input_controllers     = []

        # Things like window resize.
        @_system_controllers         = []

        @time_on = false

# FIXME: Should I make the implementation of each of these methods optional?

    # Adds a controller that handles all inputs.
    add_universal_controller: (controller) ->
    
        # Add this controller to all controller categories.
        @_mouse_input_controllers.push(controller)
        @_keyboard_input_controllers.push(controller)
        @_time_input_controllers.push(controller)
        @_system_controllers.push(controller)
        return

    add_mouse_input_controller: (controller) ->
    
        @_mouse_input_controllers.push(controller)
        return

    add_keyboard_input_controller: (controller) ->
    
        @_keyboard_input_controllers.push(controller)
        return    

    add_time_input_controller: (controller) ->
    
        @_time_input_controllers.push(controller)
        return

    add_system_controller: (controller) ->

        @_system_controllers.push(controller)
        return

    mouse_down: (event) ->
    
        # event.x, event.y are the coordinates for the mouse button.
        # They are originally piped in from screeen space from [0, screen_w] x [0, screen_h]
        len = @_mouse_input_controllers.length
        for i in [0...len]
        
            controller = @_mouse_input_controllers[i]
            controller.mouse_down(event)

        return


    mouse_up: (event) ->
    
        len = @_mouse_input_controllers.length
        for i in [0...len]
        
            controller = @_mouse_input_controllers[i]
            controller.mouse_up(event)

        return

    mouse_move: (event) ->
    
        len = @_mouse_input_controllers.length
        for i in [0...len]
        
            controller = @_mouse_input_controllers[i]
            controller.mouse_move(event)

        return
    

    # Difference in time between the previous call and this call.
    time: (dt) ->
    
        len = @_time_input_controllers.length
        for i in [0...len]
        
            controller = @_time_input_controllers[i]
            controller.time(dt)

        return


    window_resize: (event) ->
    
        len = @_system_controllers.length
        for i in [0...len]
        
            controller = @_system_controllers[i]
            controller.window_resize()

        return
