<%@page pageEncoding="UTF-8" import="tadiran.webnla.bean.SessionData, tadiran.emisweb.ReportListDataItemType" %>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>

<%
        String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
	String report_name=request.getParameter("name");
	long report_public=0;
	try {
		Long report_id=Long.parseLong(request.getParameter("id"));
		SessionData sessionData=(SessionData)session.getAttribute("sessionData");
		ReportListDataItemType report_item=sessionData.getReports().get(report_id);
		report_name=report_item.getReportName();
		report_public=report_item.getIsPublic();
	}
	catch(NumberFormatException e) {
		// new report
		//rep_item.setRenderName(rep_id);
	}
	catch(Exception e2) {
	}
    
    String langName=(String)session.getAttribute("Accept-Language");
%>

<html>
<head>
	<title><nla:text message='save.Title'/></title>
	<link href="css/nlaTemplate.css" type="text/css" rel="stylesheet"/>
	<link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>
</head>
<body class="toolsBody" <%=(langName.equals("he"))?"dir='rtl'":""%>>
<form action="processActivity" method="post">
	<table class="pane" align="center" style="border:1px solid silver; background-color:LemonChiffon;" width="100%" height="100%">
		<tr>
			<td colspan="2" align="center" bgcolor="gold" style="font-weight:bold; height:10px;">
				<span class="closeBtn ${dynamicFrontSize}" onmousedown="parent.closeSubmitWin(null,null);" title="<nla:text message="tools.CloseWin"/>" UNSELECTABLE="ON" style="background:none; position:absolute; left:3px;top:0px;">x</span>
				<nla:text message='save.Title'/></td>
		</tr>
		<tr><td style="height:10px;"></td></tr>
		<tr>
			<td width="50"><nla:text message='save.Name'/></td>
			<td><input type="input" id="rep_name" name="rep_name" value="<%=((report_name.length()>32)?report_name.substring(0,32):report_name)%>" style="width:100%;" maxlength="32"></td>
		</tr>
		<tr>
			<td></td>
			<td style="color:gray; font-style:italic;" valign="top"><input type="checkbox" name="rep_public" value="true" <%=(report_public==1?"checked":"")%> title="<nla:text message='save.PublicTip'/>"><nla:text message='save.Public'/></td>
		</tr>
		<tr><td style="height:5px;"></td></tr>
		<tr>
			<td colspan="2" align="center" style="border-top:1px solid lightGrey;"><input type="submit" value="<nla:text message='save.Activity'/>"></td>
		</tr>
	</table>
	<input type="hidden" name="rep_id" value="${param.id}">
	<input type="hidden" name="rep_params" value="${param.params}">
        <input type="hidden" name="rep_renderName" value="${param.renderName}">
	<input type="hidden" name="activity" value="save_report">
        
</form>
</body>
<script type= "text/javascript">
	document.getElementById("rep_name").focus();
</script>
</html>
