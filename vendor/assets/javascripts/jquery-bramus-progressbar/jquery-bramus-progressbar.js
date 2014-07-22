/*****************************************************************
 *
 * jquery-bramus-progressbar 0.1 - by Bramus! - http://www.bram.us/ - ported to jQuery by Darryl Pentz : djpentz@gmail.com
 *
 *
 * v 0.1   - 2012.04.17 - initial release
 *
 * @see http://www.barenakedapp.com/the-design/displaying-percentages on how to create a progressBar Background Image!
 *
 * Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
 *
 *****************************************************************/


/**
 * CONFIG
 * -------------------------------------------------------------
 */
(function (jQuery, window, document) {

    /**
     * JS_BRAMUS Object
     * -------------------------------------------------------------
     */
    if (!jQuery.JS_BRAMUS) {
        jQuery.JS_BRAMUS = new Object();
    }

    /**
     * ProgressBar Class
     * -------------------------------------------------------------
     */

    jQuery.JS_BRAMUS.JsProgressBar = function (elmt, percentage, options) {

        var base = this;

        /**
         * Datamembers
         * -------------------------------------------------------------
         */
        base.el = elmt;                         // Element where to render the progressBar in
        base.jQueryel = jQuery(elmt);                     // Element where to render the progressBar in
        base.id = base.jQueryel.attr('id');          // Unique ID of the progressbar
        base.percentage = 0;                    // Percentage of the progressbar
        base.initialPos = null;                 // Initial position of the background in the progressbar
        base.initialPerc = null;                // Initial percentage the progressbar should hold
        base.pxPerPercent = null;               // Number of pixels per 1 percent
        base.backIndex = 0;						// index in the array of background images currently used
        base.numPreloaded = 0;					// number of images preloaded
        base.running = false;					// is this one running (being animated) or not?
        base.queue = [];						// queue of percentages to set to

        base.init = function () {

            // get the options
            base.options = jQuery.extend({}, jQuery.JS_BRAMUS.JsProgressBar.defaultOptions, options);

            // datamembers which are calculated
            this.imgWidth = base.options.width * 2;		    // define the width of the image (twice the width of the progressbar)
            this.initialPos = base.options.width * (-1);	// Initial postion of the background in the progressbar (0% is the middle of our image!)
            this.pxPerPercent = base.options.width / 100;	// Define how much pixels go into 1%
            this.initialPerc = percentage;					// Store this, we'll need it later.

            // enforce backimage array
            if (!jQuery.isArray(base.options.barImage)) {
                base.options.barImage = [base.options.barImage];
            }

            // preload Images
            base.preloadImages();
        }


        /**
         * Preloads the images needed for the progressbar
         *
         * @return void
         * -------------------------------------------------------------
         */
        base.preloadImages = function () {

            // loop all barimages
            for (i = 0; i < this.options.barImage.length; i++) {

                // create new image ref
                var newImage = null;
                newImage = new Image();

                // set onload, onerror and onabort functions
                newImage.onload = function () {
                    this.numPreloaded++;
                }.bind(this);
                newImage.onerror = function () {
                    this.numPreloaded++;
                }.bind(this);
                newImage.onabort = function () {
                    this.numPreloaded++;
                }.bind(this);

                // set image source (preload it!)
                newImage.src = this.options.barImage[i];

                // image is in cache
                if (newImage.complete) {
                    this.numPreloaded++;
                }

            }

            base.checkPreloadedImages();
        }


        /**
         * Check whether all images are preloaded and loads the percentage if so
         *
         * @return void
         * -------------------------------------------------------------
         */

        base.checkPreloadedImages = function () {
            // all images are loaded, go init the visuals
            if (parseInt(base.numPreloaded, 10) >= parseInt(base.options.barImage.length, 10)) {

                // initVisuals
                this.initVisuals();

                // not all images are loaded ... wait a little and then retry
            } else {
                if (parseInt(base.numPreloaded, 10) <= parseInt(base.options.barImage.length, 10)) {
                    // jQuery(this.el).update(this.id + ' : ' + this.numPreloaded + '/' + this.options.barImage.length);
                    setTimeout(function () {
                        base.checkPreloadedImages();
                    }.bind(this), 100);
                }
            }

        }

        /**
         * Intializes the visual output and sets the percentage
         *
         * @return void
         * -------------------------------------------------------------
         */
        base.initVisuals = function () {

            // create the visual aspect of the progressBar
            jQuery(base.el).html(
                '<img id="' + base.id + '_percentImage" src="' + base.options.boxImage + '" alt="0%" style="width: ' + base.options.width + 'px; height: ' + base.options.height + 'px; background-position: ' + base.initialPos + 'px 50%; background-image: url(' + base.options.barImage[this.backIndex] + '); padding: 0; margin: 0;" class="percentImage" />' +
                    ((base.options.showText == true) ? '<span id="' + base.id + '_percentText" class="percentText">0%</span>' : ''));

            // set the percentage
            base.setPercentage(base.initialPerc);
        }

        /**
         * Sets the percentage of the progressbar
         *
         * @param string targetPercentage
         * @param boolen clearQueue
         * @return void
         * -------------------------------------------------------------
         */
        base.setPercentage = function (targetPercentage, clearQueue) {

            // if clearQueue is set, empty the queue and then set the percentage
            if (clearQueue) {

                base.percentage = (base.queue.length != 0) ? base.queue[0] : targetPercentage;
                base.timer = null;
                base.queue = [];

                setTimeout(function () {
                    base.setPercentage(targetPercentage);
                }.bind(this), 10);

                // no clearQueue defined, set the percentage
            } else {

                // add the percentage on the queue
                base.queue.push(targetPercentage);

                // process the queue (if not running already)
                if (base.running == false) {
                    base.processQueue();
                }
            }

        }

        /**
         * Processes the queue
         *
         * @return void
         * -------------------------------------------------------------
         */
        base.processQueue = function () {

            // stuff on queue?
            if (base.queue.length > 0) {

                // tell the world that we're busy
                base.running = true;

                // process the entry
                base.processQueueEntry(base.queue[0]);

                // no stuff on queue
            } else {
                // return;
            }
        }

        /**
         * Processes an entry from the queue (viz. animates it)
         *
         * @param string targetPercentage
         * @return void
         * -------------------------------------------------------------
         */
        base.processQueueEntry = function (targetPercentage) {

            // get the current percentage
            var curPercentage = parseInt(base.percentage, 10);

            // define the new percentage
            if ((targetPercentage.toString().substring(0, 1) == "+") || (targetPercentage.toString().substring(0, 1) == "-")) {
                targetPercentage = curPercentage + parseInt(targetPercentage);
            }

            // min and max percentages
            if (targetPercentage < 0)        targetPercentage = 0;
            if (targetPercentage > 100)        targetPercentage = 100;

            // if we don't need to animate, just change the background position right now and return
            if (base.options.animate == false) {

                // remove the entry from the queue
                base.queue.splice(0, 1);	// @see: http://www.bram.us/projects/js_bramus/jsprogressbarhandler/#comment-174878

                // Change the background position (and update this.percentage)
                base._setBgPosition(targetPercentage);

                // call onTick
                if (!base.options.onTick(this)) {
                    return;
                }

                // we're not running anymore
                base.running = false;

                // continue processing the queue
                base.processQueue();

                // we're done!
                return;
            }

            // define if we need to add/subtract something to the current percentage in order to reach the target percentage
            var newPercentage = 0;
            var callTick = true;
            if (targetPercentage != curPercentage) {
                if (curPercentage < targetPercentage) {
                    newPercentage = curPercentage + 1;
                } else {
                    newPercentage = curPercentage - 1;
                }
                callTick = true;
            } else {
                newPercentage = curPercentage;
                callTick = false;
            }

            // Change the background position (and update this.percentage)
            _setBgPosition(newPercentage);

            // call onTick
            if (callTick && !base.options.onTick(this)) {
                return;
            }

            // Percentage not reached yet : continue processing entry
            if (curPercentage != newPercentage) {

                base.timer = setTimeout(function () {
                    base.processQueueEntry(targetPercentage);
                }.bind(this), 10);

                // Percentage reached!
            } else {

                // remove the entry from the queue
                base.queue.splice(0, 1);

                // we're not running anymore
                base.running = false;

                // unset timer
                base.timer = null;

                // process the rest of the queue
                base.processQueue();

                // we're done!
            }
        }

        /**
         * Gets the percentage of the progressbar
         *
         * @return int
         */
        base.getPercentage = function () {
            return base.percentage;
        }

        /**
         * Set the background position
         *
         * @param int percentage
         */
        var _setBgPosition = function (percentage) {
            // adjust the background position
            jQuery("#" + base.id + "_percentImage").css('backgroundPosition', (base.initialPos + (percentage * base.pxPerPercent)) + "px 50%");

            // adjust the background image and backIndex
            var newBackIndex = Math.floor((percentage - 1) / (100 / base.options.barImage.length));

            if ((newBackIndex != base.backIndex) && (base.options.barImage[newBackIndex] != undefined)) {
                jQuery("#" + base.id + "_percentImage").css('backgroundImage', "url(" + base.options.barImage[newBackIndex] + ")");
            }

            base.backIndex = newBackIndex;

            // Adjust the alt & title of the image
            jQuery("#" + base.id + "_percentImage").attr('alt', percentage + "%");
            jQuery("#" + base.id + "_percentImage").attr('title', percentage + "%");

            // Update the text
            if (base.options.showText == true) {
                jQuery("#" + base.id + "_percentText").html("" + percentage + "%");
            }

            // adjust datamember to stock the percentage
            base.percentage = percentage;
        }

        base.init();
    }

    // Default Options
    jQuery.JS_BRAMUS.JsProgressBar.defaultOptions = {
        autoHook:true,
        animate:true, // Animate the progress? - default: true
        showText:true, // show text with percentage in next to the progressbar? - default : true
        width:120, // Width of the progressbar - don't forget to adjust your image too!!!
        boxImage : '/assets/progressbar/bramus/percentImage.png', // boxImage : image around the progress bar
        barImage : '/assets/progressbar/bramus/percentImage_back3.png', // Image to use in the progressbar. Can be an array of images too.
        height:12, // Height of the progressbar - don't forget to adjust your image too!!!
        onTick:function (pbObj) {
            return true
        }
    }

})(jQuery, window, document);