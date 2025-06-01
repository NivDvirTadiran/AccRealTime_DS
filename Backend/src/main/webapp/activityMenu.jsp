<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%@page pageEncoding="UTF-8" import="java.util.List, java.util.Vector, java.util.Collections, java.util.Comparator, java.util.HashMap, java.util.Properties,
						tadiran.webnla.bean.Agent, tadiran.webnla.bean.RCode, tadiran.webnla.bean.SessionData, tadiran.webnla.NLAContext,
						tadiran.emisweb.GroupListDataItemType, tadiran.webnla.bean.AbsDataClass, tadiran.emisweb.GenListDataItemType" %>

<%
    System.out.println("activityMenu.jsp");
    Properties rnd2tmp=(Properties)application.getAttribute("nlatRenders");

    String ref=request.getParameter("ref");
    //String r_codes_str="RCodes";
    if (ref.startsWith("Group"))
        pageContext.setAttribute("groupId", ref.split(":")[1].split("\\.")[0]);

    SessionData sessionData = (SessionData) session.getAttribute("sessionData");
    List<GenListDataItemType> rCodes=sessionData.getRCodes();
    HashMap map=(HashMap)NLAContext.getInstance().getObjectMap(ref);
    //HashMap rCodes=(HashMap)NLAContext.getInstance().getObjectMap("RCodes");
    //HashMap rCodes=NLAContext.getInstance().getRCodes().getData();
    System.out.println("activityMenu.jsp - rCodes.isEmpty()="+(false ? "true" : "false"));
    for(GenListDataItemType _locale:rCodes) {
        System.out.println("activityMenu.jsp - rCodes="+_locale.getName());
    }
    //System.out.println("activityMenu.jsp - rCodes="+rCodes.toString());
    AbsDataClass obj=(AbsDataClass)map.get(new Integer(request.getParameter("id")));
    pageContext.setAttribute("objRef", obj);
    pageContext.setAttribute("objRefData", obj.getData());
%>
<html>
<head>
    <link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>
    <link href="css/nlaTemplate.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript">
    function onOver(obj) {
        obj.style.backgroundColor="gold";
        /*obj.style.color="maroon";
        obj.style.fontWeight="bold";
        obj.style.fontSize="15px";*/
    }

    function onOut(obj) {
        obj.style.backgroundColor="";
        /*obj.style.color="";
        obj.style.fontWeight="";
        obj.style.fontSize="";*/
    }

    function onLoad() {
        var links=document.getElementsByTagName("a");
        for(var i=0; i<links.length; i++) {
            links[i].className="activityLink";
            links[i].onmouseover=function() { onOver(this) };
            links[i].onmouseout=function() { onOut(this) };
        }
        var h=18+links.length*18;
        parent.activityWin.style.height=h;
        var s=parseInt(parent.activityWin.style.top)-(parent.document.body.clientHeight-h);
        if(s>0)
            parent.activityWin.style.top=parseInt(parent.activityWin.style.top)-s-3;
    }

    document.oncontextmenu=function() { return false;};
    setTimeout('document.oncontextmenu=null', 100);
</script>
</head>

<body style="padding-top:3px; background-color:WhiteSmoke;">
    <span class="closeBtn closeBtnPos" onmousedown="parent.closeActivityWin();" title="<nla:text message="tools.Close"/>" UNSELECTABLE="ON">x</span>
    <span id="actions">
        <c:choose>
            <c:when test="${objRef.objectInfo=='Agent'}">
                <c:set var="state" value="${objRefData['6_3_2_2_1']}"/>
                <c:if test="${state!='Logout'}">
                    <c:choose>
                        <c:when test="${state=='Release' || state=='Inc+Rls' || state=='Out+Rls' || state=='Busy+Rls' || state=='ACD'}">
                            <a href="processActivity?activity=resume&agentId=${param.id}"><nla:text message="activity.Resume"/></a><br>
                        </c:when>
                        <c:when test="${!(state=='Release' || state=='Inc+Rls' || state=='Out+Rls' || state=='Busy+Rls')}">
                            <a href="processActivity?activity=release&agentId=${param.id}"><nla:text message="activity.Release"/></a><br>
                        </c:when>
                    </c:choose>
                    <a href="processActivity?activity=logout&groupId=${groupId}&agentId=${param.id}"><nla:text message="activity.Logout"/></a><br>
                    <c:if test="${state=='ACD' || state=='O.ACD' || state=='Inc' || state=='Inc+Rls' || state=='Out' || state=='Out+Rls' || state=='Split'}">
                        <div style="border-bottom:1px solid #e5e5e5;"></div>
                        <a href="processActivity?activity=monitor&agentId=${param.id}&agentExt=${objRefData['6_3_2_1_3']}" ><nla:text message="activity.Monitor"/></a><br>
                        <a href="processActivity?activity=breakIn&agentId=${param.id}&agentExt=${objRefData['6_3_2_1_3']}"><nla:text message="activity.BreakIn"/></a><br>
                        <a href="processActivity?activity=whisper&agentId=${param.id}&agentExt=${objRefData['6_3_2_1_3']}"><nla:text message="activity.Whisper"/></a><br>
                        <a href="processActivity?activity=record&agentId=${param.id}&agentExt=${objRefData['6_3_2_1_3']}"><nla:text message="activity.Record"/></a><br>
                    </c:if>
                    <div style="border-bottom:1px solid #e5e5e5;"></div>
                    <!--a href="processActivity?activity=chat&agentId=${param.id}" onclick="window.open(this.href, '_blank', 'toolbar=no,location=no,directories=no,resizable=yes,scrollbars=yes'); setTimeout('parent.closeActivityWin()',500); return false;"><nla:text message="activity.Chat"/></a--><br>
                </c:if>
                <c:if test="${state=='Logout'}">
                    <c:if test="${!empty groupId}">
                        <a href="processActivity?activity=login&groupId=${groupId}&agentId=${param.id}"><nla:text message="activity.Login"/></a><br>
                    </c:if>
                    <c:if test="${empty groupId}">
                        <label style="color:blue; font-weight:bold;"><nla:text message="activity.LogoutCode"/></label>
                        <div style="border-bottom:2px solid #e5e5e5;"></div>
                        <%
                            for(GenListDataItemType _locale:rCodes) {
                                System.out.println("activityMenu.jsp - rCodes="+_locale.getName());

                        %>
                        <a  href="processActivity?activity=logout_code&agentId=${param.id}&code=<%=_locale.getName()%>" href="test"><nla:text  message="<%=_locale.getName()%>" /></a><br>

                        <%
                            }
                        %>
                    </c:if>
                </c:if>
            </c:when>
            <c:when test="${objRef.objectInfo=='Group'}">
                <a href="javascript:parent.parent.addWin('nlat/<%=rnd2tmp.getProperty("GroupAgentsStatus")%>?groupId=${param.id}','GroupAgentsStatus'); parent.closeActivityWin();"><nla:text message="activity.AgentsRep"/></a><br>
                <a href="javascript:parent.parent.addWin('nlat/<%=rnd2tmp.getProperty("GroupCallsDistrGraph")%>?groupId=${param.id}','GroupCallsDistrGraph'); parent.closeActivityWin();"><nla:text message="activity.CallsRep"/></a><br>
            </c:when>
        </c:choose>
    </span>
</body>

<script type="text/javascript">
    onLoad();
    if (document.getElementById("actions").childElementCount==0) {
        parent.closeActivityWin();
    }
</script>
</html>
