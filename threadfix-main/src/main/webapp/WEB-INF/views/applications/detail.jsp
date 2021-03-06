<%@ include file="/common/taglibs.jsp"%>

<head>
	<title><c:out value="${ application.name }"/></title>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/confirm.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/remote-pagination.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/authentication.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/ajax_search.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/radio_select.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/application_page.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/scan_page.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/document_page.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/scripts/jquery.form.js"></script>
</head>

<body id="apps">

	<spring:url value="{appId}/edit" var="editUrl">
		<spring:param name="appId" value="${ application.id }"/>
	</spring:url>
	<spring:url value="{appId}/delete" var="deleteUrl">
		<spring:param name="appId" value="${ application.id }"/>
	</spring:url>
	<spring:url value="{appId}/progress/{numScans}" var="dataRefreshUrl">
		<spring:param name="appId" value="${ application.id }"/>
		<spring:param name="numScans" value="${ numScansBeforeUpload }"/>
	</spring:url>
	
	<div id="headerDiv" 
			data-wait-for-refresh="<c:out value="${ checkForRefresh }"/>" 
			data-refresh-url="<c:out value="${ dataRefreshUrl }"/>">
		<%@ include file="/WEB-INF/views/applications/detailHeader.jsp" %>
	</div>
	
	<div id="addWafSuccessMessage" style="display:none" class="alert alert-success">
		<button class="close" type="button">x</button>
		The WAF <span id="wafName"></span> has been added to the Application.
	</div>
	
	<div id="addDefectTrackerSuccessMessage" style="display:none" class="alert alert-success">
		<button class="close" type="button">x</button>
		The Defect Tracker <span id="defectTrackerName"></span> has been added to the Application.
	</div>
	
	<div style="padding-top:10px;" id="helpText">
		Applications are used to store, unify, and manipulate scan results from security scanners.
		<c:if test="${ empty application.scans }">
			<br/><br/>To get started, click Upload Scan to start uploading security scans.
		</c:if>
	</div>
	
	<c:if test="${ canGenerateReports }">
		<div class="container-fluid">
			<div class="row-fluid">
			    <div class="span6">
			    	<h4>
			    		6 Month Vulnerability Burndown
			    		<c:if test="${ numVulns > 0 }">
				    		<spring:url value="/reports/9/{orgId}/{appId}" var="reportsUrl">
				    			<spring:param name="orgId" value="${ application.organization.id }"/>
				    			<spring:param name="appId" value="${ application.id }"/>
				    		</spring:url>
							<span style="font-size:12px;float:right;">
					    		<a id="leftViewMore" style="display:none" href="<c:out value="${ reportsUrl }"/>">View More</a>
					    	</span>
				    	</c:if>
			    	</h4>
			    	<c:if test="${ numVulns > 0 }">
			    		<spring:url value="/dashboard/leftReport" var="reportsUrl"/>
						<form id="leftReportForm" action="<c:out value="${ reportsUrl }"/>">
							<input style="display:none" name="orgId" value="<c:out value="${ application.organization.id }"/>"/>
							<input style="display:none" name="appId" value="<c:out value="${ application.id }"/>"/>
						</form>
				    	<div id="leftTileReport">
				    		<%@ include file="/WEB-INF/views/reports/loading.jspf" %>
				    	</div>
			    	</c:if>
			    	<c:if test="${ numVulns == 0 }">
			    		<%@ include file="/WEB-INF/views/reports/emptyReport.jspf" %>
			    	</c:if>
			    </div>
			    
			     <div class="span6">
			    	<h4>
			    		Top 10 Vulnerabilities
			    		<c:if test="${ numVulns > 0 }">
				    		<spring:url value="/reports/3/{orgId}/{appId}" var="reportsUrl">
				    			<spring:param name="orgId" value="${ application.organization.id }"/>
				    			<spring:param name="appId" value="${ application.id }"/>
				    		</spring:url>
					    	<span style="font-size:12px;float:right;">
					    		<a id="rightViewMore" style="display:none" href="<c:out value="${ reportsUrl }"/>">View More</a>
				    		</span>
			    		</c:if>
			    	</h4>
			    	<c:if test="${ numVulns > 0 }">
			    		<spring:url value="/dashboard/rightReport" var="reportsUrl"/>
						<form id="rightReportForm" action="<c:out value="${ reportsUrl }"/>">
							<input style="display:none" name="orgId" value="<c:out value="${ application.organization.id }"/>"/>
							<input style="display:none" name="appId" value="<c:out value="${ application.id }"/>"/>
						</form>
				    	<div id="rightTileReport">
				    		<%@ include file="/WEB-INF/views/reports/loading.jspf" %>
				    	</div>
			    	</c:if>
			    	<c:if test="${ numVulns == 0 }">
			    		<%@ include file="/WEB-INF/views/reports/emptyReport.jspf" %>
			    	</c:if>
			    </div>
			</div>
		</div>
	</c:if>
	
		<spring:url value="/organizations/{orgId}/applications/{appId}/vulnTab" var="vulnTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
		<spring:url value="/organizations/{orgId}/applications/{appId}/scanTab" var="scanTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
		<spring:url value="/organizations/{orgId}/applications/{appId}/closedTab" var="closedTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
		<spring:url value="/organizations/{orgId}/applications/{appId}/falsePositiveTab" var="falsePositiveTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
		<spring:url value="/organizations/{orgId}/applications/{appId}/docsTab" var="docsTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
		<spring:url value="/organizations/{orgId}/applications/{appId}/hiddenTab" var="hiddenTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
		<spring:url value="/organizations/{orgId}/applications/{appId}/scanQueueTab" var="scanQueueTabUrl">
			<spring:param name="orgId" value="${ application.organization.id }"/>
			<spring:param name="appId" value="${ application.id }"/>
		</spring:url>
        <spring:url value="/organizations/{orgId}/applications/{appId}/scheduledScanTab" var="scheduledScanTabUrl">
            <spring:param name="orgId" value="${ application.organization.id }"/>
            <spring:param name="appId" value="${ application.id }"/>
        </spring:url>
		<br>

    <c:choose>
        <c:when test="${activeTab == 'scan_tab'}"><c:set var="scanTab" value="active" /></c:when>
        <c:when test="${activeTab == 'file_tab'}"><c:set var="fileTab" value="active" /></c:when>
        <c:when test="${activeTab == 'scan_agent_task_tab'}"><c:set var="scanAgentTaskTab" value="active" /></c:when>
        <c:when test="${activeTab == 'scheduled_scan_tab'}"><c:set var="scheduledScanTab" value="active" /></c:when>
        <c:when test="${activeTab == 'closed_vuln_tab'}"><c:set var="closedVulnTab" value="active" /></c:when>
        <c:when test="${activeTab == 'false_positive_tab'}"><c:set var="falsePositiveTab" value="active" /></c:when>
        <c:otherwise><c:set var="activeVulnTab" value="active" /></c:otherwise>
    </c:choose>

		<ul class="nav nav-tabs margin-top">
			<li class="pointer ${ activeVulnTab }">
				<a data-toggle="tab" id="vulnTabLink" onclick="javascript:switchTabs('<c:out value="${vulnTabUrl }"/>');return false;">
					${ fn:escapeXml(numVulns) } 
					<c:if test="${ numVulns == 1 }">Vulnerability</c:if>
					<c:if test="${ numVulns != 1 }">Vulnerabilities</c:if>
				</a>
			</li>
			<li class="pointer ${ scanTab }">
				<a data-toggle="tab" id="scanTabLink" onclick="javascript:switchTabs('<c:out value="${scanTabUrl }"/>');return false;">
					${ fn:length(application.scans) }
					<c:if test="${ fn:length(application.scans) == 1 }">Scan</c:if>
					<c:if test="${ fn:length(application.scans) != 1 }">Scans</c:if>
				</a>
			</li>
			<c:if test="${ numClosedVulns != 0 }">
				<li class="pointer ${ closedVulnTab }">
					<a data-toggle="tab" id="closedVulnTabLink" onclick="javascript:switchTabs('<c:out value="${closedTabUrl }"/>');return false;">
						${fn:escapeXml(numClosedVulns) } Closed 
						<c:if test="${fn:escapeXml(numClosedVulns) == 1}"> Vulnerability</c:if>
						<c:if test="${fn:escapeXml(numClosedVulns) != 1}"> Vulnerabilities</c:if>
					</a>
				</li>
			</c:if>
			<c:if test="${ numHiddenVulns != 0 }">
				<li class="pointer">
					<a data-toggle="tab" id="hiddenTabLink" onclick="javascript:switchTabs('<c:out value="${ hiddenTabUrl }"/>');return false;">
						${fn:escapeXml(numHiddenVulns) } Hidden 
						<c:if test="${fn:escapeXml(numHiddenVulns) == 1}">Vulnerability</c:if>
						<c:if test="${fn:escapeXml(numHiddenVulns) != 1}">Vulnerabilities</c:if>
					</a>
				</li>
			</c:if>
			<c:if test="${ falsePositiveCount != 0 }">
				<li class="pointer ${ falsePositiveTab }">
					<a data-toggle="tab" id="falsePositiveTabLink" onclick="javascript:switchTabs('<c:out value="${falsePositiveTabUrl }"/>');return false;">
						${fn:escapeXml(falsePositiveCount) } False 
						<c:if test="${fn:escapeXml(falsePositiveCount) == 1}">Positive</c:if>
						<c:if test="${fn:escapeXml(falsePositiveCount) != 1}">Positives</c:if>
					</a>
				</li>
			</c:if>
			<li class="pointer ${ fileTab }">
				<a data-toggle="tab" id="docsTabLink" onclick="javascript:switchTabs('<c:out value="${docsTabUrl }"/>');return false;">
					${ fn:length(application.documents) } 
					<c:if test="${ fn:length(application.documents) == 1 }">File</c:if>
					<c:if test="${ fn:length(application.documents) != 1 }">Files</c:if>
				</a>
			</li>
            <c:if test="${ isEnterprise }">
                <li class="pointer ${ scanAgentTaskTab }">
                    <a data-toggle="tab" id="scanQueueTabLink" onclick="javascript:switchTabs('<c:out value="${scanQueueTabUrl }"/>');return false;">
                        ${ fn:length(application.scanQueueTasks) }
                        <c:if test="${ fn:length(application.scanQueueTasks) == 1 }">Scan Agent Task</c:if>
                        <c:if test="${ fn:length(application.scanQueueTasks) != 1 }">Scan Agent Tasks</c:if>
                    </a>
                </li>
                <li class="pointer ${ scheduledScanTab }">
                    <a data-toggle="tab" id="scheduledScanTabLink" onclick="javascript:switchTabs('<c:out value="${scheduledScanTabUrl }"/>');return false;">
                        ${ fn:length(application.scheduledScans) }
                        <c:if test="${ fn:length(application.scheduledScans) == 1 }">Scheduled Scan</c:if>
                        <c:if test="${ fn:length(application.scheduledScans) != 1 }">Scheduled Scans</c:if>
                    </a>
                </li>
            </c:if>
		</ul>
		
	    <div id="tabsDiv">
            <c:choose>
                <c:when test="${scanTab == 'active'}">
                    <%@ include file="/WEB-INF/views/applications/tabs/scanTab.jsp" %>
                </c:when>
                <c:when test="${fileTab == 'active'}">
                    <%@ include file="/WEB-INF/views/applications/tabs/docsTab.jsp" %>
                </c:when>
                <c:when test="${scanAgentTaskTab == 'active'}">
                    <%@ include file="/WEB-INF/views/applications/tabs/scanQueueTab.jsp" %>
                </c:when>
                <c:when test="${scheduledScanTab == 'active'}">
                    <%@ include file="/WEB-INF/views/applications/tabs/scheduledScanTab.jsp" %>
                </c:when>
                <c:when test="${closedVulnTab == 'active'}">
                    <%@ include file="/WEB-INF/views/applications/tabs/closedTab.jsp" %>
                </c:when>
                <c:when test="${falsePositiveTab == 'active'}">
                    <%@ include file="/WEB-INF/views/applications/tabs/falsePositiveTab.jsp" %>
                </c:when>
                <c:otherwise> <%@ include file="/WEB-INF/views/applications/tabs/vulnTab.jsp" %> </c:otherwise>
            </c:choose>
		</div>
	
	<div id="addWaf" class="modal hide fade" tabindex="-1"
			role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<%@ include file="/WEB-INF/views/applications/forms/addWafForm.jsp" %>
	</div>
	
	<div id="createWaf" class="modal hide fade" tabindex="-1"
			role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<%@ include file="/WEB-INF/views/wafs/forms/createWafForm.jsp" %>
	</div>
	
	<div id="addDefectTracker" class="modal hide fade" tabindex="-1"
		role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="width:600px;">
		<%@ include file="/WEB-INF/views/applications/forms/addDTForm.jsp" %>
	</div>
	
	<%@ include file="/WEB-INF/views/config/defecttrackers/modals/createDTModal.jsp" %> 
	
	<%@ include file="/WEB-INF/views/defects/submitDefectModal.jsp" %>
	
	<%@ include file="/WEB-INF/views/defects/mergeDefectModal.jsp" %>
	
</body>