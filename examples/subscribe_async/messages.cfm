
<!DOCTYPE html>
<html>
<head>
	<title></title>
	
	<!--- Refresh this page every few seconds (to display new messages). --->
	<meta http-equiv="refresh" content="2" />
</head>
<body>
	
	<h1>
		Broadcast Messages
	</h1>
	
	<p>
		<cfoutput>
			#arrayLen( application.messages )#
			Messages as of #timeFormat( now(), "hh:mm:ss TT" )#
		</cfoutput>
	</p>
	
	<cfdump 
		var="#application.messages#"
		label="Messages"
		/>
	
</body>
</html>
