

<!--- Create an instance of our PubNub component with DEMO credentials. --->
<cfset pubnub = createObject( "component", "com.PubNub" ).init(
	publishKey = "demo",
	subscribeKey = "demo"
	) />
	
	
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->

	
<!--- 
	Get the current time token of the channel. This will be used 
	to for the subscribe method call farther down. 
--->
<cfset timeToken = pubnub.time() />
	
	
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Create a message to publish. --->
<cfset message = {} />
<cfset message[ "uuid" ] = createUUID() />
<cfset message[ "message" ] = "This is a test message from ColdFusion (#timeFormat( now(), 'hh:mm:ss TT' )#)." />

<!--- Publish the message. --->
<cfset response = pubnub.publish(
	channel = "coldfusion:hello_world",
	message = message
	) />
	
<h2>
	Publish Response
</h2>
	
<cfdump 
	var="#response#"
	label="Publish Response"
	/>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Get the history for our channel. --->
<cfset response = pubnub.history(
	channel = "coldfusion:hello_world",
	limit = 5
	) />
	
<h2>
	History Response
</h2>
	
<cfdump 
	var="#response#"
	label="History Response"
	/>
	

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- 
	Subscribe the given channel using the retreived time token 
	from above. This should return the broadcast message from 
	above. 
--->
<cfset response = pubnub.subscribe(
	channel = "coldfusion:hello_world",
	timeToken = timeToken
	) />
	
<h2>
	Subscribe Response
</h2>
	
<cfdump 
	var="#response#"
	label="Subscribe Response"
	/>
	
	
	