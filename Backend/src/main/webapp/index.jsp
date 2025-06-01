<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%
	if (session.getAttribute("sessionData")==null) {
		pageContext.forward("login.jsp");
		return;
	}
%>

<nla:render mask="(BlackBerry|IEMobile)">
<%
	pageContext.forward("openDialog.jsp");
%>
</nla:render>

<%-- AviM 14/01/2019 Changes for Aeonix Contact Center workspace display --%>

<html>
    <head>
        <link rel="icon" href="favicon.ico">
        <title><nla:text message="index.Title"/></title>
    </head>
    <frameset id="main-page" rows="70,*" border="2">
            <frame name="title" src="title.jsp" noresize MARGINHEIGHT="0" MARGINWIDTH="5" SCROLLING="no"/>
            <frame id="mainwin" name="mainwin" src="main.jsp" MARGINWIDTH="0" MARGINHEIGHT="0"/>
    </frameset>
</html>
