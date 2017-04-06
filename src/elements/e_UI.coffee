###
    SimUrban User Interface Object.
    Written by Bryce on 4.6.2017
    
    Purpose: This class organizes the drawing and functionality for all of the static user interface elements,
        such as windows, buttons, etc.

        This class also handles the text based display of information to the users.
###

class TSAG.E_UI extends TSAG.E_Super

    constructor: () ->

        super()

        @controller_ui = new BDS.Controller_UI(canvas_G)

        # -- Tools Controllers extracted from input tree.
        @controller_build_road = 
        @controller_build_road.setActive(false)
        @controller_demolish_road = 
        @controller_demolish_road.setActive(false)

        # -- Tools UI Buttons.
        b1 = new BDS.Box(new BDS.Point(0,   0),
                         new BDS.Point(64, 64));

        b2 = new BDS.Box(new BDS.Point(64,   0),
                         new BDS.Point(128, 64));

        b3 = new BDS.Box(new BDS.Point(128,  0),
                         new BDS.Point(192, 64));

        p1 = b1.toPolyline()
        p2 = b2.toPolyline()

        func_build_road_local     = () ->
        func_build_road_collector = () ->
        func_build_road_artery    = () ->

        img_build_road_local     = null # Load Local road building image.
        img_build_road_collector = null # Load Collector road building image.
        img_build_road_artery    = null # Load Arterial road building image.

        controller_ui.createButton(p1, func_build_road_local,     img_build_road_local);
        controller_ui.createButton(p2, func_build_road_collector, img_build_road_collector);
        controller_ui.createButton(p2, func_build_road_artery,    img_build_road_artery);