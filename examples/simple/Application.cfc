
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
	
</cfcomponent>
