###
    SimUrban Game User Interface.
    Written by Bryce on 4.30.2017
    
    Purpose: This class represents the particular state for the game's ui in its main gameplay state,
        - includes side buttons on the left of the screen.
        - Statistical displays on the bottom of the screen.
        - Messages.

        This class also handles the text based display of information to the users.
###

class TSAG.E_UI_Game extends TSAG.E_UI

    constructor: (@scene) ->

        super(@scene)

        @createButtons()
        @createStaticObjects()
        @changeMessageText("Default Message")

    createButtons: () ->

        # First we will retrieve a reference to the mouse controller,
        # which will be used in the button action calls.
        @mouse_controller = @scene.get_io_mouse()

        # -- Tools Controllers extracted from input tree.
        
        @controller_build_road = @mouse_controller.getRoadBuild()
        @controller_build_road.setActive(false)
        ###
        @controller_demolish_road = mouse_controller.getRoadDestroy()
        @controller_demolish_road.setActive(false)
        ###

        @controller_highlight = mouse_controller.getHighlight()
        @controller_highlight.setActive(false)

        @controller_stats = mouse_controller.getStats()
        @controller_stats.setActive(false)

        # -- Tool Button Meshes for visual display.
        view = @getVisual()

        dim_road_button  = {x: 16, y:32, w:64, h:64}
        @img_road_button = TSAG.style.newSprite("images/road.png", dim_road_button)
        view.add(@img_road_button)

        dim_stats_button  = {x: 16, y:96, w:64, h:64}
        @img_stats_button = TSAG.style.newSprite("images/stats.png", dim_stats_button)
        view.add(@img_stats_button)

        # 64 pixels offset in the y direction.
        dim_highlight_button  = {x: 16, y:160, w:64, h:64}
        @img_highlight_button = TSAG.style.newSprite("images/stats.png", dim_stats_button)
        view.add(@img_stats_button)

        # -- Tool Button collision detection.
        pline_road_button      = BDS.Polyline.newRectangle(dim_road_button)
        pline_stats_button     = BDS.Polyline.newRectangle(dim_stats_button)
        pline_highlight_button = BDS.Polyline.newRectangle(dim_highlight_button)

        # Modification functions.
        ###
        # Future road type selection
        func_build_road_local     = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_local
            @controller_build_road.setMode(mode)

        func_build_road_collector = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_collector
            @controller_build_road.setMode(mode)

        func_build_road_artery    = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_artery
            @controller_build_road.setMode(mode)
        ###

        func_build_road = () ->
            @mouse_controller.deactivateTools()
            @controller_build_road.setActive(true)

        func_stats = () ->
            @mouse_controller.deactivateTools()
            @controller_build_road.setActive(true)

        func_highlight = () ->
            @mouse_controller.deactivateTools()
            @controller_highlight.setActive(true)


        @createButton(pline_road_button,      @img_road_button.material,      func_build_road)
        @createButton(pline_stats_button,     @img_stats_button.material,     func_stats)
        @createButton(pline_highlight_button, @img_highlight_button.material, func_highlight)


    createStaticObjects: () ->

        view = @getVisual()

        # Center of rectangle aligned.
        left_border = @_createRectangle({fill: 0x808080, x: 0, y: 0, w:96, h:800, depth:-7})
        view.add(left_border)

        @img_cost_label = TSAG.style.newSprite("images/cost.png", {x: 0, y:704, w:96, h:96})
        view.add(@img_cost_label)

        # center of rectangle aligned.
        bottom_border = @_createRectangle({fill: 0x808080, x: 0, y: 800 - 16, w:1200, h:16, depth:-6})
        view.add(bottom_border)

        cost_display = @_createRectangle({fill: 0xffffff, x: 64, y: 800 - 16 - 50, w:256, h:50, depth:-5})
        view.add(cost_display)

        @info_message_display = @_createRectangle({fill: 0x0000ff, x: 64 + 256, y: 800 - 66, w:520, h:66, depth:-5})
        view.add(@info_message_display)

        @info_message_text = new THREE.Object3D()
        @info_message_text.position.x = 335
        @info_message_text.position.y = 800 - 60
        view.add(@info_message_text)


        img_happy_label = TSAG.style.newSprite("images/happy_face.png", {x: 830, y:800 - 96, w:96, h:96})
        view.add(img_happy_label)

        img_sad_label = TSAG.style.newSprite("images/sad_face.png", {x: 1200 - 96, y:800 - 96, w:96, h:96})
        view.add(img_sad_label)

        happiness_display = @_createRectangle({fill: 0xb0efcd, x: 900, y: 800 - 66, w:154, h:50, depth:-5})
        view.add(happiness_display)

        sadness_display = @_createRectangle({fill: 0xeec3c3, x: 1058, y: 800 - 66, w:60, h:50, depth:-5})
        view.add(sadness_display)



    ###

    Interface Routines. - What can the ui do?

    ###

    # Broadcast a UI message to the user.
    # params: {type:, element:}
    # type: {'info':, 'error'}
    # element: contains an element that may be colored to reflect this message.
    message: (str, params) ->
        if params.type == 'info'
            @info_message_display.revertFillColor()
        
            if params.element
                params.element.revertFillColor()

        if params.type == 'action'
            @info_message_display.setFillColor(TSAG.style.action)

            if params.element
                params.element.setFillColor(TSAG.style.action)

        else if params.type == 'error'
            @info_message_display.setFillColor(TSAG.style.error)

            if params.element
                params.element.setFillColor(TSAG.style.error)

        @changeMessageText(str)

    changeMessageText: (str) ->
        # Clear all children.
        @info_message_text.children = []

        TSAG.style.newText({font: TSAG.style.font
                            ,height: 16
                            ,fill_color: 0xff000000
                            #,outline_color: 0xffffff
                            ,message: str
                            ,out:@info_message_text})

    # Flash the ui message to blue, it will revert back to its proper state in time.
    flash: () ->

        @info_message_display.setFillColor(TSAG.style.highlight)