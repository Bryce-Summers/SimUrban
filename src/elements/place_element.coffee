#
# Place Elements handle the organization of all place content.
# Place elements only need pointers to those elements that they will change.

class TSAG.Place_Element extends TSAG.Element

    constructor: () ->

        @init()

    init: () ->

        # Specifies the features in a place.
        @_places = new Set() # Pointers to other place Elements.

        # Other elements.
        @_junctions  = new Set()
        @_conditions = new Set()
        @_paths      = new Set()
        @_operators  = new Set()


    # Changes the view to show 
    populateViewLevels: (levels, N) ->

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

    # Add and remove elements from this place element.
    addPlace:     (element) -> @_places.add(element)
    addJunction:  (element) -> @_junction.add(element)
    addCondition: (element) -> @_conditions.add(element)
    addPath:      (element) -> @_paths.add(element)
    addOperator:  (element) -> @_operators.add(element)

    removePlace:     (element) -> @_places.delete(element)
    removeJunction:  (element) -> @_junction.delete(element)
    removeCondition: (element) -> @_conditions.delete(element)
    removePath:      (element) -> @_paths.delete(element)
    removeOperator:  (element) -> @_operators.delete(element)