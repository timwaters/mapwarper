/*
 * Copyright (C) 2007-2008  Camptocamp
 *
 * This file is part of MapFish Client
 *
 * MapFish Client is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapFish Client is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MapFish Client.  If not, see <http://www.gnu.org/licenses/>.
 */


/*
 * @requires core/Searcher.js
 * @requires OpenLayers/Util.js
 */

/**
 * Class: mapfish.Searcher.Form
 * Use this class to create a form searcher. A form searcher
 * gets search criteria from an HTML form and sends search
 * requests through Ajax.
 *
 * Inherits from:
 * - mapfish.Searcher
 */
mapfish.Searcher.Form = OpenLayers.Class(mapfish.Searcher, {

    /**
     * APIProperty: protocol
     * {<OpenLayers.Protocol>} - The protocol.
     */
    protocol: null,

    /**
     * APIProperty: form
     * {DOMElement} The form node.
     */
    form: null,

    /**
     * Property: response
     * {<OpenLayers.Protocol.Response>} The response returned by the
     *     read call to <OpenLayers.Protocol> object.
     */
    response: null,

    /**
     * Constructor: mapfish.Searcher.Form
     *
     * Parameters:
     * options {Object} Optional object whose properties will be set on the
     *     instance.
     *
     * Returns:
     * {<mapfish.Searcher.Form>}
     */
    initialize: function(options) {
        mapfish.Searcher.prototype.initialize.call(this, options);
        OpenLayers.Util.extend(this, options);
        if (!this.form) {
            OpenLayers.Console.error("no form set");
            return;
        }
        if (!this.protocol) {
            OpenLayers.Console.error("no protocol set");
            return;
        }
    },

    /**
     * APIMethod: triggerSearch
     *      To be called to trigger search.
     */
    triggerSearch: function() {
        this.protocol.abort(this.response);
        this.response = this.protocol.read(
            {filter: this.getFilter(), searcher: this});
    },

    /**
     * Method: getFilter
     *      Get the search filter.
     *
     * Returns:
     * {Object} The filter.
     */
    getFilter: function() {
        var i;
        var params = {};
        var form = this.form;
        /* process <input> elements */
        var inputElements = form.getElementsByTagName('input');
        for (i = 0; i < inputElements.length; i++) {
            // Collect the current input only if it's is not 'submit', 'image'
            // or 'button'
            currentElement = inputElements.item(i);
            if (currentElement.disabled == true) {
                continue;
            }
            var inputType = currentElement.getAttribute('type');
            if (inputType == 'radio' || inputType == 'checkbox') {
                if (currentElement.checked) {
                    params = OpenLayers.Util.extend(
                        params, this.getParamsFromInput(currentElement));
                }
            } else if (inputType == 'submit' ||
                       inputType == 'button' ||
                       inputType == 'image') {
                // Do nothing. Sending the submit inputs in POST Request would
                // make the serverside act like all buttons on the form were
                // clicked.  And we don't want that.
            } else {
                params = OpenLayers.Util.extend(
                    params, this.getParamsFromInput(currentElement));
            }
        }
        /* process <select> elements */
        var selectElements = form.getElementsByTagName('select');
        for (i = 0; i < selectElements.length; i++) {
            // Get the param name (i.e. fetch the name attr)
            var currentElement = selectElements.item(i);
            var paramName = currentElement.getAttribute('name');
            // Get the param value(s)
            // (i.e. fetch the checked options element's value attr)
            var optionElements = currentElement.getElementsByTagName('option');
            for (var j = 0; j < optionElements.length; j++) {
                currentElement = optionElements.item(j);
                if (currentElement.selected) {
                    var paramValue = currentElement.getAttribute('value');
                    if (paramValue == null) {
                        paramValue = '';
                    }
                    var param = {};
                    param[paramName] = paramValue;
                    params = OpenLayers.Util.extend(params, param);
                }
            }
        }
        return OpenLayers.Util.extend(this.params, params);
    },

    /**
     * Method: getParamsFromInput
     *      Build a request string from an input element.
     *
     * Parameters:
     * htmlElement - {DOMElement}
     *
     * Returns:
     * {String} Request string (elementName=elementValue)
     */
    getParamsFromInput: function(htmlElement) {
        var paramValue;
        var inputType = htmlElement.getAttribute('type');
        var paramName = htmlElement.getAttribute('name');
        if (inputType == 'text') {
            paramValue = htmlElement.value;
        } else {
            paramValue = htmlElement.getAttribute('value');
        }
        var ret = new Object();
        if (paramValue != null) {
             ret[paramName] = paramValue;
        } else {
            // HTTP POST requests parameters HAVE TO be followed by '='
            // even when they have no associated value
            ret[paramName] = null;
        }
        return ret;
    },

    CLASS_NAME: "mapfish.Searcher.Form"
});
