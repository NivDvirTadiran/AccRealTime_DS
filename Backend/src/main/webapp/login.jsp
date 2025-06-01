<%@page import="tadiran.webnla.tag.LocaleMessage, java.util.HashMap, java.net.URLDecoder" pageEncoding="UTF-8"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html>
<head>
    <link rel="icon" href="favicon.ico">
    <title></title>
    <link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>
    <link href="css/nlaTemplate.css" type="text/css" rel="stylesheet"/>

    <%
        //if (request.getAttribute("loginError")==null) {
        //    //logout existing session
        //    session.invalidate();
        //    session=request.getSession(true);
        //}

        //session.setAttribute("dynamicFrontSize", "");
        String langName="en";
        String principal = "";
        String ws_list = "";
        String dp_app_center = "";
        if((String)session.getAttribute("userLogin")!=null)
        {
            String userLogin = "";
            try {
                userLogin = (String)session.getAttribute("userLogin");
            }catch(Exception ignored) {}
            //System.out.println("login.jsp - userLogin="+userLogin);
            session.invalidate();
            session=request.getSession(true);
        }

        //System.out.println("login.jsp - SSO_ENABLE: "+(String)session.getAttribute("SSO_ENABLE"));
        if((String)session.getAttribute("SSO_ENABLE")!=null)
        {
            principal = (String)session.getAttribute("SSO_LOGGED_IN_USERNAME");
            System.out.println("login.jsp - principal="+principal);
        }
        if((String)session.getAttribute("WS_LIST")!=null)
        {
            ws_list = (String)session.getAttribute("WS_LIST");
            //console.log(ws_list);
            //System.out.println("login.jsp - WS_LIST="+ws_list);
        }
        if((String)session.getAttribute("DP_APP_CENTER")!=null)
        {
            dp_app_center = (String)session.getAttribute("DP_APP_CENTER");
            //console.log(dp_app_center);
            //System.out.println("login.jsp - dp_app_center="+dp_app_center);
        }

    %>



    <script language="Javascript">
        function init() {
            var url = new URL(document.location.href);
            var params = url.searchParams.get("params");

            if("<%=dp_app_center%>"==="DP_ENABLE") //Aeonix-App-Center is ON
            {
                if (sessionStorage.getItem("token") === "GATE-SESSION-IS-OVER")
                {
                    var obj = document.getElementsByTagName('tr');
                    for (i=obj.length-1; i>=0; i--) { obj[i].remove();}
                    logoutHeader = document.createElement("p");
                    logoutHeader.innerHTML = "Log out";
                    logoutHeader.style = "color: white; margin-top:15px; margin-left:0;font-size:30px";
                    document.getElementsByTagName('tbody')[0].appendChild(logoutHeader);

                    logoutText = document.createElement("p");
                    logoutText.innerHTML = "You have successfully logged out of application.";
                    logoutText.style = "color: white; margin-top:25px; margin-left:0;font-size:15px"
                    document.getElementsByTagName('tbody')[0].appendChild(logoutText);
                }
                if(params != null)
                {
                    var paramsDecode = b64DecodeUnicode(params);
                    var username = paramsDecode.split(",")[0];
                    var ses_stor_user = username.split(": ")[1];
                    var psw = paramsDecode.split(",")[1];
                    var refreshtoken = paramsDecode.split(",")[2];

                    sessionStorage.setItem("user", "{\"username\": \"" + ses_stor_user + "\"}");
                    sessionStorage.setItem("auth-refreshtoken", refreshtoken);
                    sessionStorage.setItem("token", psw );
                    document.cookie="Authorization=" + sessionStorage.getItem("token") + "; path=/accRealTime;";
                    document.getElementsByName('user')[0].value = username;
                    document.getElementsByName('pass')[0].value = psw;

                    var objsubmit = document.getElementById("submit_login");
                    //System.out.println("login.jsp - objsubmit.click()");
                    objsubmit.click();
                }
                else if (sessionStorage.getItem("token") != null && sessionStorage.getItem("auth-refreshtoken") != null)
                {
                    document.getElementsByTagName('form')[0].setAttribute('hidden',true);
                    document.getElementsByName('user')[0].value = "GateUser: " + JSON.parse(sessionStorage.getItem("user")).username;
                    document.getElementsByName('pass')[0].value = sessionStorage.getItem("token");

                    var objsubmit = document.getElementById("submit_login");
                    objsubmit.click();
                }
                else
                {
                    var obj = document.getElementsByTagName('tr');
                    for (i=obj.length-1; i>=0; i--) { obj[i].remove();}
                    logoutHeader = document.createElement("p");
                    logoutHeader.innerHTML = "RESTRICTED ACCESS";
                    logoutHeader.style = "color: white; margin-bottom: 20px; margin-top:15px; margin-left:0;font-size:29px;margin-block-start: 0;";
                    document.getElementsByTagName('tbody')[0].appendChild(logoutHeader);

                    logoutText = document.createElement("p");
                    logoutText.innerHTML = "Sorry, this URL site is inactive.<br>RealTime web-application can be accessed by the following link:<br>";
                    logoutText.style = "color: white; margin-top:-5px; margin-left:0;font-size:14px"
                    document.getElementsByTagName('tbody')[0].appendChild(logoutText);


                    var createA = document.createElement('a');
                    var myUrl = window.location.href;
                    var myHost = myUrl.split("//")[1].split(":")[0];
                    var myPort = myUrl.split(":")[2].split("/")[0];
                    document.getElementsByTagName('table')[0].setAttribute('style', "position:relative; top:150px;padding-left:50px;padding-top:80px;padding-right:10px;padding-bottom: 10px");
                    createA.setAttribute('href', "https://"+myHost+":"+myPort+"/Aeonix-App-Center/");
                    createA.innerHTML = "Aeonix-App-Center";
                    createA.style = "color: blue; margin-top:25px; margin-left:0;font-size:15px"
                    document.getElementsByTagName('tbody')[0].appendChild(createA);
                }
            }
            else //Aeonix-App-Center is OFF
            {
                if(params != null)
                {
                    var paramsDecode = b64DecodeUnicode(params);
                    var username = paramsDecode.split(",")[0];
                    var psw = paramsDecode.split(",")[1];

                    document.getElementsByName('user')[0].value = username;
                    document.getElementsByName('pass')[0].value = psw;

                    var objsubmit = document.getElementById("submit_login");
                    System.out.println("login.jsp - objsubmit.click()");
                    objsubmit.click();
                }

            }

            if (top !== self) {
                top.location = self.location;
                return;
            }
            var obj=document.getElementsByName('login.WS')[0];
            //ws_list=obj.value;
            //localStorage.setItem("ws_list",ws_list);
            var ws_list="<%=ws_list%>";
            //System.out.println("login.jsp - ws_list ");
            if(ws_list!=="")
                var principal="<%=principal%>";
            if (principal!=="" && principal!=null)
            {
                var obj=document.getElementsByName('user')[0];
                obj.value=principal.substr(0,principal.indexOf("@"));
                //alert("principal="+principal);
                var objsubmit = document.getElementById("submit_login");
                //System.out.println("login.jsp - objsubmit.click()");
                objsubmit.click();
            }

            if (${!empty requestScope.loginError}){
                alert('${requestScope.loginError}');
            }

            var obj=document.getElementsByName('user')[0];

            if (obj.value!="")
                document.getElementsByName('pass')[0].focus();
            else
                obj.focus();

            var obj=document.getElementsByName('login.WS')[0];
        }

        function b64DecodeUnicode(str) {
            // Going backwards: from bytestream, to percent-encoding, to original string.
            return decodeURIComponent(atob(str).split('').map(function(c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
        }
    </script>
</head>


<%-- AviM 10/01/2019 Changes for Aeonix Contact Center login pane, uses 150dpi logo png to set size of pane --%>

<body
        bgcolor="silver"
        onload="init();"
        <c:if test='<%=langName.equals("he")%>'>dir="rtl"</c:if>
        <c:if test='<%=!langName.equals("he")%>'>dir="ltr"</c:if>
>
<form action="login" method="POST">
    <table class="pane_login" align="center" style="position:relative; top:150px;padding-left:50px;padding-top:90px;padding-right:110px;padding-bottom: 50px">

        <tr>
            <td style=" color:white"> <nla:text message="login.User"/></td>
            <td>
                <input type="text" name="user" value="${(empty requestScope.loginError)?(URLDecoder.decode(cookie['userName'].value,"UTF-8")):userName}">
            </td>
        </tr>
        <tr>
            <td style=" color:white"> <nla:text message="login.Pass"/></td>
            <td><input type="password" name="pass"></td>
        </tr>
        <tr hidden>
            <td style=" color:white"> <nla:text message="login.WS"/></td>
            <td><input id="ws_list" type="text" name="WS" value=<%=ws_list%>></td>
        </tr>
        <tr>
            <td style=" color:white"> <nla:text message="login.Lang"/></td>
            <td >
                <select name="lang" style="width:160px;">
                    <%
                        HashMap<String, ?> localeMessages = (HashMap<String, ?>) application.getAttribute("localeMessages");
                        if (localeMessages != null) {
                            for (String _locale : localeMessages.keySet()) {
                                String _localeName = _locale.substring(1);

                    %>
                                <option value="<%=_localeName%>"
                                        key="<%=_localeName%>"
                                        id="<%=_localeName%>"
                                        <%=(_localeName.equals(langName)?"selected":"")%>>
                                                <nla:text message="<%=_localeName%>"/>
                                </option>
                    <%
                            }
                        }
                    %>
                </select>
            </td>
        </tr>

        <tr>
            <td style="padding-left:4px;">
                <!--                        <select name="lang" style="border:0px; outline:none; -webkit-appearance:none; -moz-appearance:spinner; font-size:10px;">
                        <%
                            localeMessages = (HashMap<String, ?>) application.getAttribute("localeMessages");
                        if (localeMessages != null) {
                                for (String _locale : localeMessages.keySet()) {
                                    String _localeName = _locale.substring(1);

                        %>
                                    <option id="<%=_localeName%>" <%=(_localeName.equals(langName)?"selected":"")%>><%=_localeName%></option>
                        <%
                                }
                            }
                        %>
                        </select>-->
            </td>
            <td align="left"><input type="submit" id="submit_login" value='<nla:text message="login.Activity"/>'></td>
        </tr>
    </table>
</form>
</body>
</html>
