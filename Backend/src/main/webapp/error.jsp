<%@ page isErrorPage = "true"%>
<%@ page import = "java.io.*" %>

<%
	String error="no errors";
	if (exception!=null) {
		error=exception.toString();
		error=error.substring(error.indexOf(":")+2);
		error="<span style='color:blue;'>"+error.replaceFirst("\\)", ")</span><br>");
	}
%>

<html>
<head>
	<title><span style="color:OrangeRed;">Error Message</span></title>
</head>
<body>
	<font size="2"><%=error%></font>
</body>
</html>