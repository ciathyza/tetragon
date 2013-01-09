<?php
$locale_ids = array(@web_locale_ids@);
$locale_names = array(@web_locale_names@);
if (!empty($_GET["locale"])) $locale_selected = $_GET["locale"];
else $locale_selected = "en";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
	    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
	    <meta http-equiv="imagetoolbar" content="no"/>
	    <meta name="author" content="Nothing"/>
	    <meta name="publisher" content="Nothing"/>
		<meta name="copyright" content="@app_copyright@"/>
	    <meta name="rating" content="general"/>
	    <meta name="distribution" content="global"/>
	    <meta name="robots" content="index, follow, noodp"/>
	    <meta name="revisit" content="5 days"/>
		<meta name="description" lang="@app_language@" content="@app_description@"/>
	    <meta name="content-language" content="@app_language@"/>
		<meta name="keywords" content="@app_tags@"/>
		<meta name="google" content="notranslate"/>
		
	    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
	    <link type="text/css" href="css/style.css" charset="iso-8859-1" rel="stylesheet" rev="stylesheet" media="screen">
		
		<script type="text/javascript" src="@js_path@/swfobject.js"></script>
		<script type="text/javascript" src="@js_path@/jquery.min.js"></script>
		<script type="text/javascript" src="@js_path@/jquery.cookie.js"></script>
		<script type="text/javascript" src="@js_path@/tetragon.js"></script>
		
		<script type="text/javascript">
			var flashvars =
			{
				skipPreloader: "@web_skippreloader@",
				ignoreIniFile: "@web_ignoreinifile@",
				ignoreLocaleFile: "@web_ignorelocalefile@",
				useAbsoluteFilePath: "false",
				loggingVerbose: "false",
				basePath: "",
				locale: ""
			};
			var params =
			{
				allowScriptAccess: "@web_allowscriptaccess@",
				allowFullScreen: "@web_allowfullscreen@",
				allowFullscreenInteractive: "@web_allowFullscreenInteractive@",
				wmode: "@web_wmode@",
				quality: "@web_quality@",
				bgcolor: "@web_bgcolor@"
			};
			var attributes =
			{
				id: "@app_id@",
				name: "@app_shortname@",
				align: "middle"
			};
			function getFlashObject()
			{
				return document['@app_id@'];
			}
			swfobject.embedSWF("@app_swfname@", "flashContent", "@web_width@", "@web_height@", "@fpv_version@", false, flashvars, params, attributes, onFlashContentEmbedded);
        </script>
        
		<title>@app_name@</title>
	</head>
	<body>
		<div id="wrapper">
			<div id="content">
				<h1>@app_name@</h1>
				<div id="header">
					<?php
					if (count($locale_ids) > 1)
					{
						echo '<div id="locale">';
						for ($i = 0; $i < count($locale_ids); ++$i)
						{
							$id = $locale_ids[$i];
							$name = $locale_names[$i];
							$active = ($id == $locale_selected) ? ' active' : '';
							echo '<a href="index.php?locale=' . $id . '" title="' . $id . '" class="' . $id . $active .'">' . $name . '</a>';
						}
						echo '</div>';
					}
					?>
				</div>
				<div id="middle">
					<div id="swfarea">
						<div id="flashContent">
							<div class="meta-header" id="noflash-message">
								<div class="en">
									<p>This website requires Flash Player @fpv_version@. To download Flash Player <a href="http://www.adobe.com/go/getflashplayer" target="_blank">click here</a>. Please note that JavaScript must be active in your browser.</p>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div id="swf_footer"></div>
				<div id="footer-info-container">
					<div id="footer-info-swf">
						<div id="swf-loading-info">
							<p class="hidden">
								<strong><span class="first">Version </span></strong>
								<span class="line"><span id="version">1.x.x</span> - Build #<span id="buildnr">1</span> (<span id="builddate">14-June-2012</span>)</span>
								<span class="line"><strong>Debug Build:</strong> <span id="isdebugbuild">false</span></span>
								<span class="line"><strong><span id="consolekey">F8</span>:</strong> Toggle Console</span>
								<span class="last"><strong><span id="statskey">CTRL+F8</span>:</strong> Toggle Stats</span>
							</p>
						</div>
					</div>
					<div id="footer-info-browser">
						<span id="flash_info" class="first line"></span>
						<span id="useragent_info" class="last"></span>
					</div>
				</div>
				<div id="logo">
					<a href="@app_website@" target="_blank"><img src="img/logo.png" alt="@app_copyright@"></a>
				</div>
			</div>
		</div>
	</body>
</html>
