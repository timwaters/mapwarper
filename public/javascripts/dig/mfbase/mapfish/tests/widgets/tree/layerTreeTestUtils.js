// globals
var gMap, gTree, gModel;

// TODO: add a getNodeByParentAndText to handle duplicates

function getNodeByText(root, text) {
    var retNode;
    root.cascade(function (node) {
        if (node.text == text) {
            retNode = node;
            return false;
        }
    });
    return retNode;
}

function createMap() {
    // FIXME: good default options?
    var options = {
        projection: "EPSG:4326",
        controls: [new OpenLayers.Control.MouseDefaults()] ,
        'numZoomLevels': 20
    };

    var map = new OpenLayers.Map("map", options);

    // for debugging
    map.addControl(new OpenLayers.Control.LayerSwitcher());

    gMap = map;
    return map;
}

function createTree(map, model, options) {
    var treeArgs = {map: map, el: 'tree', model: model};
    if (options)
        Ext.apply(treeArgs, options);
    var tree = new mapfish.widgets.LayerTree(treeArgs);
    gTree = tree;
    tree.render();
    return tree;
}

function resetTree() {
    gTree.destroy();
    Ext.get("right").createChild({tag: "div", id: "tree"});
}

function reset() {
    gMap.destroy();
    resetTree();
}

// Check the status of the LayerTree current tree
function checkStatus(t, tree, expectedStatus) {
    var nodes = [];
    tree.getRootNode().cascade(function (node) {
        nodes.push(node);
    });
    t.eq(nodes.length, expectedStatus.length, "Correct number of nodes in tree");

    for (var i = 0; i < expectedStatus.length; i++) {
        var node = nodes[i];
        var expectProps = expectedStatus[i];

        var formType = null;
        if (expectProps.radio !== undefined) {
            formType = expectProps.radio ? "radio" : "checkbox";
            delete expectProps.radio;
        } else if (expectProps.attr_checked !== undefined) {
            formType = "checkbox";
        }
        if (formType) {
            if (node.ui && node.ui.checkbox)
                t.eq(node.ui.checkbox.type, formType, "Form of node " +
                     node.attributes.text + " is of correct type");
            else
                // dummy check so that the number of assertion does not depend
                // on the availability of the checkbox node
                t.ok(true, "dummy check");
        }

        for (var p in expectProps) {
            var toTest = node;
            var expect = expectProps[p];

            // Special handling for node.attributes properties
            var matches = p.match(/^attr_(.*)/);
            if (matches) {
                p = matches[1];
                toTest = node.attributes;
            }
            t.eq(toTest[p], expect, "Node " + node.text + " has a property " +
                                    p + " with correct value");
        }
    }
}

// Checks the status of the OpenLayer map layers
function checkOlStatus(t, map, expectedOlStatus) {
    var layerMap = {};
    t.eq(map.layers.length, expectedOlStatus.length, "Map has correct number of layers");

    for (var i = 0; i < expectedOlStatus.length; i++) {
        var layer = map.layers[i];
        var expectProps = expectedOlStatus[i];

        for (var p in expectProps) {

            // Special properties handling

            if (p == "subLayers") {
                var wmsLayers = expectProps[p];
                var layersPropertyNameInParams = layer.params.LAYERS !== undefined ?
                                                 layer.params.LAYERS : layer.params.layers;
                t.eq(layersPropertyNameInParams, wmsLayers, "subLayers are correct");
                continue;
            }

            t.eq(layer[p], expectProps[p], "Layer " + layer.name + " has a property " +
                           p + " with correct value");
        }
    }
}


// Standalone testing without Test.AnotherWay
Ext.onReady(function() {
    if (location.search.indexOf("standalone") == -1)
        return;

    var t = {
        count: 0,
        fail: function(msg, test) {
                document.body.style.backgroundColor = "red";
                if (console && console.trace)
                    console.trace();
                throw new Error("Test failure: " + msg + " : " + test);
        },
        eq: function(value, expect, msg, noIncrement) {
            if (!noIncrement)
                this.count++;
            console.info(msg);

            // XXX constructor.name is not working on Opera
            //if (value.length != undefined) {
            if (value && value.constructor &&
                value.constructor.name == "Array")
            {
                this.eq(value.length, expect.length, msg, true);
                for (var i = 0; i < expect.length; i++)
                    this.eq(value[i], expect[i], msg, true);
                return;
            }

            if (expect != value) {
                this.fail("got: " + value + " while expecting " + expect, msg);
            }
        },
        ok: function(value, msg) {
            this.count++;
            console.info(msg);
            if (!value) {
                this.fail("Not ok", msg);
            }
        },
        plan: function(n) { console.log("Planning " + n + " test"); }
    };

    for (var i = 0; i < gTests.length; i++) {
        gTests[i].call(this, t);
    }

    console.info("Done: " + t.count + " tests");
});

