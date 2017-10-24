###
#
# Element interface class.
#
# Written by Bryce Summers on 10.23.2017
#
# A Game element consists of the following:
# - Model that represents fundamental game state.
# - Representations that provide information to the user about the model.
#
# Representations include:
# Visual: Provide spatial information, decoration, character, etc.
# Auditory: Provide mood, quick feedback, etc.
# Interfacial: A representation of collision geometry, etc. that allows the user to provide inputs that influence the model.
#
# Element classes are responsible for providing useful features for building various common combinations of models and representations,
# such as a path tied to a polygon, tied to a collision geometry.
#
# There is only ever 1 model, but there can be many elements.
###

class TSAG.Element

    constructor: (@model) ->

        # View is used for inclusion in container.
        @_view = new THREE.Object3D()

        # visual is used to build the actual representation.
        @_visual = null

    # Returns a representation of this element.
    getVisualRepresentation: () ->
        return @_visual

    setVisualRepresentation: (visual) ->
        @_visual = visual
        @_view.remove(@_visual) # Remove old visual.
        @_view.add(@_visual)
        return

    getAudioRepresentation: () ->
        console.log("Please Implement me!")

    # True or false, is this element allowed to be modified?
    allowMutations: () ->
        console.log("Please Implement me!")

    # UI_Object: Returns a UI object allowing for the configuration of this element.
    getUIWindow: () ->
        console.log("Please Implement me!")
