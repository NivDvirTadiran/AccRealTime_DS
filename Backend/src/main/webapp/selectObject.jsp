<%@page pageEncoding="UTF-8" import="tadiran.webnla.NLAContext, java.util.Collections, java.util.Collection, tadiran.webnla.bean.AbsDataComparator, java.util.Vector, tadiran.webnla.tag.LocaleMessage" %>

<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
        String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
	String langName=(String)session.getAttribute("Accept-Language");
	String ids=","+request.getParameter("objId")+",";

	String caption=LocaleMessage.getMessage("select.Title", langName)+" ";
	if (request.getParameter("multiSelect").equals("true"))
		caption+=LocaleMessage.getMessage("select.Multiple", langName)+" ";

    String type=request.getParameter("type");
    if (type.length()>0) {
        type=type.substring(0,1).toUpperCase()+type.substring(1);
    }
    String captionBody=type+" "+request.getParameter("ref");
    caption+=captionBody;
    boolean isGraph = request.getParameter("ref").toLowerCase().equals("group");
%>

<html>
<head>
	<link href="${pageContext.request.contextPath}/css/nlaTemplate.css" type="text/css" rel="stylesheet"/>
	<script src="${pageContext.request.contextPath}/js/tableMng.js" type= "text/javascript"></script>
	<script type= "text/javascript">
		var nla_titleColor="Maroon"; //"LightSlateGray", DarkGoldenRod, Maroon, Orange, #555

		if (${empty sessionData}) {
			alert('<nla:text message="select.Expired"/>');
			window.parent.parent.location="${pageContext.request.contextPath}/login.jsp";
		}
      
        var isGraph = <%=isGraph%>;
        var maxAgentsInBriefReport= (<%=isGraph%> ? 14 : ${sessionData.getMaxAgentsInBriefReport()}) ;

        window.oncontextmenu = function(event) {
                                    event.preventDefault();
                                    event.stopPropagation();
                                    return false;
                                };
	</script>
    <title><%=caption%></title>
</head>

<c:choose>
	<c:when test="${param.ref=='Group'}">
        <c:set var="refObj" value="${sessionData.groups}"/>
	</c:when>
	<c:when test="${param.ref=='Agent'}">
		<%
			Vector sortedAgents=new Vector(NLAContext.getInstance().getAgents().getData().values());
			Collections.sort(sortedAgents, new AbsDataComparator("6_3_2_1_1"));
		%>
		<c:set var="refObj" value="<%=sortedAgents%>"/>
	</c:when>
	<c:when test="${param.ref=='DNIS'}">
		<c:if test="${param.type=='voice'}">
			<c:set var="refObj" value="${sessionData.voiceDNISs}"/>
		</c:if>
		<c:if test="${param.type=='email'}">
			<c:set var="refObj" value="${sessionData.emailDNISs}"/>
		</c:if>
		<c:if test="${empty param.type}">
			<c:set var="refObj" value="${sessionData.DNISs}"/>
		</c:if>
	</c:when>
	<c:when test="${param.ref=='IVRApplication'}">
		<c:set var="refObj" value="${sessionData.IVRApps}"/>
	</c:when>
	<c:when test="${param.ref=='IVRGroup'}">
		<c:set var="refObj" value="${sessionData.IVRGroups}"/>
	</c:when>
	<c:when test="${param.ref=='SuperGroup'}">
		<c:set var="refObj" value="${sessionData.superGroups}"/>
	</c:when>
</c:choose>

<body style="margin:0px;">
	<nla:render mask="(BlackBerry|IEMobile)">
		<div class="title"><%=caption%></div>
	</nla:render>
	<table border="0" align="center" width="100%" style="margin-top:-2px;">
		<tr class="dataTableHeader  ${dynamicFrontSize}">
			<c:if test="${param.multiSelect=='true'}">
				<td width="10"><input type="checkbox" onclick="onAllObjectsSelect(event);" title="click to select/unselect all"></td>
				<td onclick="onObjectSelectDone(null,'<%=request.getParameter("ref").toLowerCase()%>');" class="objSelectBtn ${dynamicFrontSize}" title="click to select"><nla:text message="select.Select"/></span></td>
			</c:if>
			<c:if test="${param.multiSelect!='true'}">
				<td>&nbsp;<nla:text message="select.Name"/></td>
			</c:if>
		</tr>
	</table>	
	<div style="height:<nla:render mask="(Firefox|Chrome|Safari)">74%</nla:render><nla:render mask="(MSIE)">93%</nla:render>; overflow-y:auto;overflow-x:hidden;">
	<table border="0" align="center" width="100%" style="font-size:14px;">
	<c:forEach var="item" items="${refObj}" varStatus="rowCounter">
		<c:set var="showItem" value="true"/>
		<c:choose>
			<c:when test="${param.ref=='Group'}">
				<c:set var="refId" value="${item.grpId}"/>
				<c:set var="refNum" value="${item.grpNumber}"/>
				<c:set var="refName" value="${item.grpName}"/>
				<c:if test="${param.type=='email'}">
					<c:set var="showItem" value="${item.grpEmailEnable==1}"/>
				</c:if>
				<c:if test="${param.type=='voice'}">
					<c:set var="showItem" value="${item.grpEmailEnable==0}"/>
				</c:if>
			</c:when>
			<c:when test="${param.ref=='DNIS'}">
				<c:set var="refId" value="${item.dnisId}"/>
				<c:set var="refName" value="${item.dnisName}"/>
			</c:when>
			<c:when test="${param.ref=='Agent'}">
				<c:set var="refId" value="${item.id}"/>
				<c:set var="refNum" value="${item.num}"/>
				<c:set var="refName" value="${item.name}"/>
			</c:when>
			<c:when test="${param.ref=='IVRApplication' || param.ref=='IVRGroup'}">
				<c:set var="refId" value="${item.id}"/>
				<c:set var="refName" value="${item.name}"/>
			</c:when>
			<c:when test="${param.ref=='SuperGroup'}">
				<c:set var="refId" value="${item.superGroupId}"/>
				<c:set var="refName" value="${item.superGroupName}"/>
			</c:when>
		</c:choose>
		<c:if test="${showItem}">
            <c:set var="isNotEmpty" value="true"/>
			<tr id="${refId}" class='dataTableRow${(rowCounter.count%2==1)? " rowOdd ":" "} ${dynamicFrontSize}' style="cursor:pointer;" onmouseover="onSelectOver(this, '${dynamicFrontSize}')" onmouseout="onSelectOut(this)">
				<td
				<c:if test="${param.multiSelect=='true'}">
					width="15%">
					<input id ="chk_${refId}" type="checkbox" onclick="onObjectSelect(this, event);">
					<c:if test='<%=(ids.indexOf(","+pageContext.getAttribute("refId")+",")!=-1)%>'>
						<script type= "text/javascript">
							var obj=document.getElementById("chk_${refId}");
							obj.checked=true;
							onObjectSelect(obj);
						</script>
					</c:if>
				</c:if>
				<c:if test="${param.multiSelect!='true'}">
					width="5%">
				</c:if>
				</td>
				<td onclick="onObjectSelectDone(this,'<%=request.getParameter("ref").toLowerCase()%>');" title="${refNum}">${refName}</td>
			</tr>
		</c:if>
	</c:forEach>
	</table>
    <c:if test="${!isNotEmpty}">
        <div style="text-align: center; font-size: 13px; margin-top: 30%;">no <%=captionBody%></div>
    </c:if>
	</div>
</body>
</html>
