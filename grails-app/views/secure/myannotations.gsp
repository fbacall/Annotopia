<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="secure"/>
		<title>My Annotations</title>
		
		<style>
			.counter {
				font-size:18px; 
				padding-right: 5px;
			}
			
			.titleBar {
				font-weight: bold;
			}
		</style>
	</head>
	<body>
		<div class="container">
			<div id="sidebar" class="viewerSidebar well" >
		    	<div id='contributorsTitle'>Filtering by permissions</div>
				<div id="contributors" style="border-top: 3px solid #ddd; padding-bottom: 2px;"></div>
		    	<div style="padding: 5px; padding-top: 10px; ">
				    <input id="publicFilter" type="checkbox" name="vehicle" checked="checked"> Public<br>
				    <input id="privateFilter" type="checkbox" name="private"> Private<br/>
				    
				    <%--  
				   	<g:if test="${userGroups.size()>0}">
					  	<div id="groupsList">
					  	 	<br/>Groups<br/>	    
					  		<g:each in="${userGroups}" status="i" var="usergroup">
					  			<input type="checkbox" name="${usergroup.group.name}" class="groupCheckbox" value="${usergroup.group.id}"> ${usergroup.group.name}<br/>
					  		</g:each>
					  	</div
				  	</g:if>
				  	--%>
				<br/>					
				
				<div align="center"><input value="Refresh" title="Search" name="lucky" type="submit" id="btn_i" onclick="loadAnnotationSets('', 0, '')" class="btn btn-success"></div>
				</div>
		  	</div>
		
			<div id="progressIcon" align="center" style="padding: 5px; padding-left: 10px; display: none;">
		    	<img id="groupsSpinner" src="${resource(dir:'images/secure',file:'ajax-loader-4CAE4C.gif')}" />
		    </div>
		    
		    <table width="790px;">
		    	<tr><td>
		    		<div id="resultsSummary" style="padding:5px; padding-left: 10px;"></div>
		    		<div class="resultsPaginationTop"></div>
		    	</td><td style="text-align:right">
		    		<div id="resultsStats" style="padding: 5px; "></div>
		    	</td></tr>
		    </table>
		    
		    <div id="resultsList" style="padding: 5px; padding-left: 10px; width: 790px;"></div>
		    <div class="resultsPaginationBottom"></div>
	      	<div class="clr"></div>
		</div>
		<script type="text/javascript">
			
			$(document).ready(function() {
				$('#progressIcon').css("display","block");
				//var url = getURLParameter("url")!=null ? getURLParameter("url"):'';
				var url = '';
				loadAnnotations(url,0);
			});

			function loadAnnotations(url, paginationOffset, paginationRange) {
				$("#resultsList").empty();
				$('.resultsPaginationTop').empty();
				$('.resultsPaginationBottom').empty(); 

				var groups = '';
				$(".groupCheckbox").each(function(i) {
					if($(this).attr('checked')!=undefined) 
						groups += $(this).attr('value') + " ";
				});

				try {
					var dataToSend = { 
						id: '${loggedUser.id}', 
						documentUrl: url,
						outCmd: 'frame',
						paginationOffset:paginationOffset, 
						paginationRange:paginationRange, 
						publicData: $("#publicFilter").attr('checked')!==undefined, 
						groupsData: $("#groupsFilter").attr('checked')!==undefined, 
						groupsIds: groups,
						privateData:$("#privateFilter").attr('checked')!==undefined
					};
					$.ajax({
				  	  	url: "${appBaseUrl}/secure/getAnnotation",
				  	  	context: $("#resultsList"),
				  	  	data: dataToSend,
				  	  	success: function(data){
				  	  		$("#progressIcon").css("display","none");
							if(!data.result || !data.result.total || data.result.total==0) {
								$("#resultsSummary").html("");
								$("#resultsList").html("No results to display");	
							} else {
								$("#resultsSummary").html("<span class='counter'>" + data.result.items.length + "</span> of <span class='counter'>" + data.result.total + (data.result.items.length==1?"</span> annotation":"</span> annotations") + " in " + data.result.duration);							
								$.each(data.result.items, function(i,item){						
									var annotationGraph = item['@graph'][0];
									$("#resultsList").append(getComment(annotationGraph));
								});
					  		}					  		
				  	  	}
					});	
				} catch(e) {
					alert(e);
				}
			}

			function getComment(annotation) {
				var annotationType = ""
				var motivations = annotation['motivatedBy'];
				if(motivations) {
					if(motivations instanceof Array) {
						alert('motivatedBy is an Array');
					} else {
						if(motivations=='http://www.w3.org/ns/oa#commenting' || motivations=='oa:commenting') {
							annotationType += "Comment";
						} else if(motivations=='http://www.w3.org/ns/oa#highlighting' || motivations=='oa:highlighting') {
							annotationType += "Highlight";
						} else {
							annotationType += "Annotation";
						}
					}
				} else {
					annotationType += "Annotation";
				}
				
				var col1 = '';
				if(annotation['hasTarget']['format']=="text/html") 
					col1 = '<img src="${resource(dir:'images/secure',file:'file_html.png')}" style="width:40px;"/>'
				else if(annotation['hasTarget']['format']=="application/pdf") 
					col1 = '<img src="${resource(dir:'images/secure',file:'file_pdf.png')}" style="width:40px;"/>'

				var annotator = '';
				if(annotation['annotatedBy']['name']) 
					annotator = '<a href="' +  annotation['annotatedBy']['@id']  + '">' + annotation['annotatedBy']['name'] + '</a>';
				else 
					annotator + annotation['annotatedBy'];

				var tool = '';
				if(annotation['serializedBy']=="urn:application:domeo") 
					tool = '<img src="${resource(dir:'images/secure',file:'file_html.png')}" style="width:40px;"/>'
				else if(annotation['serializedBy']=="urn:application:utopia") 
					tool = '<img src="${resource(dir:'images/secure',file:'file_pdf.png')}" style="width:40px;"/>'
				
				var col2 = '<span class="titleBar">' + annotationType + '</span>' + ' on <a href="' + annotation['hasTarget']['@id'] + '">' + annotation['hasTarget']['@id'] + '</a>' + 
					' createdWith '  + annotation['serializedBy'] + 
					'<br/> by ' + annotator + ' on ' + annotation['annotatedAt'];
				//alert(annotator['serializedBy']);
				
				var col3 = '';
				var layout = "<table><tr><td>"+col1+"</td><td style='vertical-align: top;'>"+col2+"</td><td>"+col3+"</td></tr></table>";
				return layout;
			}
		</script>
	</body>
</html>