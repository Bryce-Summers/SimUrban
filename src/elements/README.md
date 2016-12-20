# Elements README

'e' stands for element.

Elements specify semantic elements for the game that have states, visual representations, etc.
Elements are housed in structural classes and are able to access those classes to locate other elements.
Elements are acted upon by the input classes.

Every Element class must contain a 'view' object that points to a THREE.js scene graph node.
(Typically a THREE.Scene or THREE.Object3 node)

These element classes will then provide a function called getVisual() that returns the element's associated scene graph node.
Some classes, such as the transportation network will provide functionality to rediscretize the view based on a particular viewport.