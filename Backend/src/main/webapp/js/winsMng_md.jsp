<%@page pageEncoding="UTF-8" %>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%
   
    String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
    String langName=(String)session.getAttribute("Accept-Language");
    
    System.out.println("winsMng_md.jsp(1) - Attribute Accept-Language " + langName);
%>

//---------------------------------------------------- window drag/drop functions
var dragapproved=false;
var resizeapproved=false;
var startX,startY;
var dtObj=null, oldDtObj=null, dtObjFrame;
var maxZind=0;
var isWSChanged=false;
var openRepCategories="";
var closeTemplateGroups="";
var isPaused=null;
var xmlHttpReq = null;
var keepAliveTimeout=10000; //20000;

initKeepAlive();

//---------- initKeepAlive ----------//
function initKeepAlive()
{
    if (window.XMLHttpRequest) {
        // Mozilla/Safari
        xmlHttpReq = new XMLHttpRequest();
    }
    else
    if (window.ActiveXObject) {
        // IE
        try {
            xmlHttpReq=new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
            xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
        }
    }
	
    if (xmlHttpReq!=null && keepAliveTimeout>0)
        setInterval(testKeepAlive,keepAliveTimeout);
}


//18-Jul-2019 BZ#50285
//------------------- showAlert -------------------//
function showAlert()
{
    console.log("winsMng:showAlert - connectionErr");
    var spanErr = parent.title_md.document.getElementById("connectionErr");
    spanErr.style.color = "red";
    spanErr.innerHTML = 'Connection Lost - Trying to Reconnect';
}


//------------------- closeAlert ------------------//
function closeAlert()
{
    console.log("winsMng:closeAlert - connectionErr");
    var spanErr = parent.title_md.document.getElementById("connectionErr");
    spanErr.innerHTML = ''; 
    isPaused=null;
}


//----------------- testKeepAlive -----------------//
function testKeepAlive()
{
    var skip = false;
    //console.log("winsMng:testKeepAlive - xmlHttpReq.status " + xmlHttpReq.status + ", xmlHttpReq.readyState " + xmlHttpReq.readyState);
    if (xmlHttpReq.readyState == 0)
    {
        skip = true;
        xmlHttpReq.open("GET", "alive.jsp", true);
    }
            
    xmlHttpReq.onreadystatechange = function()
    {
        //console.log("winsMng:testKeepAlive - onreadystatechange function()- xmlHttpReq.status " + xmlHttpReq.status + ", xmlHttpReq.readyState " + xmlHttpReq.readyState);
        //if (xmlHttpReq.readyState == 4 && xmlHttpReq.status == 200)
        if (xmlHttpReq.status != 0 && xmlHttpReq.status != 200)
        {
            if (isPaused==null)
            {
                isPaused=true;
                showAlert();
            }
        }
        else
        {
            if (isPaused)
            {
                isPaused=null;
                closeAlert();
            }
        }
    }//end function 

    if (!skip)
        xmlHttpReq.open("GET", "alive.jsp", true);
    else
        skip = false;
            
    xmlHttpReq.send(null);
 }


//-------------------- dragMove -------------------//
function dragMove(event)
{
    event = event || window.event;
    if (dragapproved && (event.button || event.which)==1)
    {
        dtObj.style.left=temp1+event.clientX-startX;
        dtObj.style.top=temp2+event.clientY-startY;

        if (parseInt(dtObj.style.top)<10)
            dtObj.style.top="10px";
        if (parseInt(dtObj.style.left)+parseInt(dtObj.style.width)<30)
            dtObj.style.left=-(parseInt(dtObj.style.width)-30)+"px";

        if (dtObjFrame==null)
        {
            dtObjFrame=document.getElementById("workspaceLayer");
            dtObjFrame.style.display="inline";
        }

        return false;
    }

    disableMove(event);
    return false;
}


//------------------- resizeMove ------------------//
function resizeMove(event)
{
    event = event || window.event;
    if (resizeapproved && (event.button || event.which)==1)
    {
        dtObj.style.width=temp1+event.clientX-startX;
        dtObj.style.height=temp2+event.clientY-startY;

        if (parseInt(dtObj.style.width)<250)
                dtObj.style.width="250px";
        if (parseInt(dtObj.style.height)<100)
                dtObj.style.height="100px";

        if (dtObjFrame==null) {
            dtObjFrame=document.getElementById("workspaceLayer");
            dtObjFrame.style.display="inline";
        }

        return false;
    }

    disableMove(event);
    return false;
}


//------------------ disableMove ------------------//
function disableMove(event)
{
    document.onmousemove=null;
    dragapproved=false;
    resizeapproved=false;
    
    event = event || window.event;
    if ((event.clientX-startX)!=0 || (event.clientY-startY)!=0)
    {
        isWSChanged=true;
    }

    if (dtObjFrame!=null)
    {
        dtObjFrame.style.display="none";
        dtObjFrame=null;
    }
}


//--------------- setMouseEventProps --------------//
function setMouseEventProps(event, obj, func)
{
    startX=event.clientX;
    startY=event.clientY;

    dtObj=obj;
    document.onmousemove=func;
    activateWin(obj);
}


//--------------------- drags ---------------------//
function drags(event)
{
    event = event || window.event;
    var obj=(event.srcElement || event.target).parentNode;
    if (obj.className=="nlaWindowCaption")
        obj=obj.parentNode;

    if (obj.className.indexOf("drag")!=-1)
    {
        dragapproved=true;
        temp1=(obj.style.pixelLeft | parseInt(obj.style.left));
        temp2=(obj.style.pixelTop | parseInt(obj.style.top));
        setMouseEventProps(event, obj, dragMove);
    }
}

//---------------------------------------------------- window resize functions

//-------------------- resizes --------------------//
function resizes(event)
{
    event = event || window.event;
    var obj=(event.srcElement || event.target).parentNode;

    resizeapproved=true;
    temp1=parseInt(obj.style.width);
    temp2=parseInt(obj.style.height);
    setMouseEventProps(event, obj, resizeMove);

    event.cancelBubble = true;
    if (event.stopPropagation)
        event.stopPropagation();
}


document.onmousedown=drags;
document.onmouseup=disableMove;

//------------------------------------------------------ window functions

var activeSelectBox=null;

// remove window
var winToRemove=null;

//------------------- removeWin -------------------//
function removeWin(event, obj)
{
    if (!obj.isSaved && obj.isWSReport)
    {
        if (confirm("<nla:text message='winMng.UnsavedWindow'/>"))
        {
            saveReport(obj);
            winToRemove=obj;
            return;
        }
    }

    if (event!=null)
    {
        event.cancelBubble = true;
        if (event.stopPropagation)
            event.stopPropagation();
    }
    
    var flag=(obj==oldDtObj);
    var nextWin=obj.nextSibling;
    if (nextWin==null || nextWin.name!="win")
        nextWin=obj.previousSibling;
    obj.parentNode.removeChild(obj);

    if (activeSelectBox==obj) activeSelectBox=null;

    if (flag)
    {
        oldDtObj=null;
        activateWin(nextWin);
    }
    isWSChanged=true;
}

// activate (select) window
//------------------ activateWin ------------------//
function activateWin(winRef)
{
    if (winRef && winRef.name=="win")
    {
        if (winRef.style.zIndex!=maxZind)
        {
            winRef.style.zIndex=++maxZind;
        }

        if (winRef.style.borderColor=="")
        {
            if (oldDtObj!=null)
            {
                oldDtObj.firstChild.style.backgroundColor="";
                oldDtObj.style.borderColor="";
                oldDtObj.style.opacity=0.95;
            }

            winRef.firstChild.style.backgroundColor="#555"; // Gold, LightSlateGray, DarkGoldenRod, Maroon, Orange, #555
            winRef.style.borderColor="#555";
            winRef.style.opacity=1;
            oldDtObj=winRef;
        }
    }
}

// on window load event
//------------------ onWinLoad -------------------//
function onWinLoad(refWin, docWin)
{
    var templateTitle=docWin.document.title;
    var templateRef=templateTitle.match(/<(.)+>/g); //ids in SPAN tag
    var title=refWin.firstChild.lastChild;
    if (refWin.reportName==null)
        title.innerHTML=templateTitle;
    else
    {
        var tmpRef=(templateRef!=null)?templateRef:"";
        /*if (refWin.reportName.match(/\[(.)+\]/g)!=null)
            title.innerHTML=refWin.reportName.replace(/\[(.)+\]/g,tmpRef);
        else*/
                 
        title.innerHTML= decodeURIComponent( refWin.reportName )+" "+tmpRef;
        //title.innerHTML=encodeURI( refWin.reportName )+" "+tmpRef;
        //title.innerHTML=URLEncoder.encode(refWin.reportName,"UTF-8")+" "+tmpRef;
        //title.innerHTML=URLDecoder.decode(refWin.reportName,"UTF-8")+" "+tmpRef;
        //title.innerHTML=refWin.reportName+" "+tmpRef;
        title.title=templateTitle.replace(/<(.)+>/g,"");
    }
    if (docWin.nla_winSize)
    {
        if (document.all)
            refWin.lastChild.previousSibling.height="95%";
		
        docWin.winRef=refWin;
        if (!refWin.isWSReport)
        {
            var size=docWin.nla_winSize.split("x");
            refWin.style.width=size[0];
            refWin.style.height=size[1];
        }
    }

    if (docWin.nla_titleColor)
    {
        activeSelectBox=refWin;
        refWin.firstChild.style.backgroundColor=docWin.nla_titleColor;
        refWin.style.borderColor="#eee "+docWin.nla_titleColor+" "+docWin.nla_titleColor;
    }
    else
    {
        activeSelectBox=null;
        title.innerHTML=(refWin.isSaved?"":"* ")+title.innerHTML;
        refWin.firstChild.style.backgroundColor="";
        refWin.style.borderColor="";
        activateWin(refWin);
        if (docWin.document.getElementById("tabName1")!=null)
        {
            refWin.lastChild.style.display="none";
            refWin.style.background="white";
        }
    }
}

// create window
//-------------------- addWin ---------------------//
function addWin(winUrl,id,name,x,y,w,h)
{
    if (activeSelectBox!=null)
    {
        activateWin(activeSelectBox);
        alert("<nla:text message='winMng.Opened'/>");
        return;
    }
        
    var winData='<div id="title" class="nlaWindowCaption ${dynamicFrontSize}"><span class="closeBtn ${dynamicFrontSize}" onmousedown="removeWin(event,this.parentNode.parentNode);" title="<nla:text message="tools.CloseWin"/>" UNSELECTABLE="ON">x&nbsp;</span><span UNSELECTABLE="ON" style="-moz-user-select: none;"></span></div>';
    winData+='<iframe id="body" src="'+winUrl+'" width="100%" height="100%" frameborder="0" scrolling="no" style="margin-top:-5px;" onload="onWinLoad(this.parentNode, this.contentWindow);"/>';
    <%--
    winData+='<iframe id="body" src="'+winUrl+'" width="100%" height="100%" frameborder="0" scrolling="no" style="margin-top:-5px;" onload="onWinLoad(this.parentNode, this.contentWindow);"/>';
    --%>
    <%--
    <% System.out.println( "winsMng.jsp:addWin" ); %>
    if (typeof x=="undefined") x="40%";
    if (typeof y=="undefined") y="35%";
    if (y<10) y=10;
    --%>
    if (typeof x=="undefined") x=100+Math.random()*640;
    if (typeof y=="undefined") y=50+Math.random()*480;
    if (y<10) y=10;
    if (typeof w=="undefined") w=200;
    if (typeof h=="undefined") h=200;

    console.log( "winsMng.jsp:addWin - winUrl: " + winUrl + ", id: " + id + ", name: " + name + ", x:" + x + ",y:" + y + ", w:" + w + ", h:" + h );
    console.log( "winsMng.jsp:addWin - winData: " + winData );
    
    var objWin = document.createElement('div');
    if (id.substring==null)
        objWin.isSaved=true;
    else
    {
        objWin.isSaved=false;
        isWSChanged=true;
    }
    if (w==200 && h==200)
        objWin.isWSReport=false;
    else
        objWin.isWSReport=true;

    objWin.id=id;
    objWin.reportName=(typeof name=="undefined")?null:name;
    objWin.name="win";
    objWin.className="nlaWindow drag  ${dynamicFrontSize}";
    objWin.style.opacity=0.95;
    objWin.style.position="absolute";
    objWin.style.left=x;
    objWin.style.top=y;
    <%--24-Feb-2019 YR BZ#28512
    objWin.style.left="40%"; //x;
    objWin.style.top="35%";  //y;
    objWin.style.margin= "auto";--%>
    objWin.style.width=w;
    objWin.style.height=h;
    objWin.style.zIndex=++maxZind;
    objWin.innerHTML=winData;

    console.log( "winsMng.jsp:addWin - objWin: " + objWin );
    
    var obj=document.createElement('div');
    obj.className="nlaWindowResizeCorner";
    <%--
    if (!document.all)
        obj.style.bottom="34px";
    --%>
    obj.innerHTML="&nbsp;";
    obj.title="<nla:text message='winMng.Resize'/>";
    obj.onmousedown=resizes;
    objWin.appendChild(obj);

    document.body.appendChild(objWin);

    console.log( "winsMng.jsp:addWin - obj: " + obj );
    
    var titleHeight = document.getElementById("title").style.height;
        
}

// change window id
//------------------- changeId --------------------//
function changeId(srcObj,srcParam)
{
    if (activeSelectBox!=null)
    {
        activateWin(activeSelectBox);
        alert("<nla:text message='winMng.Opened2'/>");
        return;
    }

    var refObj=srcObj.parentNode.parentNode.nextSibling;
    var url=refObj.contentWindow.document.location.href;

    url=url.replace(new RegExp(srcParam+"(&|$)"),"").replace(/(&|\?)$/,"");
    srcParam=srcParam.replace(/^(.)+=/,"objId=");
    refObj.src=url+((url.indexOf("?")>=0)?"&":"?")+srcParam;
    srcObj.parentNode.parentNode.parentNode.isSaved=false;

    isWSChanged=true;
}

var objDialog=null;
//----------------- closeSubmitWin -----------------//
function closeSubmitWin(respParams,respMessage)
{
    //return;
    if (objDialog)
    {
        if (objDialog.name=="saveWSWin")
        {
            var wins=document.body.getElementsByTagName("div");
            var j=0;
            var name;
            for (var i=0; i < wins.length ; i++)
                if (wins[i].name=="win" && j < respParams.length)
                {
                    wins[i].id=respParams[j++];
                    wins[i].isSaved=true;
                    name=wins[i].firstChild.lastChild.innerHTML;
                    if (name.charAt(0)=="*")
                    {
                        name=name.substring(2, name.length);
                        wins[i].firstChild.lastChild.innerHTML=name;
                    }
                }

            document.body.removeChild(objDialog);
        }
        else
            if (objDialog.name=="saveReportWin")
            {
                var objBody=objDialog.ref.getElementsByTagName("iframe")[0];
                if (respParams!=null)
                {
                    objDialog.ref.id=respParams[0];
                    objDialog.ref.reportName=respParams[1];
                    objDialog.ref.isSaved=true;

                    var templateTitle=objBody.contentWindow.document.title;
                    var templateRef=templateTitle.match(/<(.)+>/g);
                    var title=objDialog.ref.firstChild.lastChild;
                    title.innerHTML=respParams[1]+((templateRef!=null)?" "+templateRef:"");
                    title.title=templateTitle.replace(/<(.)+>/g,"");

                    if (winToRemove!=null) {
                        removeWin(null, winToRemove);
                    }
                }

                winToRemove=null;

                objBody.style.opacity="";
                objBody.style.filter="";

                objDialog.ref.removeChild(objDialog);
            }

        parent.title_md.document.getElementById("tools").onclick=null;

        if (respMessage!=null)
            alert(respMessage);
    }
    objDialog=null;
}

//------------------- saveReport -------------------//
function saveReport(objWin)
{
    if (objWin==null) {
        objWin=oldDtObj;
    }
    var url=objWin.lastChild.previousSibling.contentWindow.location.href;
    var ind=url.indexOf("?");
    if (ind>0)
        url=url.substring(ind+1,url.length);
    else
        url="";
    url=url.replace(/&/g, "%26");

    var name;
    if (document.all)
        name=objWin.firstChild.lastChild.innerText;
    else
        name=objWin.firstChild.lastChild.textContent;
    if (name.charAt(0)=="*")
        name=name.substring(2,name.length);
    name=name.replace(/ \[.+$/g,"");

    objDialog = document.createElement("iframe");
    objDialog.name="saveReportWin";
    objDialog.ref=objWin;
    objDialog.frameBorder="0";
    objDialog.scrolling="no";
    objDialog.src="saveReport.jsp?id="+objWin.id+"&name="+name+"&params="+url;
    objDialog.style.position="absolute";
    objDialog.style.left=parseInt(objWin.style.width)/2-125;
    objDialog.style.top=parseInt(objWin.style.height)/2-75;
    objDialog.style.width=250;
    objDialog.style.height=150;
    objDialog.style.zIndex="9999";

    var objBody=objWin.getElementsByTagName("iframe")[0];
    objBody.style.opacity="0.5";
    objBody.style.filter="alpha(opacity=50)";

    objWin.appendChild(objDialog);

    parent.title_md.document.getElementById("tools").onclick=function() {return false};
}


var isReload=false;
//------------------- restoreWS -------------------//
function restoreWS()
{
    isReload=true;
    document.location.reload(true);
}


//----------------- restoreLangFont ----------------//
function restoreLangFont()
{
    var selectBox = parent.title_md.document.getElementById("selectBox_MD");
    var param = selectBox.options[selectBox.selectedIndex].value;
    if (document.all)
        objDialog = document.createElement("<iframe name='changeLang'>");
    else
        objDialog = document.createElement("iframe");
    objDialog.src="about:blank";
    objDialog.name="saveWSWin";
    objDialog.style.display="none";

    var objForm = document.createElement('form');
    objForm.action="processActivity"
    objForm.target=objDialog.name;
    objForm.method="post";

    var objActivity=document.createElement('input');
    objActivity.type="hidden";
    objActivity.name="activity"
    objActivity.value="BACK_WS_LANG";
    objForm.appendChild(objActivity);

    document.body.appendChild(objDialog);
    document.body.appendChild(objForm);
    objForm.submit();

    document.body.removeChild(objForm);
}


var changeLang_xmlHttpReq = null;
//------------------- changeLang ------------------//
function changeLang()
{
    var formData = new FormData();
    
    var selectBox = parent.title_md.document.getElementById("selectBox_MD");
    var param = selectBox.options[selectBox.selectedIndex].value;
    
    console.log("winsMng:changeLang(1) - current: " + "<%=langName%>" + ", new: " + param);
    
    if(changeLang_xmlHttpReq == null)
        changeLang_xmlHttpReq = new XMLHttpRequest();
        
    //changeLang_xmlHttpReq.open("POST", "processActivity"); 
    //formData.append("activity", "CHANGE_LANG");
    //formData.append("lang_param", param);
    
    changeLang_xmlHttpReq.onreadystatechange = function()
    {
        if(changeLang_xmlHttpReq.readyState == 4 && changeLang_xmlHttpReq.status == 200)
        {
                console.log("winsMng:changeLang(2) - current: " + "<%=langName%>" + ", new: " + param);
                parent.title_md.reloadTitleMdWin()
                restoreWS();
        }
    }
    changeLang_xmlHttpReq.open("POST", "processActivity"); 
    changeLang_xmlHttpReq.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    changeLang_xmlHttpReq.send("activity=CHANGE_LANG&lang_param=" + encodeURI(param));
    //changeLang_xmlHttpReq.send(formData); 


    <%--
    var selectBox = parent.title_md.document.getElementById("selectBox");
    var param = selectBox.options[selectBox.selectedIndex].value;
    if (document.all)
            objDialog = document.createElement("<iframe name='changeLang'>");
	else
            objDialog = document.createElement("iframe");
    objDialog.src="about:blank";
    objDialog.name="saveWSWin";
    objDialog.style.display="none";

    var objForm = document.createElement('form');
    objForm.action="processActivity"
    objForm.target=objDialog.name;
    objForm.method="post";

    var objActivity=document.createElement('input');
    objActivity.type="hidden";
    objActivity.name="activity"
    objActivity.value="CHANGE_LANG";
    objForm.appendChild(objActivity);

    var objParam=document.createElement('input');
    objParam.type="hidden";
    objParam.name="lang_param"
    objParam.value=param;
    objForm.appendChild(objParam);


    document.body.appendChild(objDialog);
    document.body.appendChild(objForm);
    objForm.submit();

    document.body.removeChild(objForm);
    isWSChanged=false;
    --%>
}


//------------------- closeDialog ------------------//
function closeDialog()
{
    //parent.title_md.document.getElementById("small").className = parent.title_md.document.getElementById("small").className.split(" ")[0];
    //parent.title_md.document.getElementById("meduim").className = parent.title_md.document.getElementById("meduim").className.split(" ")[0];
    //parent.title_md.document.getElementById("big").className = parent.title_md.document.getElementById("big").className.split(" ")[0];
    document.body.removeChild(objDialog);
    objDialog=null;

    var bg=document.getElementById("workspaceLayer");
    bg.style.display="none";
    bg.style.opacity="0";
    bg.style.filter="alpha(opacity=0)";

    parent.title_md.document.getElementById("tools").onclick=null;
}

//------------------- showDialog ------------------//
function showDialog(url,w,h)
{
    console.log( "winsMng_md.jsp:showDialog - url: " + url + ", w: " + w + ", h: " + h );
    objDialog = document.createElement('iframe');
    objDialog.src=url;
    objDialog.frameBorder="0";
    objDialog.style.backgroundColor="white";
    objDialog.scrolling="no";
    objDialog.style.border="1px solid LightSlateGray";
    objDialog.style.borderBottomWidth="2px";
    objDialog.style.position="absolute";
    objDialog.style.width=w;
    objDialog.style.height=h;
    if (document.all)
        objDialog.style.height=h+10;
    objDialog.style.top=document.body.clientHeight/2-parseInt(objDialog.style.height)/2-50;
    objDialog.style.left=document.body.clientWidth/2-parseInt(objDialog.style.width)/2;
    objDialog.allowTransparency = true;
    objDialog.style.zIndex=99999;
    document.body.appendChild(objDialog);

    var bg=document.getElementById("workspaceLayer");
    bg.style.display="inline";
    bg.style.opacity="0.5";
    bg.style.filter="alpha(opacity=50)";

    parent.title_md.document.getElementById("tools").onclick=function() {return false};
}

//------------------- beforeExit ------------------//
function beforeExit()
{
    if (isWSChanged && !isReload)
    {
        <nla:render mask="(Chrome)">
            return "<nla:text message='winMng.ExitSave'/>";
        </nla:render>
        if (confirm("<nla:text message='winMng.ExitSave'/>"))
        {
            saveWS();
                
            for(var retry=0; objDialog && retry<10; retry++) {
                sleep();
            }
        }
        else {
            isWSChanged=false;
        }
    }
}


//---------------------- sleep ---------------------//
function sleep()
{
    if (xmlHttpReq!=null)
    {
        xmlHttpReq.open("POST", "processActivity?sleep=500", false);
        xmlHttpReq.onreadystatechange = function() {
        }
        xmlHttpReq.send(null);
    }
}



//---------------------- MD_OpenLevel --------------//
function MD_OpenLevel(viewLevel, rb_ids, SelectedName)
{
    var isColumnSupported = CSS.supports('columns', '');
    console.log('columns supported: ' + isColumnSupported);
    var isFlexWrapSupported = CSS.supports('flex-wrap', 'wrap');
    console.log('flex-wrap supported: ' + isFlexWrapSupported);
    var isFlexSupported = CSS.supports('display', 'flex');
    console.log("display: flex supported: " + isFlexSupported);

    console.log( "winsMng_md.jsp:MD_OpenLevel - viewLevel: " + viewLevel + ", rb_ids: " + rb_ids );
    var winUrl = "";
    //var strLevel = viewLevel + " View: " + SelectedName;
    var strLevel = "";
    var strImg = "";
    var strRef = "";
    var strTitle = "";
    
    switch (viewLevel)
    {
        case "Company":
            strLevel = '<nla:text message="md.ViewLevel_Company"/>' + " " + SelectedName.replace("<","&lt;").replace(">","&gt;");
            break;
            
        case "Department":
            //winUrl = "/accRealTime/main_md.jsp?md_ViewLevel=Company&md_Selected=" + rb_ids;
            winUrl = "main_md.jsp?md_ViewLevel=Company&md_Selected=" + rb_ids;
            strLevel = '<nla:text message="md.ViewLevel_Department"/>' + " " + SelectedName;
            strImg = '<img src="img/md_rollup.png" border="0" width="30px" align="center">';
            strTitle = 'title=\"Roll Up to Company Level\"';
            strRef = '<a href=' + winUrl + ' ' + strTitle + '>' + strImg + '</a>';
            break;
            
        case "Group":
            //winUrl = "/accRealTime/main_md.jsp?md_ViewLevel=Department&md_Selected=" + rb_ids;
            winUrl = "main_md.jsp?md_ViewLevel=Department&md_Selected=" + rb_ids;
            strLevel = '<nla:text message="md.ViewLevel_Group"/>' + " " + SelectedName;
            strImg = '<img src="img/md_rollup.png" border="0" width="30px" align="center">';
            strTitle = 'title=\"Roll Up to Department Level\"';
            strRef = "<a href=${winUrl} ${strTitle} >" + strImg + "</a>';
            break;
    }
    
    var winData = '<span>' + strRef + strLevel + '</span>';
    console.log( "winsMng_md.jsp:MD_OpenLevel - winData: " + winData );
    
    var objWin = document.getElementById('MD_Level');
    objWin.innerHTML=winData;
    console.log( "winsMng_md.jsp:MD_OpenLevel - objWin: " + objWin );
    //document.body.appendChild(objWin);
}


//---------------------- MD_OpenTop ----------------//
function MD_OpenTop(viewLevel, ids)
{
    console.log( "winsMng_md.jsp:MD_OpenTop - viewLevel: " + viewLevel + ", ids: " + ids );
    var winUrl;
    var winData = '';
    switch (viewLevel)
    {
        case "Company":
            //winUrl = "nlat/MD_SuperGroups.Brief_Report.nlat?fromViewId=mdView&supergroupId=" + ids;
            winUrl = "nlat/MD_SuperGroups.Daily.Brief_Report.nlat?fromViewId=mdView&supergroupId=" + ids;
            break;
        case "Department":
            //winUrl = "nlat/MD_Groups.Status_Brief_Report.nlat?fromViewId=mdView&groupId=" + ids;
            winUrl = "nlat/MD_Groups.Daily.Brief_Report.nlat?fromViewId=mdView&groupId=" + ids;
            break;
            
        case "Group":
            winUrl = "nlat/MD_Groups.Agents_Report.nlat?fromViewId=mdView&groupId=" + ids;
            break;
    }
    //winData = '<div id="title" class="nlaWindowCaption ${dynamicFrontSize}"><span class="closeBtn ${dynamicFrontSize}" onmousedown="removeWin(event,this.parentNode.parentNode);" title="<nla:text message="tools.CloseWin"/>" UNSELECTABLE="ON">x&nbsp;</span><span UNSELECTABLE="ON" style="-moz-user-select: none;"></span></div>';
    winData += '<iframe id="body" src="'+winUrl+'" width="98%" height="100%" frameborder="0" scrolling="no" style="resize:vertical" style="overflow:auto" style="margin-top:-5px" />'; // onload="onWinLoad(this.parentNode, this.contentWindow);"

    console.log( "winsMng_md.jsp:MD_OpenTop - winData: " + winData );
    
    var objWin = document.getElementById('MD_Top');
 
    //objWin.reportName=(typeof name=="undefined")?null:name;
    //objWin.name="win";
    objWin.className="nlaWindow"; //   ${dynamicFrontSize}
    //objWin.style.opacity=0.95;
    //objWin.style.position="absolute";
    //objWin.style.left=50;
    //objWin.style.top=50;
    //objWin.style.width="95%";
    //objWin.style.height=h;
    //objWin.style.zIndex=++maxZind;
    objWin.innerHTML=winData;

    console.log( "winsMng_md.jsp:MD_OpenTop - objWin: " + objWin );
    //document.body.appendChild(objWin);
}


//---------------------- MD_OpenBottom --------------//
function MD_OpenBottom(viewLevel, id)
{
    console.log( "winsMng_md.jsp:MD_OpenBottom - viewLevel: " + viewLevel + ", id: " + id );
    var winUrls = [];
    switch (viewLevel)
    {
        case "Company":
            winUrls.push("nlat/MD_SuperGroups.Agents_Loggedin.nlat?supergroupId=64");           //row1-1
            winUrls.push("nlat/MD_SuperGroups.Agents_ACD.nlat?supergroupId=64");                //row1-2
            winUrls.push("nlat/MD_SuperGroups.Agents_Release.nlat?supergroupId=64");            //row1-3
            winUrls.push("nlat/MD_SuperGroups.Incoming_Calls_in_Queue.nlat?supergroupId=64");   //row1-4
            winUrls.push("nlat/MD_SuperGroups.Longest_Call_in_Queue.nlat?supergroupId=64");     //row1-5
            winUrls.push("nlat/MD_SuperGroups.Daily.Accepted_Calls.nlat?supergroupId=64");      //row2-1
            winUrls.push("nlat/MD_SuperGroups.Daily.Answered_Calls.nlat?supergroupId=64");      //row2-2
            winUrls.push("nlat/MD_SuperGroups.Daily.Abandoned_Calls.nlat?supergroupId=64");     //row2-3
            winUrls.push("nlat/MD_SuperGroups.Daily.Answered_Calls_Percent.nlat?supergroupId=64");//row2-4
            //winUrls.push("nlat/MD_SuperGroups.Above_TASA.nlat?supergroupId=64");                //row2-4
            //winUrls.push("nlat/MD_SuperGroups.Outbound_Pending_Calls.nlat?supergroupId=64");    //row2-5
            break;
        case "Department":
            winUrls.push("nlat/MD_SuperGroups.Agents_Loggedin.nlat?supergroupId="+id);          //row1-1
            winUrls.push("nlat/MD_SuperGroups.Agents_ACD.nlat?supergroupId="+id);               //row1-2
            winUrls.push("nlat/MD_SuperGroups.Agents_Release.nlat?supergroupId="+id);           //row1-3
            winUrls.push("nlat/MD_SuperGroups.Incoming_Calls_in_Queue.nlat?supergroupId="+id);  //row1-4
            winUrls.push("nlat/MD_SuperGroups.Longest_Call_in_Queue.nlat?supergroupId="+id);    //row1-5
            winUrls.push("nlat/MD_SuperGroups.Daily.Accepted_Calls.nlat?supergroupId="+id);     //row2-1
            winUrls.push("nlat/MD_SuperGroups.Daily.Answered_Calls.nlat?supergroupId="+id);     //row2-2
            winUrls.push("nlat/MD_SuperGroups.Daily.Abandoned_Calls.nlat?supergroupId="+id);    //row2-3
            winUrls.push("nlat/MD_SuperGroups.Daily.Answered_Calls_Percent.nlat?supergroupId="+id);//row2-4
            //winUrls.push("nlat/MD_SuperGroups.Above_TASA.nlat?supergroupId="+id);               //row2-4
            //winUrls.push("nlat/MD_SuperGroups.Outbound_Pending_Calls.nlat?supergroupId="+id);   //row2-5
       
            break;
            
        case "Group":
            winUrls.push("nlat/MD_Groups.Agents_LoggedIn.nlat?groupId=" + id);                  //row1-1
            winUrls.push("nlat/MD_Groups.Agents_ACD.nlat?groupId=" + id);                       //row1-2
            winUrls.push("nlat/MD_Groups.Agents_Release.nlat?groupId=" + id);                   //row1-3
            winUrls.push("nlat/MD_Groups.Incoming_Calls_in_Queue.nlat?groupId="+id);            //row1-4
            winUrls.push("nlat/MD_Groups.Longest_Call_in_Queue.nlat?groupId="+id);              //row1-5
            winUrls.push("nlat/MD_Groups.Daily.Accepted_Calls.nlat?groupId=" + id);             //row2-1
            winUrls.push("nlat/MD_Groups.Daily.Answered_Calls.nlat?groupId=" + id);             //row2-2
            winUrls.push("nlat/MD_Groups.Daily.Abandoned_Calls.nlat?groupId=" + id);            //row2-3
            winUrls.push("nlat/MD_Groups.Daily.Answered_Calls_Percent.nlat?groupId=" + id);     //row2-4
            winUrls.push("nlat/MD_Groups.Average_Q_Time.nlat?groupId="+id);                     //row2-5
            //winUrls.push("nlat/MD_Groups.Above_TASA.nlat?groupId="+id);                         //row2-5
        
            break;
    }
    
    var winData = '';
    var objWin = document.getElementById('MD_Bottom');
    var i;
    for (i = 0; i < winUrls.length; i++) 
    {
        var winUrl = winUrls[i];
        //winData='<div id="title" class="nlaWindowCaption ${dynamicFrontSize}"><span class="closeBtn ${dynamicFrontSize}" onmousedown="removeWin(event,this.parentNode.parentNode);" title="<nla:text message="tools.CloseWin"/>" UNSELECTABLE="ON">x&nbsp;</span><span UNSELECTABLE="ON" style="-moz-user-select: none;"></span></div>';
        //winData += '<div id="title" class="nlaWindowCaption ${dynamicFrontSize}"></div>';
        if( winUrl.includes("Longest_Call_in_Queue") || winUrl.includes("Average_Q_Time") )
        {
            winData += '<iframe id="body" src="'+winUrl+'"  frameborder="0" scrolling="no" style="flex-grow: 2" style="position: relative" style="margin-top:-5px;" ></iframe>'; // onload="onWinLoad(this.parentNode, this.contentWindow);"
        }
        else
        {
            winData += '<iframe id="body" src="'+winUrl+'"  frameborder="0" scrolling="no" style="position: relative" style="margin-top:-5px;" ></iframe>'; // onload="onWinLoad(this.parentNode, this.contentWindow);"
        }
        //winData+='<iframe id="body" src="'+winUrl+'" width="100%" height="100%" frameborder="0" scrolling="no" style="margin-top:-5px;" onload="onWinLoad(this.parentNode, this.contentWindow);"/>';
    }
    
    console.log( "winsMng.jsp:MD_OpenBottom - winData: " + winData );
    
    //objWin.reportName=(typeof name=="undefined")?null:name;
    //objWin.name="win";
    objWin.className="nlaWindow"; //   ${dynamicFrontSize}
    //objWin.style.opacity=0.95;
    //objWin.style.position="absolute";
    //objWin.style.left=50;
    //objWin.style.top=50;
    //objWin.style.width="95%";
    //objWin.style.height=h;
    //objWin.style.zIndex=++maxZind;
    objWin.innerHTML=winData;
    console.log( "winsMng.jsp:addWin - objWin: " + objWin );
    //document.body.appendChild(objWin);

}

