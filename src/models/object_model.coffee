###
    Written by Bryce Summers on 10.23.2017

    Objects are agents that try to do stuff. They carry along data, then sleep.

    Objects are responsible for determining when statistics ought to be logged,
    when plans should be created, and for following the rules.
###

class TSAG.Object_Model extends TSAG.Model

    constructor: (@scene) ->

        # Is the object model currently driving a process.
        @active = null

        # A mapping of variable names to values.
        @state = null
        #state['key'] = val.

        @statistics = null

        @navigation = null

        # The percentage of the current model that has been transversed.
        @percentage = 0

        @representation = null

    buildModel: () ->

        @statistics     = new TSAG.Statistics_Model()
        @navigation     = new TSAG.Navigation_Model()
        @representation = new TSAG.Representation(@)

        @percentage = 0
        @state = {}
        @active = false

    update: (dt) ->

        @navigation.move(dt)

    # Have the scene pass update commands to this object model.
    activate: () ->
        @scene.activateObject(@)
        @active = true

    deactivate: () ->
        @scene.deactivateObject(@)
        @active = false

    lookupKey: (key) ->
        return @state[key]

    setKey: (key, val) ->
        @state[key] = val
        return