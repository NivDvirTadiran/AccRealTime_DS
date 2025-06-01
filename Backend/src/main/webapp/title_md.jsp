<%@page pageEncoding="UTF-8" language="java" import="tadiran.webnla.tag.LocaleMessage, java.util.HashMap, java.net.URLDecoder" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%
	String version="v2.1";
        String smallClass;
        String meduimClass;
        String bigClass;
        String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
	String langName=(String)session.getAttribute("Accept-Language");
        String accVersion=(String)session.getAttribute("accVersion");
        
        if(dynamicFrontSize != null && dynamicFrontSize.equals("meduimSize")){
            smallClass = "unSelectedChangeFontSize";
            meduimClass = "selectedChangeFontSize";
            bigClass = "unSelectedChangeFontSize";
        }
        else if(dynamicFrontSize != null && dynamicFrontSize.equals("bigSize")){
            smallClass = "unSelectedChangeFontSize";
            meduimClass = "unSelectedChangeFontSize";
            bigClass = "selectedChangeFontSize";
        }  
        else {
            smallClass = "selectedChangeFontSize";
            meduimClass = "unSelectedChangeFontSize";
            bigClass = "unSelectedChangeFontSize";
        }
        
        System.out.println("title_md.jsp(1) - Attribute Accept-Language " + langName);
%>


<html>
<head>
	<style type="text/css">
		body {
			font-family:Arial;
		}
		.serviceName {
			color:#191C54;
			font-size:15pt;
			font-weight:bold;
			position:relative;
			top:-7px;
			font-family:Tahoma;
		}
                .unSelectedChangeFontSize{
                    font-weight: normal;
                    color:gray;
                    text-decoration:none;
                }
                .selectedChangeFontSize{
                    font-weight: bold;
                    color:blue;
                    text-decoration:underline;
                }
                .disabled {
                    pointer-events: none;
                    cursor: default;
                }
                 
	</style>
        
</head>

<%-- AviM 14/01/2019 Changes for Aeonix Contact Center workspace display --%>

<body>

    <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td rowspan="2">
                <a href="http://www.tadirantele.com" target="_blank"><img src="img/aeonix_logo_72.png" border="0"></a>&nbsp;
                <span class="serviceName">by Tadiran Telecom</span>
                <span class="serviceName" style="font-size:75%; font-weight: normal">Version : <%=accVersion%></span>
                <span style="font-size:150%; font-weight:bold; margin-left: 5px" id="connectionErr"></span> 
            </td>
            <td align="right" style="padding-right:5px; font-size:11px; padding-top:3px;" valign="center">
                <%--<nla:text message="tools.User"/>: <img src="img/user.png" border="0" width="14" align="center">&nbsp;<b>${cookie['userName'].value}</b>--%>
                <nla:text message="tools.User"/>: <img src="img/user.png" border="0" width="14" align="center">&nbsp;<b>${URLDecoder.decode(cookie['userName'].value,"UTF-8")}</b>
                <%--<nla:text message="tools.User"/>: <%String decodeUserName=URLDecoder.decode((cookie['userName'].value).toString(),"UTF-8");  %><b><%=decodeUserName%></b>&nbsp;<img src="img/user.png" border="0" width="14" align="center">--%>
                <%--<nla:text message="tools.User"/>: <%String decodeUserName=URLDecoder.decode(session.getAttribute("userName").toString(),"UTF-8");  %><b><%=decodeUserName%></b>&nbsp;<img src="img/user.png" border="0" width="14" align="center">--%>
                <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                <a href="login.jsp" onClick="logoutGate()" style="color:blue;" target="_parent" title='<nla:text message="tools.Logout"/>'><img src="img/logout.png" border="0" width="15" align="center"></a>
			
            </td>
        </tr>
        <tr>
            <td id="t1" align="right" valign="center" style="padding-bottom:3px; padding-right:5px; font-size:14px;">
                <span id="tools">
                    <%--select id="selectBox_MD" name="lang" style="width:100px;" onchange="javascript:parent.mainwin_md.changeLang();javascript:parent.mainwin_md.restoreWS();javascript:setTimeout('location.reload();',1500);"--%>
                    <select id="selectBox_MD" name="lang" style="width:130px;" onchange="javascript:parent.mainwin_md.changeLang();">
                    <%
                        //String langName2=(String)session.getAttribute("Accept-Language");
                        //System.out.println("title.jsp(2) - Attribute Accept-Language " + langName2);
                        for(String _locale:((HashMap<String,?>)application.getAttribute("localeMessages")).keySet()) {
                            String _localeName=_locale.substring(1);

                    %>
                    <option value="<%=_localeName%>"  key="<%=_localeName%>" id="<%=_localeName%>" <%=(_localeName.equals(langName)?"selected":"")%>><nla:text message="<%=_localeName%>"/></option>
                    <%
                        }
                        //String langName3=(String)session.getAttribute("Accept-Language");
                        //System.out.println("title.jsp(3) - Attribute Accept-Language " + langName3);
                    %>
                    </select>
                    <%--
                    <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                    <a id="small" disabled class ="<%=smallClass%>" href="javascript:parent.mainwin_md.changeFrontSize('');javascript:parent.mainwin_md.restoreWS();" onClick="boldSmall()" style="font-size: 10px">A</a>
                    <a id="meduim" class ="<%=meduimClass%>" href="javascript:parent.mainwin_md.changeFrontSize('meduimSize');javascript:parent.mainwin_md.restoreWS();" onClick="boldMeduim()" style="font-size: 15px">A</a>
                    <a id="big" class ="<%=bigClass%>" href="javascript:parent.mainwin_md.changeFrontSize('bigSize');javascript:parent.mainwin_md.restoreWS();" onClick="boldBig()" style="font-size: 22px">A</a>
                    <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                    <a id="showDialog" href="javascript:parent.mainwin_md.showDialog('openDialog.jsp',350,300);" onClick="showDialog()" style="color:blue;" title='<nla:text message="tools.Open"/>'><img src="img/template.png" border="0" width="16" align="center"></a>
                    <a href="javascript:parent.mainwin_md.saveReport();" style="color:blue;" title='<nla:text message="tools.SaveAs"/>'><img src="img/save.png" border="0" width="16" align="center"></a> <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                    <a href="javascript:parent.mainwin_md.restoreWS();javascript:parent.mainwin_md.restoreLangFont(); javascript:location.reload();" style="color:blue;" title='<nla:text message="tools.RestoreWS"/>'><img src="img/reload_ws.gif" border="0" width="16" align="center"></a>
                    <a href="javascript:parent.mainwin_md.saveWS();" style="color:blue;" title='<nla:text message="tools.SaveWS"/>'><img src="img/save-ws.png" border="0" width="16" align="center"></a>
                    --%>
                    <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                    <c:if test="${sessionData.supLevel!=4}">
                        <a href="javascript:parent.mainwin_md.showDialog('loginManager.jsp',640,300);" style="color:blue;" title='<nla:text message="tools.LoginMng"/>'><img src="img/loginMng.png" border="0" width="16" align="center"></a> <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                    </c:if>
                    <a href="index.jsp" style="color:blue;" target="_parent" title='<nla:text message="tools.flat"/>'><img src="img/management.png" border="0" width="15" align="center"></a>
                    <span style="font-size:12px; color:#ddd;">&nbsp;|&nbsp;</span>
                </span>
                <a href="help/index.html" target="_blank" style="color:blue;" title='<nla:text message="tools.Help"/>'><img src="img/help.png" border="0" width="16" align="center"> </a>
            </td>
        </tr>
    </table>
</body>

<script type="text/javascript">
    window.oncontextmenu = function(event) {
        event.preventDefault();
        event.stopPropagation();
        return false;
    };
    
    function update(input)
{
        $("#refresh").html(input)
}
    
    function onMouse(event, size) {
        event = event || window.event;
        var obj=event.srcElement || event.target;
        obj.width=size;
    }
    
    function boldSmall() {
        document.getElementById("small").className = "selectedChangeFontSize";
          document.getElementById("meduim").className = "unSelectedChangeFontSize";
          document.getElementById("big").className = "unSelectedChangeFontSize";
     }
     
      function boldMeduim() {
          document.getElementById("small").className = "unSelectedChangeFontSize";
          document.getElementById("meduim").className = "selectedChangeFontSize";
          document.getElementById("big").className = "unSelectedChangeFontSize";
     }
     
      function boldBig() {
          var test1 = parent.document.getElementById("mainwin_md");
          var test2 = document.getElementById("showDialog");
          document.getElementById("small").className = "unSelectedChangeFontSize";
          document.getElementById("meduim").className = "unSelectedChangeFontSize";
          document.getElementById("big").className = "selectedChangeFontSize";
     }
     function showDialog() {
          document.getElementById("small").className = document.getElementById("small").className+" disabled";
          document.getElementById("meduim").className = document.getElementById("meduim").className+" disabled";
          document.getElementById("big").className = document.getElementById("big").className+" disabled";
     }
     function logoutGate() {
            if (sessionStorage.getItem("token") !== null && JSON.parse(sessionStorage.getItem("user")).username !== null)
            { 
                sessionStorage.clear();
                sessionStorage.setItem("token","GATE-SESSION-IS-OVER");
                document.cookie="Authorization=";
            }
     }
    function reloadTitleMdWin()
    {
        document.location.reload(true);
    }
     
    if (document.all)
        document.getElementById("t1").style.paddingBottom="";

    var images=document.getElementsByTagName("img");
    for(var i=0; i<images.length; i++) {
        if (images[i].align=="bottom") {
            images[i].onmouseover=function(e) { onMouse(e,20); };
            images[i].onmouseout=function(e) { onMouse(e,16); };
        }
    }
    
</script>
</html>
