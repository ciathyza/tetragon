/*
 * Tetragon Default HTML Wrapper Javascript
 * http://www.tetragonengine.com/
 */

/* Set handler that is called when HTML is ready. */
$(document).ready(onDocumentReady);

/* beforeunload is better, but not available in every browser,
 * listen to both events and react only to the first to trigger. */
$(window).bind("beforeunload", onPageUnload);
$(window).bind("unload", onPageUnload);

/* Listen for the changeLocaleEvent which gets dispatched when the
 * user clicks on the language interaction elements. */
$(document).bind("changeLocaleEvent", onLocaleChange);


//-----------------------------------------------------------------------------------------
// Properties
//-----------------------------------------------------------------------------------------

var isUnloadNotified = false;
var jsReady = false;
var focusRef;


//-----------------------------------------------------------------------------------------
// Public Methods
//-----------------------------------------------------------------------------------------

/**
 * Returns the Flash Player version string.
 * 
 * @returns {String}
 */
function getFlashPlayerVersion()
{
	var v = swfobject.getFlashPlayerVersion();
	var output = "Flash Player: " + v.major + "." + v.minor + "." + v.release;
	return output;
}


/**
 * Accessor for Flash to determine when JS calls can be made.
 * 
 * @returns {Boolean}
 */
function isJSReady()
{
	return jsReady;
}


//-----------------------------------------------------------------------------------------
// Callback Handlers
//-----------------------------------------------------------------------------------------

/**
 * Called when the docxument is fully loaded and ready.
 */
function onDocumentReady()
{
	/* Restore last set locale from the cookie if available. */
	if ($.cookie("locale"))
	{
		$(document).trigger(
		{
			type: "changeLocaleEvent",
			locale: $.cookie("locale")
		});
	};
	
	/* Hook up event listener for the sound on/off button on the page. */
	$("#sound a").click(onSoundButtonClick);
	
	/* Hook up event listener the language buttons on the page. */
	$("#locale a").click(onLocaleLinkClick);
	
	/* Display Flash Player- & Browser Info */
	$("#flash_info").html(getFlashPlayerVersion);
	$("#useragent_info").html(navigator.userAgent);
	
	/* Set flag to determine that JS is ready. */
	jsReady = true;
}


/**
 * Called when the Flash content has been embedded.
 * 
 * @param e
 */
function onFlashContentEmbedded(e)
{
	focusRef = e.ref;
}


/**
 * Called when the Flash content has been loaded.
 */
function onFlashContentLoaded()
{
	focusRef.focus();
}


/**
 * Called when the sound button is clicked.
 * @param e
 */
function onSoundButtonClick(e)
{
	e.preventDefault();
	var flashObj = getFlashObject();
	if (flashObj && flashObj['toggleSound'])
	{
		$(this).toggleClass("active");
		var image = $(this).children("img");
		if (image.attr("src") == "../img/sound_on.png")
		{
			image.attr("src", "../img/sound_off.png");
		}
		else
		{
			image.attr("src", "../img/sound_on.png");
		}
		flashObj.toggleSound();
	}
}


/**
 * Called when a locale link is clicked.
 * @param e
 */
function onLocaleLinkClick(e)
{
	e.preventDefault();
	$(document).trigger(
	{
		type: "changeLocaleEvent",
		locale: $(this).attr("title").toLowerCase()
	});
}


/**
 * Handles the locale change event. It updates the page to highlight the selected
 * locale and notifies the flash movie that the locale has been changed.
 * 
 * @param e
 */
function onLocaleChange(e)
{
	var flashObj = getFlashObject();
	
	/* Change the active locale of the flash object. */
	if (flashObj && flashObj['changeLocale'])
	{
		flashObj.changeLocale(e.locale);
	}
	
	/* Remove the active-class from the all tabs, add it to the current language. */
	$("#locale a.active").removeClass('active');
	$("#locale a." + e.locale).addClass('active');
	
	/* Change alert message if no flash. */
	if ($("#noflash-message div"))
	{
		$("#noflash-message div").addClass('hidden');
		$("#noflash-message div." + e.locale).removeClass('hidden');
	}
	
	/* Update the URL with the selected language. */
	if (window.history && window.history.pushState)
	{
		window.history.pushState(
		{
			locale: e.locale
		}, document.title, "?locale=" + e.locale);
	}
	
    /* Sets a cookie to remember the language use. */
    $.cookie("locale", e.locale);
}


/**
 * Handles the unload event and then notifies the Flash movie that the page
 * will be unloaded so that it can be shutdown.
 * 
 * @param e the event to handle.
 */
function onPageUnload(e)
{
	if (!isUnloadNotified)
	{
		var flashObj = getFlashObject();
		if (flashObj && flashObj['unload']) flashObj.unload();
		isUnloadNotified = true;
	}
}


/*
 * Callback handler that are being called from within Flash to provide
 * build information.
 */
function onSWFVersionNumber(v)
{
    $("#version").html(v);
}
function onSWFBuildNumber(v)
{
    $("#buildnr").html(v);
}
function onSWFBuildDate(v)
{
    $("#builddate").html(v);
    $('#swf-loading-info p').fadeIn("slow");
}
function onSWFIsDebugBuild(v)
{
    $("#isdebugbuild").html(v);
}
function onSWFConsoleKey(v)
{
    $("#consolekey").html(v);
}
function onSWFStatsKey(v)
{
    $("#statskey").html(v);
}
