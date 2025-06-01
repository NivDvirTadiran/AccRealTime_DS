<%@page import="java.util.Properties, java.util.Hashtable" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collection"%>
<%@page import="tadiran.emisweb.GroupListDataItemType"%>
<%@page import="tadiran.emisweb.GenListDataItemType"%>
<%@page import="tadiran.webnla.bean.SessionData"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<%
	String md_ViewLevel=request.getParameter("md_ViewLevel");
        String md_Selected=request.getParameter("md_Selected");
        String md_SelectedRb=(String)session.getAttribute("md_SelectedRb");
        SessionData sessionData=(SessionData)session.getAttribute("sessionData");
        String ids = "";
        session.setAttribute("md_ViewLevel",md_ViewLevel);
        //pageContext.setAttribute("md_ViewLevel",md_ViewLevel);
        if(md_ViewLevel.equals("Company"))
        {
            ids = sessionData.getMdIDs(md_ViewLevel, md_Selected);
            session.setAttribute("md_SelectedRb","");
        }
        else if(md_ViewLevel.equals("Department"))
        {
            session.setAttribute("md_SelectedRb",md_Selected);
            if(md_SelectedRb.isEmpty())
                ids = sessionData.getMdIDs(md_ViewLevel, md_Selected);
            else
                ids = sessionData.getMdIDs(md_ViewLevel, md_SelectedRb);
        }
        else if(md_ViewLevel.equals("Group"))
        {
            ids = sessionData.getMdIDs(md_ViewLevel, md_Selected);
        }
        md_SelectedRb=(String)session.getAttribute("md_SelectedRb");
        String rb_ids = sessionData.getMdRbIDs(md_ViewLevel, md_SelectedRb);
        String md_SelectedName = sessionData.getMdSelectedName(md_ViewLevel, md_Selected).replace("\"", "\\\"");
        System.out.println("main_md.jsp - md_ViewLevel: " + md_ViewLevel + ", md_Selected: " + md_Selected + ", Id List: " + ids + ", md_SelectedRb: " + md_SelectedRb + ", rb_ids: " + rb_ids);
%>

<html>
<head>
    <style>
        div {
            border: thin solid bisque;
            width: 100%;
            mergin: 5px;
        }
    </style>
    <link rel="icon" href="favicon.ico">
    <link rel="preconnect" href="https://fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@1,700&display=swap" rel="stylesheet">
    <script src="js/winsMng.jsp" type= "text/javascript"></script>
    <script src="js/winsMng_md.jsp" type= "text/javascript"></script>
    <script src="js/tableMng.js" type= "text/javascript"></script>
    <script type= "text/javascript">
        window.oncontextmenu = function(event) {
            event.preventDefault();
            event.stopPropagation();
            return false;
        };
        
        function init()
        {
            var md_ViewLevel = "<%=md_ViewLevel%>";
            var md_Selected = "<%=md_Selected%>";
            var md_SelectedName = "<%=md_SelectedName%>";
            //var md_SelectedRb = "<%=md_SelectedRb%>";
            var ids = "<%=ids%>";
            var rb_ids = "<%=rb_ids%>";
            //System.out.println("main_md.jsp - init()  md_ViewLevel:" + md_ViewLevel + " ids" + ids);
            //MD_OpenLevel(md_ViewLevel, rb_ids);
            MD_OpenLevel(md_ViewLevel, rb_ids, md_SelectedName);
            MD_OpenTop(md_ViewLevel, ids);
            MD_OpenBottom(md_ViewLevel, md_Selected);
        }
        
    </script>
    <link href="css/nlaApp_md.css" type="text/css" rel="stylesheet"/>
</head>

<%-- AviM 14/01/2019 Changes for Aeonix Contact Center workspace display --%>

<body onload="init()" scroll="no" style="background: silver url(img/aeonix_logo_150_20.png) fixed center no-repeat">
    <div id="workspaceLayer" class="workspaceLayer"></div>
    <div id="MD_Main" class="MD_Main" >
        <div id="MD_Level" class="MD_Level">
        </div>
        <div id="MD_Top" class="MD_Top">
        </div>
        <div id="MD_Bottom" class="MD_Bottom">
        </div>
    </div>
</body>
</html>
