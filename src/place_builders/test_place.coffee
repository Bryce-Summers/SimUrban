###
#
# Model Interface Class.
# This specifies properties of all element objects.
#
# Written by Bryce Summers on 10.23.2017
###

class TSAG.Test_Place extends TSAG.Place_Element

    # Builds a test place.
    constructor: () ->

        super(new TSAG.Place_Model())


        place_model = new TSAG.Place_Model()

        pts = [new BDS.Point(0, 0), new BDS.Point(100, 0), new BDS.Point(100, 100), new BDS.Point(0, 100)]
        square = new BDS.Polyline(true, pts)

        square_mesh = EX.Visual_Factory.newPolygon(square, new THREE.Color(1, 0, 0))

        square_place = new TSAG.Place_Element(place_model)
        square_place.setVisualRepresentation(square_mesh)

        @addPlace(square_place)