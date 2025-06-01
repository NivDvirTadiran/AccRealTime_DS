//---------------------------------------------------- select id functions
function onSelectOut(ref)
{
    if (ref.style.fontWeight!="bolder")
    {
        ref.style.color="";
        ref.style.fontSize="";
        ref.style.fontWeight="";
    }
}
function onSelectOver(ref, fontSize)
{
    if (ref.style.fontWeight!="bolder")
    {
        var size =14;
        if(fontSize != null)
        {
            if(fontSize == "bigSize")
                size = size*1.3;
            else if(fontSize == "meduimSize")
                size = size*1.15;
        }
            ref.style.color="Maroon";
            ref.style.fontSize=size+"px";
            ref.style.fontWeight="bold";
    }
}

function onAllObjectsSelect(event)
{
    //console.log("onAllObjectsSelect - event: " + event );
    event = event || window.event;
    console.log("onAllObjectsSelect - event: " + event + ", document.location: " + document.location );
    onObjectSelect(event.srcElement || event.target, 'selectAll');
}


var ids=new Array(0);
function onObjectSelect(ref, event)
{
    var obj=null;
    var refs=null;
    console.log("onObjectSelect - ref: " + ref + ", event: " + event );
    event = event || window.event;
    if (event=='selectAll' || (event!=null && event.shiftKey==1))
        refs=document.getElementsByTagName("input");
    else
        refs=new Array(ref);

    if (ref.checked)
    {
        for (i=0; i<refs.length; i++)
        {
            ref=refs[i];
            if (ref.id!=null && ref.id!='' && ref.getAttribute("type")=="checkbox")
                if (ids.length<maxAgentsInBriefReport)
                {
                    ref.checked=true;
                    obj=ref.parentNode.parentNode;

                    obj.style.fontWeight="bolder";
                    obj.style.color="Maroon";
                    for (var j=0; j<ids.length; j++)
                    {
                        if (ids[j]==obj.id)
                            break;
                    }

                    if (j==ids.length)
                        ids.push(obj.id);
                }
                else
                {
                    ref.checked=false;
                    confirm("This report is limited to " + maxAgentsInBriefReport + (isGraph ? " groups." : " agents."));
                    break;
                }
        }
        refs=document.getElementsByTagName("input");
        if (refs.length-1==ids.length || ids.length>=maxAgentsInBriefReport)
            refs[0].checked=true;
    }
    else
    {            
        for (i=0; i<refs.length; i++)
        {
            ref=refs[i];
            if (ref.id!=null && ref.id!='' && ref.getAttribute("type")=="checkbox")
            {
                ref.checked=false;
                obj=ref.parentNode.parentNode;

                obj.style.fontWeight="";
                obj.style.color="";
            }
        }

        if (refs.length==1)
        {
            for (i=0; i < ids.length; i++)
                if (ids[i]==obj.id) {
                    ids[i]=null;
                    break;
                }
            ids.sort();
            ids.pop();
        }
        else
            ids=new Array();
    }
}

function onObjectSelectDone(ref, objName)
{
    var idsList=ids.sort().join();
    console.log("onObjectSelectDone - ref: " + ref + ", objName: " + objName + ", idsList: " + idsList );
    if (ref!=null)
    {
        var obj_id=ref.parentNode.id;
        if (idsList=="")
            idsList=obj_id;
        else
        {
            if (idsList.indexOf(obj_id)==-1)
                idsList+=","+obj_id;
        }
    }
    else 
        if (idsList=="")
            return;
	
    var params="";
    var url=document.location.href;
    console.log("onObjectSelectDone - url after document.location.href: " + url );
    url=url.replace(new RegExp("(&|\\?)(obj|"+objName+")Id=(.)*$"),"");
    console.log("onObjectSelectDone - url after replace: " + url );
    var ind=url.indexOf("?");
    if (ind!=-1)
        params=url.substr(ind+1, url.length)+"&";

    document.location="?"+params+objName+"Id="+idsList;
    console.log("onObjectSelectDone - url: " + url)
    console.log("onObjectSelectDone - document.location: " + document.location + "?"+ params + objName + "Id=" + idsList)
}


//---------------------------------------------------- select optional fields functions
var fieldsWin=null;
var activityWin=null;
var activityImg=null;
var activeRowId=null;
var activeRowTimer=null;
var activeTable;
function hideFields()
{
    if (fieldsWin)
    {
        var selectedKeys=fieldsWin.contentWindow.getSelected();
        //if (selectedKeys!="")
        selectedKeys="fields="+selectedKeys;

        var url=document.location.href.replace(/fields=[^&]*(&|$)/,"").replace(/(&|\?)$/,"");
        url+=((url.indexOf("?")>=0)?"&":"?")+selectedKeys;
        document.location.href=url;

        document.body.removeChild(fieldsWin);
        fieldsWin=null;
    }
    return false;
}

function selectFields(event, ref, allFields, selectedFields)
{
    if (fieldsWin==null)
    {
        event = event || window.event;
        var obj=(event.srcElement || event.target);
        obj.style.backgroundColor="gold";

        winRef.isSaved=false;
        var objWin = document.createElement("iframe");
        objWin.className="winMenu";
        objWin.frameBorder=0;
        objWin.src="../selectFields.jsp?ref="+ref+"&fields="+allFields+"&selected="+selectedFields;
        objWin.style.width="230px";
        objWin.style.height="200px";
        objWin.style.position="absolute";
        objWin.style.top="1px";
        objWin.style.left=event.clientX-220;

        document.body.appendChild(objWin);
        fieldsWin=objWin;

        event.cancelBubble = true;
        if (event.stopPropagation)
            event.stopPropagation();
    }
    else {
        hideFields();
    }

    return false;
}

//---------------------------------------------------- activity menu functions
function checkActiveRow()
{
    if (activityWin!=null && activeRowId!=null)
        if (document.getElementById(activeRowId)==null) {
            closeActivityWin();
        }
}

function closeActivityWin(errorMessage)
{
    if (activityWin!=null)
    {
        clearInterval(activeRowTimer);
        activeTable.style.opacity="";
        activeTable.style.filter="";
        if (document.getElementById(activeRowId)!=null)
                document.getElementById(activeRowId).style.backgroundColor="";
        document.body.removeChild(activityWin);
        document.body.removeChild(activityImg);
        document.oncontextmenu=null;
        activityWin=null;
        activeRowTimer=null;
        activeRowId=null;

        if (errorMessage!=null)
            alert(errorMessage);
    }
}

function openActivityWin(event, ref, id)
{
    event = event || window.event;
    if (event.which==3 || event.button==2)
    {
        closeActivityWin();
        var obj=(event.srcElement || event.target);
        activeRowId=obj.parentNode.id;
        activeRowTimer=setInterval("checkActiveRow()",1000 * 30);
        obj.parentNode.style.backgroundColor="gold";

        event.cancelBubble = true;
        if (event.stopPropagation)
            event.stopPropagation();

        activeTable=obj.parentNode.parentNode.parentNode;
        activeTable.style.opacity="0.5";
        activeTable.style.filter="alpha(opacity=50)";

        document.oncontextmenu=function() {return false;};

        var objWin = document.createElement("iframe");
        objWin.className="winMenu";
        objWin.frameBorder=0;
        objWin.style.zIndex=1;
        objWin.src="../activityMenu.jsp?ref="+ref+"&id="+id;
        objWin.style.width="140px";
        objWin.style.height="50px";
        objWin.style.position="absolute";
        objWin.style.top=event.clientY-35;
        objWin.style.left=event.clientX;

        activityImg = document.createElement("img");
        activityImg.src="../img/sel.png";
        activityImg.style.zIndex=2;
        activityImg.style.position="absolute";
        activityImg.style.top=event.clientY-5;
        activityImg.style.left=event.clientX-15;
        activityWin=objWin;
        document.body.appendChild(activityWin);
        document.body.appendChild(activityImg);
        return false;
    }

    closeActivityWin();
    return false;
}

//---------------------------------------------------- sort by functions
function sortBy(field, reverseOrder)
{
    if (fieldsWin)
        return hideFields();

    reverseOrder = !reverseOrder;
    winRef.isSaved=false;
    var url=document.location.href.replace(/sortBy=[^&]*(&|$)/,"").replace(/reverseOrder=[^&]*(&|$)/,"").replace(/(&|\?)$/,"");
    url+=((url.indexOf("?")>=0)?"&":"?")+"sortBy="+field+(reverseOrder?"&reverseOrder=true":"");
    document.location.href=url;
}
