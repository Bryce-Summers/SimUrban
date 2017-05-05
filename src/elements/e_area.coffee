###
#
# Area Element Class
# 
# Written by Bryce Summers on May.4.2017
#
# Purpose: This class represents an area.
#          This area has a number of people who want to get to other areas.
#          FIXME: I may remove this element of adapt it in future iterations after the IDM showcase.
#
# FIXME: Labeled city regions and areas representing faces may need to be decoupled.
###

class TSAG.E_Area extends TSAG.E_Super

    constructor: (polyline, label_str, url_to_stats_overlay) ->

        # images/stats_overlays/overlay_bronx.png
        # images/stats_overlays/overlay_queens.png
        # images/stats_overlays/overlay_brooklyn.png
        # images/stats_overlays/overlay_manhattan.png

        super()


        @stats_overlay = TSAG.style.newSprite(url_to_stats_overlay, {x: 0, y:0, w:1200, h:800})

        @area = polyline
        bounding_box = @area.ensureBoundingBox()

        view = @getVisual()
        
        mesh_factory = TSAG.style.unit_meshes

        mesh         = mesh_factory.newCircle({color: TSAG.style.c_normal})
        view.add(mesh)

        width  = (bounding_box.max.x - bounding_box.min.x)
        height = (bounding_box.max.y - bounding_box.min.y)

        center_x = (bounding_box.max.x + bounding_box.min.x)/2
        center_y = (bounding_box.max.y + bounding_box.min.y)/2

        mesh.position.x = center_x
        mesh.position.y = center_y
        mesh.position.z = -.7
        mesh.scale.x = width
        mesh.scale.y = height



        @text_label = new THREE.Object3D()
        view.add(@text_label)

        @text_label.position.x = center_x
        @text_label.position.y = center_y        

        TSAG.style.newText({font: TSAG.style.font
                            ,height: 12
                            ,fill_color: 0xff000000
                            #,outline_color: 0xffffff
                            ,message: label_str
                            ,out:@text_label
                            ,align_center:true})


    # Returns whether the given point is inside of this area.
    containsPoint: (pt) ->
        return @area.containsPoint(pt)

    display_stats: (view) ->
        view.add(@stats_overlay)

    hide_stats: (view) ->
        view.remove(@stats_overlay)