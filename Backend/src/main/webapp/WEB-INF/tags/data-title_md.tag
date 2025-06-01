<%------------------------------------------------------------
DATA-TITLE - display text title
params: text - (mandatory param) text to display

usage:
...
<nla:pane caption="Inbound" cols="4">
	<nla:data-title text="ACD Calls"/>
		<nla:data key="20_3_1_4_1" name="Accepted"/>
	...
</nla:pane>
-----------------------------------------------------------------%>

<%@attribute name="text" required="true"%>

<%@tag import="tadiran.webnla.tag.LocaleMessage" %>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:if test="${!empty cols}">
	<c:if test="${!empty currRow}">
		</td>
	</c:if>
	<c:if test="${empty currRow}">
		</tr>
		<tr>
	</c:if>
	<td width="${colWidth}" valign="top">
</c:if>
<%
    String langName=(String)session.getAttribute("Accept-Language");
    String textBody="data-title."+text;
    String caption=LocaleMessage.getMessage(textBody, langName);
    //System.out.println(caption);
    session.setAttribute("dataTitleTrans", caption);
%>
<c:set var="dataTitleTrans" value='${sessionScope.dataTitleTrans}'/>
<div class="dataTitle"><span class="dataTitleText">${dataTitleTrans}</span></div>
<c:if test="${!empty cols}">
	<c:set var="currCol" value="-1" scope="request"/>
	<c:set var="currRow" value="1" scope="request"/>
</c:if>