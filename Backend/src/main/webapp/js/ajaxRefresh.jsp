<%@page pageEncoding="UTF-8" %>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<% 
    String wsList=(String)session.getAttribute("WS_LIST");
    String ws1 = "";
    String ws2 = "";
    if(wsList != null)
    {
        String[] wsListArr = wsList.split(";", 2);
        ws1 = wsListArr[0];
        //22-Sep-2019 YR BZ#50556
        if(wsListArr.length == 2)
            ws2 = wsListArr[1];
        else
            ws2 = null;

    }
    String userName=(String)session.getAttribute("userName");
    String pass=(String)session.getAttribute("pass");
    String dp_app_center = (String)session.getAttribute("DP_APP_CENTER");
%>
var cacheElement=document.createElement("span");

var Request_TIMEOUT=1000; //was 30000
var url=document.location;
var xmlHttpReq = null;
var refreshTokenXmlHttpReq = null;
var pingXmlHttpReq = null;
var self = this;
var timer;
var ws_list = "";
var font = "";
var lang = "";
var pathToGo = "";
var lastPing = "";

// ================================[ initRequest ] =============================
function initRequest()
{
    ws_list = localStorage.getItem("ws_list");
    font = localStorage.getItem("ws_dynamicFrontSize");
    lang = localStorage.getItem("ws_Accept-Language");
    console.log(ws_list);
    self.pingXmlHttpReq  = new XMLHttpRequest();
    if (window.XMLHttpRequest) {
        // Mozilla/Safari
        self.xmlHttpReq = new XMLHttpRequest();
    }
    else
        if (window.ActiveXObject)
        {
            // IE
            try {
                self.xmlHttpReq=new ActiveXObject("Msxml2.XMLHTTP");
            }
            catch (e) {
                self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
            }
        }
        else
            alert("Warning: Axaj does not supported");
}

// ================================[ requestUpdate ] ===========================
function requestUpdate()
{
    if (xmlHttpReq!=null)
    {
        self.xmlHttpReq.open("GET", url, true);
        self.xmlHttpReq.setRequestHeader("RefreshMode","true");
        self.xmlHttpReq.onreadystatechange = doContextUpdate;
        self.xmlHttpReq.setRequestHeader("Authorization", "Bearer " + sessionStorage.getItem("token"));
        self.xmlHttpReq.send(null);
    }
}

// ================================[ requestUpdatePing ] =======================
function requestUpdatePing(url)
{
    if (pingXmlHttpReq!=null)
    {
        self.pingXmlHttpReq.open("GET", url, true);
        //self.pingXmlHttpReq.setRequestHeader("RefreshMode","true");
        self.pingXmlHttpReq.onreadystatechange = doPingContextUpdate;
        self.pingXmlHttpReq.setRequestHeader("Authorization", "Bearer " + sessionStorage.getItem("token"));
        self.pingXmlHttpReq.send(null);
    }
}

// ================================[ showAlert ] ===============================
//18-Jul-2019 BZ#50285
function showAlert()
{
    console.log("ajaxRefresh:showAlert - connectionErr");
    var spanErr = titleOrTiltle_md().document.getElementById("connectionErr");
    if(spanErr != null){
        spanErr.style.color = "red";
        spanErr.innerHTML = 'Connection Lost - Trying to Reconnect';
    }
}

// ================================[ closeAlert ] ==============================
function closeAlert()
{
    console.log("ajaxRefresh:closeAlert - connectionErr");
    var spanErr = titleOrTiltle_md().document.getElementById("connectionErr");
    spanErr.innerHTML = ''; 
    //isPaused=null;
}

// ================================[ showRefresh ] ===============================
function showRefresh()
{
    console.log("ajaxRefresh:showRefresh - connectionErr");
    var spanErr = titleOrTiltle_md().document.getElementById("connectionErr");
    if(spanErr != null){
        spanErr.innerHTML = 'Refreshing..';
    }
}
// ================================[ closeRefresh ] ==============================
function closeRefresh()
{
    console.log("ajaxRefresh:closeRefresh - connectionErr");
    var spanErr = titleOrTiltle_md().document.getElementById("connectionErr");
	if(spanErr != null){
        spanErr.innerHTML = ''; 
	}
    //isPaused=null;
}
// ================================[ closeRefresh ] ==============================
function isRefreshing()
{
    console.log("ajaxRefresh:isRefreshing - connectionErr");
    var spanErr = titleOrTiltle_md().document.getElementById("connectionErr");
    if(spanErr != null){
        if (spanErr.innerHTML == 'Refreshing..')
		{
			return true;
		}
	} 
    
	return false;
}
// ================================[ titleOrTiltle_md ] ==============================
function titleOrTiltle_md()
{
	var currentTitle = parent.parent.document.getElementById("main-page").getElementsByTagName("frame")[0].name;
	var Obj = null;
	if (currentTitle == "title")
	{
		var Obj = parent.parent.title;
	}
	if (currentTitle == "title_md")
	{
		var Obj = parent.parent.title_md;
	}
	return Obj;
}

// ================================[ b64EncodeUnicode ] ========================
function b64EncodeUnicode(str)
{
    // first we use encodeURIComponent to get percent-encoded UTF-8,
    // then we convert the percent encodings into raw bytes which
    // can be fed into btoa.
    return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
        function toSolidBytes(match, p1) {
            return String.fromCharCode('0x' + p1);
    }));
}

// ================================[ runUpdateTimer ] ==========================
function runUpdateTimer()
{
    if(errors == 5)
        showAlert();
        
    //window.status=errors+":"+new Date.now();
    //console.log("ajaxRefresh::showAlert()");
    if (errors < 10)
        timer=setTimeout(requestUpdate,Request_TIMEOUT);
    else
    {
        console.log("ajaxRefresh::runUpdateTimer() - errors " + errors);
        if (parent.isPaused==null)
        {
            parent.isPaused=true;
            parent.isWSChanged=false;
            //showAlert();
            //alert("<nla:text message='winMng.SrvError'/>");
            var ws1="<%=ws1%>";
            var ws2="<%=ws2%>";
            var myUrl = window.location.href;
            var myIp = getIp(myUrl);
            var ws1Ip = getIp(ws1);
            var ws2Ip = getIp(ws2);
            
            var restUrl = "/accRealTime/login.jsp";
            
            if(myIp == ws1Ip && ws2 != null)
            {
                if(ws2 == lastPing)
                {
                    lastPing = ws1;
                    pathToGo = ws1 + restUrl;
                    requestUpdatePing(ws1 + "/accAgent/ping");
                }
                else
                {
                    lastPing = ws2;
                    pathToGo = ws2 + restUrl;
                    requestUpdatePing(ws2 + "/accAgent/ping");
                }
            }
            else
            {
                pathToGo = ws1 + restUrl;
                requestUpdatePing(ws1 + "/accAgent/ping");
            }
            
            /*
            if(ws2 != null && myIp == ws1.split("//")[1].split(":")[0])
            {
                pathToGo = ws2 + restUrl;
                //window.location.assign(ws2 + restUrl);
                requestUpdatePing(ws2 + "/accAgent/ping");
                //parent.parent.document.location=ws2 + restUrl;
            }
            else 
            {
                //window.location.assign(ws1 + restUrl);
                pathToGo = ws1 + restUrl;
                requestUpdatePing(ws1 + "/accAgent/ping");
                //parent.parent.document.location=ws1 + restUrl;
            }
            */
            
            //parent.parent.document.location="../login.jsp";
        }
    }
}

// ================================[ getParams ] =========================
function getParams()
{
    if("<%=dp_app_center%>"=="DP_ENABLE")
            {
                var userName = "GateUser: " + JSON.parse(sessionStorage.getItem("user")).username;
                var pass = sessionStorage.getItem("token");
                var refreshtoken = sessionStorage.getItem("auth-refreshtoken");
                var a1 = userName + ',' + pass + ',' + refreshtoken;
            }
            else
            {
                var userName ="<%=userName%>";
                var pass = "<%=pass%>";
                var a1 = userName + ',' + pass;
            }
            var params = '?params=' + b64EncodeUnicode(a1);//btoa(a1);
            return params;
}

// ================================[ doContextUpdate ] =========================
var errors=0;
function doContextUpdate()
{
    if (self.xmlHttpReq.readyState == 4)
    {
        if (self.xmlHttpReq.status == 200)
        {
            //alert(self.xmlHttpReq.responseText);
            cacheElement.innerHTML=self.xmlHttpReq.responseText;
            x=cacheElement.getElementsByTagName("onRefresh");
            //alert(x.length);
            //console.log("doContextUpdate: cacheElement - " + cacheElement + ", x - " + x + ", length - " + x.length);
            for(var i=0; i< x.length ; i++) {
                //console.log("doContextUpdate: eval(x[i].getAttribute(\"event\") - " + eval(x[i].getAttribute("event"));
                //alert(x[i].getAttribute("event")+"(cacheElement)");
                eval(x[i].getAttribute("event")+"(cacheElement)");
            }
            runUpdateTimer();
            errors=0;
            
            //10-Aug-2022 YR BZ#56641
            //var today = new Date();
            //var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
            var ServerTime = self.xmlHttpReq.getResponseHeader("accServerTime");



            var spanServerTime = titleOrTiltle_md().document.getElementById("accServerTime");
            //console.log("accServerTime: " + ServerTime + ", Local: " + time);.contains("Period")
            if((spanServerTime != null) && (ServerTime != null) && (spanServerTime.innerHTML != ServerTime)){
                //spanServerTime.innerHTML = time;
                console.log("Updating accServerTime - " + ServerTime);
                spanServerTime.innerHTML = ServerTime;
                //spanServerTime.innerHTML = self.xmlHttpReq.getResponseHeader("accServerTime");
            
            //var spanServerTime = parent.parent.title.document.createElement('div');
            //spanServerTime.innerHTML = self.xmlHttpReq.getResponseHeader("accServerTime");
            //parent.parent.title.document.getElementById("accServerTime").appendChild(spanServerTime);
            }
        }
        else if (self.xmlHttpReq.status == 401 )
        {
			runUpdateTimer(Request_TIMEOUT);
			
            if ( isRefreshing() == false )
            {
		refreshToken(false);
				
            }
            else
            {
                		console.log( "Token is expired and refresh process is already on");
            }
        }
        else 
        {
            errors++;
            runUpdateTimer(Request_TIMEOUT*5);
        }
    }
}

// ================================[ doPingContextUpdate ] =====================
function doPingContextUpdate()
{
    if (self.pingXmlHttpReq.readyState == 4)
    {
        if (self.pingXmlHttpReq.status == 200)
        {
            parent.parent.document.location = pathToGo + getParams();
        }
        else if (self.pingXmlHttpReq.status == 401 )
        {
			runUpdateTimer(Request_TIMEOUT);
                        
			
            if ( isRefreshing() == false ) {
            
                if (refreshToken(true))
                    parent.parent.document.location = pathToGo + getParams();		
            }
            else
            {
				console.log( "Token is expired and refresh process is already on");
            }
        }
        else 
        {
            errors=8;
            parent.isPaused=null;
            runUpdateTimer();
        }
    }
    else
    {
        errors=8;
        parent.isPaused=null;
        runUpdateTimer();
    }
}
// ================================[ refreshToken ] =============================
function refreshToken(toClusterIp)
{

    showRefresh();
    console.log("xmlHttpReq.status - 401");
    console.log( "Starting Token refresh process.");
    var data = JSON.stringify({
            "refreshToken": sessionStorage.getItem("auth-refreshtoken")
    });

    var myUrl = window.location.href;
    var myIp = myUrl.split("//")[1].split(":")[0];
    var clusterIp;
    var ws1="<%=ws1%>";
    var ws2="<%=ws2%>";
    var ws1Ip = getIp(ws1);
    var ws2Ip = getIp(ws2);
    if(myIp == ws1Ip && ws2Ip != null)
    { 
        clusterIp = ws2Ip;
    }
    else
    {
        clusterIp = ws1Ip;
    }
    var myHost = (toClusterIp ? clusterIp : myIp );
    var myPort = myUrl.split(":")[2].split("/")[0];
    refreshTokenXmlHttpReq  = new XMLHttpRequest();
    refreshTokenXmlHttpReq.open("POST", "https://"+myHost+":"+myPort+"/Aeonix-App-Center/auth/refreshtoken", true);
    refreshTokenXmlHttpReq.setRequestHeader("message", "just a message");
    refreshTokenXmlHttpReq.setRequestHeader("Content-Type", "application/json");
    refreshTokenXmlHttpReq.setRequestHeader("Authorization", "Bearer " + sessionStorage.getItem("token"));
    refreshTokenXmlHttpReq.onreadystatechange = function()
    {
            if (this.readyState == 4 ) {
                    if (this.status == 200) {
                            sessionStorage.setItem("auth-refreshtoken", JSON.parse(refreshTokenXmlHttpReq.responseText).refreshToken.toString());
                            sessionStorage.setItem("token", JSON.parse(refreshTokenXmlHttpReq.responseText).accessToken.toString());
                            document.cookie="Authorization=" + sessionStorage.getItem("token") + "; path=/accRealTime;";
                            if (JSON.parse(refreshTokenXmlHttpReq.responseText).accessToken.toString() != null) { requestUpdate();}
                            closeRefresh();
                            return true;
                    }
                    else
                    {
                            console.log( "Token refresh process failed! ");
                            closeRefresh();
                            return true;
                    }
            }
    }
    return refreshTokenXmlHttpReq.send(data);
}

// ================================[ getIp] =============================
function getIp(url)
{
	if (url == null || url == "null" || url == "" )
	{
		return null
	}
	else
	{
		return url.split("//")[1].split(":")[0];
	}
}

// ================================[ data_update ] =============================
// called by pane/table on data refresh event to display updated data
function data_update(objName, ref)
{
    //alert("kuku");
    var obj;
    if (ref.children)
        obj=ref.children[objName];
    else
    {
        for (var i=0; i< ref.childNodes.length ; i++)
        {
            if (ref.childNodes[i].id==objName)
            {
                obj=ref.childNodes[i];
                break;
            }
        }
    }

    if (obj.nodeName!="TABLE") 
    {
        document.getElementById(objName).innerHTML=obj.innerHTML;
    }
    else
    {
        var oTable=document.getElementById(objName);
        if (obj.tBodies.length>0)
        {
            if (oTable.tBodies.length>0)
                oTable.removeChild(oTable.tBodies[0]);

            oTable.appendChild(obj.tBodies[0]);
        }
    }
}


initRequest();
runUpdateTimer();

