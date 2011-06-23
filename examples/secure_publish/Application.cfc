
<cfcomponent
	output="false"
	hint="I define the application settings and event handlers.">
	
	<!--- Define the appliation settings. --->
	<cfset this.name = hash( getCurrentTemplatePath() ) />
	<cfset this.applicationTimeout = createTimeSpan( 0, 0, 20, 0 ) />
	<cfset this.sessionManagement = true />
	<cfset this.sessionTimeout = createTimeSpan( 0, 0, 10, 0 ) />
	
	<!--- Map the COM library for the examples. --->
	<cfset this.mappings[ "/com" ] = (getDirectoryFromPath( getCurrentTemplatePath() ) & "../../com/") />
	
	<!--- Define the request settings. --->
	<cfsetting 
		showdebugoutput="false"
		requesttimeout="20"
		/>
		
		
	<cffunction
		name="onApplicationStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I initialize the application.">
		
		<!--- 
			Create and cache an instance of our PubNub component.
			This will be used to publish messages to the PubNub
			API as the server-side proxy to the client.
		--->
		<cfset application.pubnub = createObject( "component", "com.PubNub" ).init(
			publishKey = "pub-7b6592f6-4ddb-4af6-b1b3-0e74cefe818d",
			subscribeKey = "sub-f4baaac5-87e0-11e0-b5b4-1fcb5dd0ecb4"
			) />
		
		<!--- Return true so the application can load. --->
		<cfreturn true />
	</cffunction>
	
		
	<cffunction
		name="onSessionStart"
		access="public"
		returntype="void"
		output="false"
		hint="I initialize the session.">
		
		<!--- 
			Set up the initial user. In order for the user to be 
			able to post messages to the channel, they will have 
			to be logged-in.
		--->
		<cfset session.user = {
			isLoggedIn = false,
			uuid = createUUID(),
			name = ""
			} />
		
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	
	
	<cffunction
		name="onRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I initialize the request.">
		
		<!--- Check to see if we need to re-initialize the app. --->
		<cfif structKeyExists( url, "init" )>
		
			<!--- Manually restart the application and session. --->
			<cfset this.onApplicationStart() />
			<cfset this.onSessionStart() />
		
		</cfif>
		
		<!--- Return true so the request can load. --->
		<cfreturn true />
	</cffunction>
	
</cfcomponent>
