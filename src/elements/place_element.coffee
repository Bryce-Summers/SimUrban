#
# Place Elements handle the organization of all place content.
# Place elements only need pointers to those elements that they will change.
#

class TSAG.Place_Element extends TSAG.Element

    constructor: (model) ->

        super(model)

        @init()

    init: () ->

        # Specifies the features in a place.
        @_places = new Set() # Pointers to other place Elements.

        # Other elements.
        @_junctions  = new Set()
        @_conditions = new Set()
        @_paths      = new Set()
        @_operators  = new Set()

        @_visual_places     = new THREE.Object3D()
        @_visual_junctions  = new THREE.Object3D()
        @_visual_paths      = new THREE.Object3D()
        @_visual_operators  = new THREE.Object3D()
        @_visual_conditions = new THREE.Object3D()


    # Changes the view to show 
    populateViewLevels: (levels, N) ->

        levels[1].add(@_visual_places)
        levels[1].add(@_visual_junctions)
        levels[2].add(@_visual_paths)

        levels[3].add(@_visual_operators)
        levels[3].add(@_visual_conditions)

        ###
        @_places.forEach (element) =>
            levels[1].add(element.getVisualRepresentation())

        @_junctions.forEach (element) =>
            levels[1].add(element.getVisualRepresentation())

        @_paths.forEach (element) =>
            levels[2].add(element.getVisualRepresentation())

        @_operators.forEach (element) =>
            levels[3].add(element.getVisualRepresentation())
        @_conditions.forEach (element) =>
            levels[3].add(element.getVisualRepresentation())
        ###

    # Add and remove elements from this place element.
    addPlace:     (element) ->
        @_places.add(element)
        @_visual_places.add(element.getVisualRepresentation())

    addJunction:  (element) ->
        @_junction.add(element)
        @_visual_junctions.add(element.getVisualRepresentation())

    addCondition: (element) ->
        @_conditions.add(element)
        @_visual_conditions.add(element.getVisualRepresentation())

    addPath:      (element) ->
        @_paths.add(element)
        @_visual_paths.add(element.getVisualRepresentation())

    addOperator:  (element) ->
        @_operators.add(element)
        @_visual_operators.add(element.getVisualRepresentation())


    removePlace:     (element) ->
        @_places.delete(element)
        @_visual_places.remove(element.getVisualRepresentation())

    removeJunction:  (element) ->
        @_junction.delete(element)
        @_visual_junctions.remove(element.getVisualRepresentation())

    removeCondition: (element) ->
        @_conditions.delete(element)
        @_visual_conditions.remove(element.getVisualRepresentation())

    removePath:      (element) ->
        @_paths.delete(element)
        @_visual_paths.remove(element.getVisualRepresentation())

    removeOperator:  (element) ->
        @_operators.delete(element)
        @_visual_operators.remove(element.getVisualRepresentation())