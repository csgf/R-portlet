<%
/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.util.PortalUtil" %>
<%@ page import="com.liferay.portal.model.Company" %>
<%@ page import="javax.portlet.*" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<portlet:defineObjects />

<%
// Below the javascript functions used by the GATE web form 
%>
<script type="text/javascript">
//
// preSubmit
//
function preSubmit() {  
    var inputFileName=document.getElementById('upload_inputFileId');
    var inputFileText=document.getElementById('inputFileId');
    var jobIdentifier=document.getElementById('jobIdentifierId');
    var state_inputFileName=false;
    var state_inputFileText=false;
    var state_jobIdentifier=false;
    
    if(inputFileName.value=="") state_inputFileName=true;
    if(inputFileText.value=="" || inputFileText.value=="Insert here your text file, or upload a file") state_inputFileText=true;
    if(jobIdentifier.value=="") state_jobIdentifier=true;    
       
    var missingFields="";
    if(state_inputFileName && state_inputFileText) missingFields+="  Input file or Text message\n";
    if(state_jobIdentifier) missingFields+="  Job identifier\n";
    if(missingFields == "") {
      document.forms[0].submit();
    }
    else {
      alert("You cannot send an inconsisten job submission!\nMissing fields:\n"+missingFields);
        
    }
}
//
//  uploadMacroFile
//
// This function is responsible to disable the related textarea and 
// inform the user that the selected input file will be used
function uploadInputFile() {
	var inputFileName=document.getElementById('upload_inputFileId');
	var inputFileText=document.getElementById('inputFileId');
	if(inputFileName.value!='') {
		inputFileText.disabled=true;
		inputFileText.value="Using file: '"+inputFileName.value+"'";
	}
}

//
//  resetForm
//
// This function is responsible to enable all textareas
// when the user press the 'reset' form button
function resetForm() {
	var currentTime = new Date();
	var inputFileName=document.getElementById('upload_inputFileId');
	var inputFileText=document.getElementById('inputFileId');
	var jobIdentifier=document.getElementById('jobIdentifierId');
        
        // Enable the textareas
	inputFileText.disabled=false;
	inputFileName.disabled=false;        			
            
	// Reset the job identifier
        jobIdentifier.value="Job execution details ...";
}

//
//  addDemo
//
// This function is responsible to enable all textareas
// when the user press the 'reset' form button
function addDemo() {
	var currentTime = new Date();
	var inputFileName=document.getElementById('upload_inputFileId');
	var inputFileText=document.getElementById('inputFileId');
	var jobIdentifier=document.getElementById('jobIdentifierId');
	
	// Disable all input files
        inputFileText.disabled=false;
	inputFileName.disabled=true;
	
	// Secify that the simulation is a demo
	jobIdentifier.value="DEMO execution ...";
	
        // Add the demo value for the GATE macro file
	inputFileText.value="## Create a bivariate normal distribution\n"
                           +"x <- rnorm( n = 10000, mean = 10, sd = 4 )\n"
                           +"y <- rnorm( n = 10000, mean = 10, sd = 4 )\n"
                           +"\n"
                           +"## The z value is the density of values in the x-y plane.\n"
                           +"z <- matrix( data = 0, nrow = 21, ncol = 21 )\n"
                           +"\n"
                           +"for ( i in seq( from = 1, to = length( x ), by = 1 ) )\n"
                           +"{\n"
                           +"    if ( ( x[ i ] >= 0 ) && ( x[ i ] <= 20 ) &&\n"
                           +"         ( y[ i ] >= 0 ) && ( y[ i ] <= 20 ) )\n"
                           +"    {\n"
                           +"        xx <- round( x[ i ] )\n"
                           +"        yy <- round( y[ i ] )\n"
                           +"        z[ xx + 1, yy + 1 ] = z[ xx + 1, yy + 1 ] + 1\n"
                           +"    }\n"
                           +"}\n"
                           +"\n"
                           +"## Display the density of values with a perspective plot.\n"
                           +"persp(\n"
                           +"  x=0:20,\n"
                           +"  y=0:20,\n"
                           +"  z=z,\n"
                           +"  theta=i,\n"
                           +"  phi=30,\n"
                           +"  xlab=\"x\",\n"
                           +"  ylab=\"y\",\n"
                           +"  col=\"lightblue\",\n"
                           +"  ltheta=-135,\n"
                           +"  shade=0.5,\n"
                           +"  ticktype=\"detailed\" )\n";
}
</script>

<%//
  // This interface takes in input an R macro file or an R macro text
  // typed into the dedicated text area
  //
  // The ohter three buttons of the form are used for:
  //    o Demo:          Used to fill with demo values the text areas
  //    o SUBMIT:        Used to execute the job on the eInfrastructure
  //    o Reset values:  Used to reset input fields
  //
%>

<%
// Below the descriptive area of the web form 
%>
<table>
<tr>
<td valign="top">
<img align="left" style="padding:10px 10px;" src="<%=renderRequest.getContextPath()%>/images/AppLogo.png"/>
</td>
<td>
<p><a href="http://www.r-project.org/">R</a> is a free software environment for statistical computing and graphics.</p>
<center><img width="320" src="http://www.r-project.org/hpgraphic.png"/></center>
By this interface you may execute your R macro into a distributed infrastructure. It is possible to upload a R macro file or directyl type your macro text into the text area.
Then press <b>'SUBMIT'</b> button to launch R.<br>
Requested inputs are:
<ul>
	<li>A 'R' macro input file (Any text file to upload) or alernatively ...</li>
        <li>A 'R' macro text directly typed into the text area</li>
</ul>
Pressing the <b>'Demo'</b> Button input fields will be filled with a Demo input.<br>
Pressing the <b>'Reset'</b> Button all input fields will be initialized.<br>
Pressing the <b>'About'</b> Button information about the application will be shown
</td>
</tr>
<tr>
<td>
</td>
<td align="center">
<%
// Below the application submission web form 
//
// The <form> tag contains a portlet parameter value called 'PortletStatus' the value of this item
// will be read by the processAction portlet method which then assigns a proper view mode before
// the call to the doView method.
// PortletStatus values can range accordingly to values defined into Enum type: Actions
// The processAction method will assign a view mode accordingly to the values defined into
// the Enum type: Views. This value will be assigned calling the function: setRenderParameter
//
%>
<form enctype="multipart/form-data" action="<portlet:actionURL portletMode="view"><portlet:param name="PortletStatus" value="ACTION_SUBMIT"/></portlet:actionURL>" method="post">
<dl>	
	<dd>		
 		<p><b>Application' input file</b> <input type="file" name="file_inputFile" id="upload_inputFileId" accept="*.*" onchange="uploadInputFile()"/></p>
		<textarea id="inputFileId" rows="20" cols="80%" name="inputFile">Insert here your text file, or upload a file</textarea>
	</dd>
	<dd>
		<p>Insert below your <b>job identifyer</b></p>
		<textarea id="jobIdentifierId" rows="1" cols="60%" name="JobIdentifier">Job execution details ...</textarea>
	</dd>	
  	<dd>
  		<input type="button" value="Demo" onClick="addDemo()">
  		<input type="button" value="Submit" onClick="preSubmit()"> 
  		<input type="reset" value="Reset values" onClick="resetForm()">
	</dd>
</form>
	<dd>
<form action="<portlet:actionURL portletMode="HELP"> /></portlet:actionURL>" method="post">
        	<input type="submit" value="About">
       </dd>
</form>
</dl>        
</td>
</tr>
</table>

