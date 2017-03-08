#
# Transportation Network.
#
# Written by Bryce Summers   on 12 - 18 - 2016.
# Rewritten by Bryce Summers on 1 - 26 - 2017.
#
# Purpose:
# This class represents a connected transportation network and provides gameplay functionality and rendering capabilities.
# Its functions are named according to gameplay uses, rather than mathematical imperatives.
# 
# This class represents all the urban systems linkages, rather than extraneous User Interfaces and such.
#
# This class spatially represents the various elements in a number of bounding volume hiearchies:
#
# 1. @line_bvh: A line segment bvh for network edge lookup, such as linear segments of roads.
#               This will be used to implement efficient road construction and road - road intersections.
# 2. @bvh: A face bvh, that stores bounding volumes for elements, e.g. Roads, intersections, Areas.
#    - FIXME: Every element should have its own internal BVH and they should only be represented by bounding boxes in this Network.
#    - Every Road element has a BVH for faces...
#    - Every Area has a BVH for elements contained within. This network is kind of like the root area.
#
#
# Elements are composed of 3 distinct structures:
# 1. @_view a THREE.JS Object tree, which controls what visuals are displayed to the user.
# 2. @_bvh, which is used for collision detection.
# 3. @_topology, which is used to represent the network connectivity between elements.
class TSAG.E_Network extends TSAG.E_Super

    # Takes in a SCRIB.Graph.
    constructor: () ->
    
        super()

        # We need a graph processor to make topology updates.
        @_topology_generator = new TSAG.PolylineGraphGenerator()
        graph = @_topology_generator.allocateGraph()
        @_topology_linker    = new SCRIB.TopologyLinker(@_topology_generator, graph)

        # Use the graph as this network's topology object.
        @setTopology(graph)

        # FIXME: We shouldn't need these, since they will be associated with topological elements.
        #@_intersections = []
        @_roads = []

    # Add a road to the explict list of roads.
    # I may use this for enumerating streets by name or something like that...
    addRoad: (road) ->
        @_roads.push(road)

    getRoads : () ->
        return @_roads

    getGenerator: () ->
        return @_topology_generator

    getLinker: () ->
        return @_topology_linker 

    # The network exposes an interface for the following kinds of actions:
    # From aa_e_super interface.
    # 1. addElement(e)         -> Adds the element's visual display and collision detection.
    # 2. removeElement(e)      -> Remove's the elements visual display and collision detection.
    #
    # 3. queryingElement(polygon()) -> Returns any element of the given type found inside the given world coordinate region.
    #
    # 4. linkElement(e)       -> Embeds the given element into the Network Topology.
    # 5. unlinkElement(e)     -> Removes the given element from the Network Topology.

    
    # Returns all elements that are found at the given point.
    query_elements_pt: (x, y) ->

        polylines = @_bvh.query_point_all(new BDS.Point(x, y))

        elements = []

        for polyline in polylines
            elements.push(polyline.getAssociatedData())

        return elements

    # BDS.Box -> TSAG.Element[]
    query_elements_box: (box) ->
    
        polylines = @_bvh.query_box_all(box)
        elements  = []

        for polyline in polylines
            elements.push(polyline.getAssociatedData())

        return elements