<%------------------------------------------------------------
PANE - provide data in pane view
		always used in <nla:obj ref="..."> tag
params: caption - pane caption
		width - pane width
		align - pane align (right and/or: top or bottom)
		cols - data cols in pane
usage:
1.	<nla:obj ref="Group">
		<nla:pane caption="Agents" width="280" cols="2">
			<nla:data key="6_3_1_3_1" name="Logged In"/>
			...
		</nla:pane>
		...
	</nla:obj>

2.	<nla:obj ref="Group">
		<nla:pane caption="By Period (30min)" align="right,top" width="550">
			<nla:pane caption="Inbound" cols="4">
				<nla:data-title text="ACD Calls"/>
					<nla:data key="20_3_1_4_1" name="Accepted"/>
					...
				<nla:data-title text="Avg.Time"/>
				...
			</nla:pane>
			<nla:pane caption="Outbound" cols="4">
			...
			</nla:pane>
			...
		</nla:pane>
	</nla:obj>
-----------------------------------------------------------------%>

<%@attribute name="caption"%>
<%@attribute name="width"%>
<%@attribute name="align"%>
<%@attribute name="cols"%>

<%@tag import="tadiran.webnla.tag.LocaleMessage" %>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>

<c:set var="paneLevel" value="${paneLevel+1}" scope="request"/>
<c:if test="${!empty cols && !(paneLevel>1)}">
    <c:remove var="cols" scope="request"/>
</c:if>
<c:remove var="colWidth"/>
<c:if test="${!empty cols}">
    <c:set var="cols" value="${cols}" scope="request"/>
    <c:set var="currCol" value="-1" scope="request"/>
    <%
        String cols=(String)jspContext.findAttribute("cols");
        if (cols==null) cols="1";
        jspContext.setAttribute("colWidth",100/Integer.parseInt(cols)+"%",PageContext.REQUEST_SCOPE);
    %>
</c:if>

<c:if test="${!(paneLevel>1)}">
    <nla:define name="tabName"/>
    <c:remove var="currRow"/>

    <c:set var="style" value="width:${(!empty width)?width:'100%'};"/>
    <c:set var="css_class" value="pane"/>
    <c:if test="${!empty align}">
        <%
            String[] classNames=((String)jspContext.getAttribute("align")).split(",");
            String paneClassNames="pane";
            for (int i=0; i<classNames.length; i++)
                paneClassNames+=" pane_"+classNames[i];
            jspContext.setAttribute("css_class",paneClassNames);
        %>
        <c:set var="css_class" value="${css_class} pane_right"/>
    </c:if>
	
    <table id="${tabName}" class="${css_class}" style="${style}" border="0" cellpadding="0" cellspacing="0">
        <thead>
            <tr>
                <%
                    String langName=(String)session.getAttribute("Accept-Language");
                    String captionBody="caption."+caption;
                    String caption=LocaleMessage.getMessage(captionBody, langName);
                    //System.out.println(caption);
                    session.setAttribute("captionTrans", caption);
                %>
                <c:set var="captionTranslted" value='${sessionScope.captionTrans}'/>
                <th class="paneTitle" colspan="99">${captionTranslted}</th>
            </tr>
            <tr>
                <th style="height:8px;"></th>
            </tr>
        </thead>
        <tr>
            <td width="${(colWidth!="100%")?colWidth:''}">
                <jsp:doBody/>
            </td>
        </tr>
        <tfoot>
            <tr>
                <td>
                    <c:if test="${empty subPanel}">
                        <br>
                    </c:if>
                        <c:remove var="subPanel"/>
                </td>
            </tr>
        </tfoot>
    </table>
    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
        <onRefresh event="${tabName}_update"></onRefresh>
            <c:if test='${!header["RefreshMode"]}'>
                <script type="text/javascript">
                    // onp pane update
                    function ${tabName}_update(ref) {
                        data_update("${tabName}",ref);
                    }
                </script>
            </c:if>
    </nla:render>
</c:if>
<c:if test="${paneLevel>1}">
    </td>
        </tr>
	<tr>
        <td colspan="${cols}">
        <%
            String langName=(String)session.getAttribute("Accept-Language");
            String captionBody="caption."+caption;
            String caption=LocaleMessage.getMessage(captionBody, langName);
            //System.out.println(caption);
            session.setAttribute("captionTrans", caption);
        %>
        
        <c:set var="captionTranslted" value='${sessionScope.captionTrans}'/>
        <div class="paneTitle paneSubTitle">${captionTranslted}</div>
        <c:if test="${!empty cols}">
            </td>
        </c:if>
        <c:set var="currCol" value="${cols}" scope="request"/>
        <c:remove var="currRow"/>
        <c:set var="subPanel" value="true" scope="request"/>
        <jsp:doBody/>
        </tr>
        <tr>
            <td>
	<br>
</c:if>

<c:set var="paneLevel" value="${paneLevel-1}" scope="request"/>