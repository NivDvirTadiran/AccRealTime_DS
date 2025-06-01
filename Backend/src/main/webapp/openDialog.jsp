<%@page pageEncoding="UTF-8" import="tadiran.webnla.bean.SessionData, tadiran.emisweb.ReportListDataItemType"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<%
    String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
     //String =(String)session.getAttribute("dynamicFrontSize");  
    if (request.getParameter("refresh") != null) {
        response.sendRedirect("nlatRescan");
    }

    SessionData sessionData=(SessionData)session.getAttribute("sessionData");
    if(sessionData == null){
        response.sendRedirect("login.jsp");
    }
    else
        sessionData.refresh();
    
   
%>

<html>
<head>
    <nla:render mask="(BlackBerry|IEMobile)">
        <link href="css/nlaApp_Mobile.css" type="text/css" rel="stylesheet"/>
    </nla:render>
    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
        <link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>
        <script type= "text/javascript">
            var prevObj=null;
            var prevObjTab;
            function tabGroup(obj) {
                if (obj==prevObj) return;

                if (prevObj!=null) {
                    prevObj.className="tabName";
                    prevObj.firstChild.innerHTML=">";
                    prevObjTab.style.display="none";
                }

                var tab=obj.nextSibling;
                if (!tab.tagName)
                    tab=tab.nextSibling;					

                if (tab.style.display=="none") {
                    obj.className="tabNameSelected";
                    obj.firstChild.innerHTML="^";
                    tab.style.display="inline";

                    <c:if test='${empty param["type"] || param["type"]=="reports"}'>
                        if (parent.openRepCategories.indexOf(obj.id)==-1)
                            parent.openRepCategories+=obj.id+";";
                    </c:if>
                        
                    <c:if test='${param["type"]=="templates"}'>
                        parent.closeTemplateGroups=parent.closeTemplateGroups.replace(obj.id+";","");
                    </c:if>
                }
                else {
                    obj.className="tabName";
                    obj.firstChild.innerHTML=">";
                    tab.style.display="none";

                    <c:if test='${empty param["type"] || param["type"]=="reports"}'>
                        parent.openRepCategories=parent.openRepCategories.replace(obj.id+";","");
                    </c:if>
                        
                    <c:if test='${param["type"]=="templates"}'>
                        if (parent.closeTemplateGroups.indexOf(obj.id)==-1)
                            parent.closeTemplateGroups+=obj.id+";";
                    </c:if>
                }
                //prevObj=obj;
                prevObjTab=tab;
            }

            function openNlat(url, id, name) {
                parent.addWin('nlat/'+url,id,name);
            }

            function changeType(type) {
                document.location=document.location.pathname+"?type="+type;
            }

            function overRep(ref) {
                ref.style.fontWeight="bold";
                ref.style.color="maroon";
            }

            function outRep(ref) {
                ref.style.fontWeight="";
                if (ref.style.fontStyle=='') //is public
                    ref.style.color="";
                else
                    ref.style.color="";
            }

            function fwdRep(type, id) {
                var ref=document.getElementById("rep_"+id);
                var ref2=document.getElementById("del_"+id);
                if (type=="over") {
                    overRep(ref);
                    ref2.style.color="maroon";
                    ref2.style.fontSize="11px";
                    ref2.style.fontWeight="bold";
                }
                else {
                    outRep(ref);
                    ref2.style.color="";
                    ref2.style.fontSize="";
                    ref2.style.fontWeight="";
                }
            }

            var reportId=null;
            function removeReport(id, name) {
                if (!confirm("<nla:text message='open.DeleteConf'/> '"+name+"' report?"))
                    return;

                reportId=id;
                srv.src="processActivity?activity=delete_report&reportId="+reportId;
                srv.location=srv.src;
                
                //4-Mar-2020 Debby BZ#28550
                var reports = parent.document.getElementsByClassName("nlaWindow drag "); 
                for(var i=0; i<reports.length; i++)
                {
                    if(reports[i].id == id){
                        reports[i].style.display="none"; //close the report
                    }
                }
            }

            function closeActivityWin(errorMessage) {
                if (errorMessage!=null)
                    alert(errorMessage);
                else {
                    document.getElementById("rep_"+reportId).style.display="none";
                    document.getElementById("del_"+reportId).style.display="none";
                }
            }
        </script>
    </nla:render>
</head>

<body class="toolsBody ${dynamicFrontSize}">
    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
        <iframe id="srv" style="display:none;"></iframe>
        <div style="background-color:LightSlateGray; padding-top:4px;">
            <span class="closeBtn2 ${dynamicFrontSize}" onmousedown="parent.closeDialog();" title="<nla:text message='tools.CloseWin'/>">x&nbsp;</span>
            <span style="position:relative; bottom:1px; margin-left:15px; font-weight:bold;color:white;"><nla:text message='open.Title'/>:</span>
            <span class='navTab ${(empty param["type"] || param["type"]=="reports")?"navActiveTab ":""} ${dynamicFrontSize}' style="margin-left:3px;" onclick="changeType('reports');"><nla:text message='open.Report'/></span><span class='navTab ${(param["type"]=="templates")?"navActiveTab ":""} ${dynamicFrontSize}' onclick="changeType('templates');"><nla:text message='open.Template'/></span>
        </div>
        <div style="height:85%; overflow-y:auto;overflow-x:hidden; margin:10px; margin-top:15px;">
            </nla:render>
            <nla:render mask="(BlackBerry|IEMobile)">
                <div style="background-color:LightSlateGray;">
                    <span style="font-weight:bold; color:white;">&nbsp;<nla:text message='open.Title'/>&nbsp;<nla:text message='open.Report'/>:</span>
                </div>
            </nla:render>
            <c:if test='${param["type"]=="templates"}'>
                <c:forEach var="group" items="${nlaTemplates}">
                    <c:if test='${initParam.PBXType!=15 || (group.key!="IVRPorts" && !group.key.startsWith("MD_"))}'>
                        <nla:render mask="(BlackBerry|IEMobile)">
                            <div class="tabNameSelected">${group.key}</div>
                        </nla:render>
                        <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
                            <div id="grp_${group.key}" class="tabNameSelected" onclick="tabGroup(this)" UNSELECTABLE="ON" style="-moz-user-select: none;"><span style="color:chocolate; font-size:11px;">^</span>&nbsp <nla:text message='${group.key}'/></div>
                        </nla:render>
                        <span class="tabGroup">
                            <c:forEach var="item" items="${group.value}">
                                <c:set var="isDefault" value='<%=((String[]) pageContext.getAttribute("item"))[1].indexOf("/")==-1%>' scope="request"/>
                                <nla:render mask="(BlackBerry|IEMobile)">
                                    <a href="nlat/${item[1]}" class="tabTemplate"><%=((String[]) pageContext.getAttribute("item"))[0].replace('_', ' ')%></a><br/>
                                </nla:render>
                                <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
                                    <div class="tabItem ${isDefault?'tabTemplate ':'custTemplate'}" onclick="openNlat('${item[1]}','${nlatRendersRev[item[1]]}'); parent.closeDialog();"><nla:text message='${item[0]}'/></div>
                                </nla:render>
                            </c:forEach>
                            <div style="font-size:2px; border-top:1px solid PaleGoldenRod;">&nbsp;</div>
                        </span>
                    </c:if>
                </c:forEach>
            </c:if>
            <c:if test='${empty param["type"] || param["type"]=="reports"}'>
                <c:forEach var="item" items="${sessionData.reportsByType}">
                    <nla:render mask="(BlackBerry|IEMobile)">
                        <div class="tabNameSelected"><nla:text message='${item.key}'/></div>
                    </nla:render>
                    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
                        <div id="tag_${item.key}" class="tabName" onclick="tabGroup(this)" UNSELECTABLE="ON" style="-moz-user-select: none;"><span style="color:chocolate; font-size:11px;">></span>&nbsp <nla:text message='${item.key}'/></div>
                    </nla:render>
                    <span class="tabGroup" <nla:render mask="(Firefox|MSIE|Chrome|Safari)">style='display:none;'</nla:render>>
                        <c:forEach var="report" items="${item.value}">
                            <%
                                ReportListDataItemType report=(ReportListDataItemType)pageContext.getAttribute("report");
                                String template=report.getParams();
                                String templateParams=template.replaceAll(".*\\?", "");
                                template=template.replaceAll("\\.nlat(.)*$", "");
                                template=template.substring(template.indexOf(".")+1);
                            %>
                            <nla:render mask="(BlackBerry|IEMobile)">
                                <a href="nlat/${report.params}" ${(report.isPublic==1)?"style='font-style:italic;'":""} class="tabItem tabReport<%=template.endsWith("Graph")?"2":""%>">${report.reportName}</a><br/>
                            </nla:render>
                            <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
                                <span id ="del_${report.reportId}" class="closeBtn3 ${dynamicFrontSize}" title="delete" onclick="removeReport(${report.reportId},'${report.reportName}')" onmouseover="fwdRep('over',${report.reportId})" onmouseout="fwdRep('out',${report.reportId})">x</span>
                                <div id="rep_${report.reportId}" ${(report.isPublic==1)?"":"style='font-style:italic;'"} class="tabItem tabReport<%=template.endsWith("Graph")?"2":""%>" onclick="openNlat('${report.params}',${report.reportId},'${report.reportName}')" title="${(report.isPublic==1)?"Public: ":""}<nla:text message='<%=template%>'/>" onmouseover="overRep(this);" onmouseout="outRep(this);">${report.reportName}${(report.isPublic==1)?'<font style="font-size:8px; color:#A9A9A9; position:fixed; margin-left:3px; margin-top:-2px;">(p)</font>':''}</div>
                            </nla:render>
                        </c:forEach>
                        <div style="font-size:2px; border-top:1px solid PaleGoldenRod;">&nbsp;</div>
                    </span>
                </c:forEach>
            </c:if>
        </div>
</body>

<script type= "text/javascript">
    
    var openTags=parent.openRepCategories.split(";");
    for(var i=0; i<openTags.length-1; i++)
        tabGroup(document.getElementById(openTags[i]));

    var closeTags=parent.closeTemplateGroups.split(";");
    for(var i=0; i<closeTags.length-1; i++)
        tabGroup(document.getElementById(closeTags[i]));
    
</script>
</html>
