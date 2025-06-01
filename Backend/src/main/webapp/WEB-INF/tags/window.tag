<%------------------------------------------------------------
WINDOW - construct templete envelopment, always first tag in template
params: size
usage:

<nla:window size="175x280">
...
</nla:window>
-----------------------------------------------------------------%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>

<%@attribute name="size"%>

<%
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Expires", "-1");

	response.setCharacterEncoding("UTF-8");
	//------------------
	request.setAttribute("size", jspContext.getAttribute("size"));
%>

<%-- BODY --%>
<c:choose>
    <c:when test="${empty includes}">
        <c:if test='${!header["RefreshMode"]}'>
            <html>
                <head>
                    <nla:render mask="(BlackBerry|IEMobile|Opera)">
                        <meta http-equiv="refresh" content="3"/>
                    </nla:render>
                    <nla:render mask="(Firefox|MSIE||Chrome|Safari|IEMobile)">
                        <link href="${pageContext.request.contextPath}/css/nlaTemplate.css" type="text/css" rel="stylesheet"/>
                    </nla:render>
                    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
                        <script src="${pageContext.request.contextPath}/js/ajaxRefresh.jsp" type= "text/javascript"></script>
                        <c:if test="${!empty size}">
                            <script type= "text/javascript">
                                var winRef=null;
                                var nla_winSize="${size}";

                                window.oncontextmenu = function(event) {
                                    if (true) {
                                        event.preventDefault();
                                        event.stopPropagation();
                                        return false;
                                    }
                                };
                            </script>
                        </c:if>
                    </nla:render>
                    <title><nla:caption/></title>
                </head>
        </c:if>
        <body onmousedown="if (winRef) parent.activateWin(winRef);">
            <%
                jspContext.setAttribute("includes", "begin",PageContext.REQUEST_SCOPE);
            %>
            <jsp:doBody/>
        </body>
        <c:if test='${!header["RefreshMode"]}'>
            </html>
        </c:if>
    </c:when>
    <c:when test="${includes=='begin'}">
        <jsp:doBody/>
    </c:when>
</c:choose>
