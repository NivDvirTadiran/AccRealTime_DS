<%@page import="java.util.Hashtable" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html>
<head>
    <link rel="icon" href="favicon.ico">
    <script src="js/winsMng.jsp" type= "text/javascript"></script>
    <script type= "text/javascript">
        window.oncontextmenu = function(event) {
            event.preventDefault();
            event.stopPropagation();
            return false;
        };
    </script>
	<link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>
</head>

<%-- AviM 14/01/2019 Changes for Aeonix Contact Center workspace display --%>

<body scroll="no" style="background: silver url(img/aeonix_logo_150_20.png) fixed center no-repeat" onbeforeunload="return beforeExit();">
    <div id="workspaceLayer" class="workspaceLayer"></div>
	<script type= "text/javascript">
	<c:set var="userReports" value="${sessionData.reports}" scope="request"/>
	<c:forEach var="item" items="${sessionData.workspace}">
		<c:set var="reportId" value="${item.reportId}" scope="request"/>
		<c:set var="render" value='<%=((Hashtable)request.getAttribute("userReports")).get(request.getAttribute("reportId"))%>' scope="request"/>
		<c:if test="${!empty render}">
			addWin('nlat/${render.params}',${reportId},'${render.reportName}',${item.x},${item.y},${item.width},${item.height});
		</c:if>
	</c:forEach>
	</script>
</body>
</html>
