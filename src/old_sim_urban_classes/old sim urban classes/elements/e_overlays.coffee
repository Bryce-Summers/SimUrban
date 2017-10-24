###
    Sim Urban Overlays
    Written by Bryce on May.4.2017
    
    Purpose: This class provides functions for mapping visual data displays across the screen.
        It also provides functions for producing custom sized geometries.
        - produce overlays.
        - Reset the screen to the normal aesthetic.
###

class TSAG.E_Overlays extends TSAG.E_Super

    constructor: () ->

        super()

        view = @getVisual()

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

    # Add visuals, like the cursor, which should never be removed.
    addPermanentVisual: (mesh) ->
        view = @getVisual()
        view.add(mesh)