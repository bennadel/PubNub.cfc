
<cfcomponent
	output="false"
	hint="I define the application settings and event handlers.">
	
	<!--- Define the appliation settings. --->
	<cfset this.name = hash( getCurrentTemplatePath() ) />
	<cfset this.applicationTimeout = createTimeSpan( 0, 0, 5, 0 ) />
	<cfset this.sessionManagement = false />
	
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
			We will just be using the DEMO account. 
		--->
		<cfset application.pubnub = createObject( "component", "com.PubNub" ).init(
			publishKey = "demo",
			subscribeKey = "demo"
			) />
			
		<!--- Keep a collection of broadcasted messages. --->
		<cfset application.messages = [] />
		
		<!--- Keep a flag for running. --->
		<cfset application.isRunning = false />
		
		<!--- Return true so the application can load. --->
		<cfreturn true />
	</cffunction>
	
	
	<cffunction
		name="onRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I initialize the request.">
		
		<!--- Check to see if we need to re-initialize the app. --->
		<cfif structKeyExists( url, "init" )>
		
			<!--- Manually restart the application. --->
			<cfset this.onApplicationStart() />
		
		</cfif>
		
		<!--- Return true so the request can load. --->
		<cfreturn true />
	</cffunction>
	
</cfcomponent>
