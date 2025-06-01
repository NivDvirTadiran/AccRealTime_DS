<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<%@page pageEncoding="UTF-8" import="tadiran.webnla.NLAContext, tadiran.webnla.bean.AbsDataClass, tadiran.webnla.bean.DataItem, java.util.HashMap" %>

<html>
<head>
    <link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>
    <link href="css/nlaTemplate.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript">
        function getSelected() {
            var result="";
            var fields=document.getElementsByTagName("input");
            for (var i=0; i<fields.length; i++)
                if (fields[i].checked)
                    result+=","+fields[i].name;
            
            return result.substr(1, result.length-1);
        }

        function setSelected(event) {
            event = event || window.event;
            if (event!=null && event.shiftKey==1) {
                var obj=event.srcElement || event.target;
                var refs=document.getElementsByTagName("input");

                for (i=0; i<refs.length; i++) {
                    if (refs[i].getAttribute("type")=="checkbox")
                        if (obj.checked)
                            refs[i].checked=true;
                        else
                            refs[i].checked=false;
                }
            }
        }
    </script>
</head>
<body style="font-size:12px; padding-top:7px;">
    <div class="closeBtn closeBtnPos" onmousedown="parent.hideFields();" title="<nla:text message="tools.Close"/>" UNSELECTABLE="ON">x</div>
    <c:set var="objKeys" value='<%=((String)request.getParameter("fields")).split("[ ]*,[ ]*")%>'/>
    <%
        String langName=(String)session.getAttribute("Accept-Language");
        HashMap map=(HashMap)NLAContext.getInstance().getObjectMap(request.getParameter("ref"));
        HashMap fields=((AbsDataClass)map.values().iterator().next()).getData();

        String selectedKeys=request.getParameter("selected");
        String field;
        String checked;
        String item;
    %>
    <c:forEach var="field" items="${objKeys}">
        <%
            checked="";
            field=(String)pageContext.findAttribute("field");
            if (selectedKeys!=null)
                if (selectedKeys.indexOf(field)!=-1)
                    checked="checked";
            item = "";
            if(((DataItem)fields.get(field)) != null)
                item = ((DataItem)fields.get(field)).getName(langName);
            else item = field;
        %>
        <input type="checkbox" name="${field}" <%=checked%> onclick="setSelected(event);"> <%=item%><br>
    </c:forEach>
</body>
</html>
