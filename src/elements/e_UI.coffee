###
    SimUrban User Interface Object.
    Written by Bryce on 4.6.2017
    
    Purpose: This class organizes the drawing and functionality for all of the static user interface elements,
        such as windows, buttons, etc.

        This class also handles the text based display of information to the users.
###

class TSAG.E_UI extends TSAG.E_Super

    constructor: (@controller_ui) ->

        super()


        @createUIObjects()


    createUIObjects: () ->

        view = @getVisual()

        @img_road_button = TSAG.style.newSprite("images/road.png", {x: 16, y:32, w:64, h:64})
        view.add(@img_road_button)

        @img_stats_button = TSAG.style.newSprite("images/stats.png", {x: 16, y:96, w:64, h:64})
        view.add(@img_stats_button)

        # Center of rectangle aligned.
        left_border = @createRectangle({fill: 0x808080, x: 0, y: 0, w:96, h:800, depth:-7})
        view.add(left_border)

        @img_cost_label = TSAG.style.newSprite("images/cost.png", {x: 0, y:704, w:96, h:96})
        view.add(@img_cost_label)

        # center of rectangle aligned.
        bottom_border = @createRectangle({fill: 0x808080, x: 0, y: 800 - 16, w:1200, h:16, depth:-6})
        view.add(bottom_border)

        cost_display = @createRectangle({fill: 0xffffff, x: 64, y: 800 - 16 - 50, w:256, h:50, depth:-5})
        view.add(cost_display)

        info_message_display = @createRectangle({fill: 0x0000ff, x: 64 + 256, y: 800 - 66, w:520, h:66, depth:-5})
        view.add(info_message_display)

        img_happy_label = TSAG.style.newSprite("images/happy_face.png", {x: 830, y:800 - 96, w:96, h:96})
        view.add(img_happy_label)

        img_sad_label = TSAG.style.newSprite("images/sad_face.png", {x: 1200 - 96, y:800 - 96, w:96, h:96})
        view.add(img_sad_label)

        happiness_display = @createRectangle({fill: 0xb0efcd, x: 900, y: 800 - 66, w:154, h:50, depth:-5})
        view.add(happiness_display)

        sadness_display = @createRectangle({fill: 0xeec3c3, x: 1058, y: 800 - 66, w:60, h:50, depth:-5})
        view.add(sadness_display)


    # {fill:, x:, y:, w:, h:, depth}
    # x and y of top left corner.
    createRectangle: (params) ->
        rect = TSAG.style.unit_meshes.newSquare({color: new THREE.Color(params.fill)})
        rect.scale.x = params.w
        rect.scale.y = params.h
        rect.position.x = params.x + params.w/2
        rect.position.y = params.y + params.h/2
        rect.position.z = params.depth

        return rect

        ###
        mesh.scale.x = 200
        mesh.scale.y = 200
        

        view.add(mesh)

        window.mesh = mesh
        ###


        # -- Tools Controllers extracted from input tree.
        ###
        @controller_build_road = 
        @controller_build_road.setActive(false)
        @controller_demolish_road = 
        @controller_demolish_road.setActive(false)
        ###


        ###
        # -- Tools UI Buttons.
        b1 = new BDS.Box(new BDS.Point(0,   0),
                         new BDS.Point(64, 64));

        b2 = new BDS.Box(new BDS.Point(64,   0),
                         new BDS.Point(128, 64));

        b3 = new BDS.Box(new BDS.Point(128,  0),
                         new BDS.Point(192, 64));

        p1 = b1.toPolyline()
        p2 = b2.toPolyline()

        # Modification functions.
        func_build_road_local     = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_local
            @controller_build_road.setMode(mode)

        func_build_road_collector = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_collector
            @controller_build_road.setMode(mode)

        func_build_road_artery    = () ->
            mode = TSAG.I_Mouse_Build_Road.mode_artery
            @controller_build_road.setMode(mode)

        img_build_road_local     = null # Load Local road building image.
        img_build_road_collector = null # Load Collector road building image.
        img_build_road_artery    = null # Load Arterial road building image.

        @controller_ui.createButton(p1, func_build_road_local,     img_build_road_local)
        @controller_ui.createButton(p2, func_build_road_collector, img_build_road_collector)
        @controller_ui.createButton(p2, func_build_road_artery,    img_build_road_artery)
        ###