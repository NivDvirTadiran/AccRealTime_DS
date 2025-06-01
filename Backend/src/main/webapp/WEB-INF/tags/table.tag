<%------------------------------------------------------------
TABLE - provide data in table view
params: keys - (mandatory param) fields (cols) to display
		ref - ref object name, if not defined then required <nla:obj ref="..."> tag before table tag
		optionalKeys - optional fields to display
usage:
1.
<nla:obj ref="Groups">
	<nla:table keys="6_3_2_1_1, 6_3_2_1_2" optionalKeys="6_3_1_1_2,6_3_2_2_8"/>
</nla:obj>

2.
<nla:table ref="Agents" keys="6_3_2_1_1, 6_3_2_1_2" optionalKeys="6_3_1_1_2,6_3_2_2_8"/>
-----------------------------------------------------------------%>

<%@attribute name="ref"%>
<%@attribute name="keys" required="true" %>
<%@attribute name="optionalInKeys" %>
<%@attribute name="optionalOutKeys" %>

<%@tag pageEncoding="UTF-8" import="tadiran.webnla.NLAContext, tadiran.webnla.bean.AbsDataComparator, java.util.Collection, java.util.ArrayList, java.util.Arrays, java.util.Vector, java.util.Collections, java.util.Comparator, java.util.LinkedHashSet, tadiran.webnla.bean.AbsDataClass, tadiran.webnla.bean.DataItem, tadiran.webnla.bean.SessionData" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<nla:define name="tableName"/>
<%
    String langName=(String)session.getAttribute("Accept-Language");
    String uniqueNlatName = request.getServletPath().replaceAll("^(.)*/", "") + request.getQueryString();
    //String showLoggedInOnlyState = (String)session.getAttribute("ShowLoggedInOnly");
    String showLoggedInOnlyState = (String)session.getAttribute("ShowLoggedInOnly:" + uniqueNlatName);
    //10-Aug-2022 YR BZ#56641
    String accServerTime=(String)session.getAttribute("accServerTime");
    if(showLoggedInOnlyState == null)
        showLoggedInOnlyState = "false";
    
    // normalize filed names
    String selectedKeys=request.getParameter("fields");
    if (selectedKeys!=null) {
        selectedKeys=selectedKeys.replaceFirst("^f","");
        selectedKeys=selectedKeys.replaceAll(",f",",");
        selectedKeys+=",.";
    }

    LinkedHashSet visibleKeys=new LinkedHashSet(); //visible fields
    
    ArrayList<String> lKeys=new ArrayList(Arrays.asList(((String)jspContext.getAttribute("keys")).split("[ ]*,[ ]*")));
    String optInKeys=(String)jspContext.getAttribute("optionalInKeys");
    String optOutKeys=(String)jspContext.getAttribute("optionalOutKeys");
    if (optInKeys==null) {
        optInKeys="";
    }
    if (optOutKeys==null) {
        optOutKeys="";
    }
    ArrayList<String> lOptInKeys=new ArrayList(Arrays.asList((optInKeys).split("[ ]*,[ ]*")));
    ArrayList<String> lOptOutKeys=new ArrayList(Arrays.asList((optOutKeys).split("[ ]*,[ ]*")));
    //lOptInKeys.retainAll(lKeys);
    lKeys.removeAll(lOptInKeys);
    lKeys.removeAll(lOptOutKeys);
   
    ArrayList<String> lSelKeys=new ArrayList();
    if (selectedKeys!=null) {
        lSelKeys.addAll(Arrays.asList(selectedKeys.split("[ ]*,[ ]*")));
    }
    else {
        lSelKeys.addAll(lOptInKeys);
        //lSelKeys.addAll(lOptOutKeys);
    }
    selectedKeys=lSelKeys.toString().replaceAll(",\\s", ",");
    selectedKeys=selectedKeys.substring(1,selectedKeys.length()-1);
    
    lKeys.addAll(lSelKeys);
    //lKeys.addAll(lOptOutKeys);
%>
<c:set var="nlatName" value='<%=request.getServletPath().replaceAll("^(.)*/", "")%>'/>
<c:set var="uniqueNlatName" value='<%=uniqueNlatName%>'/>
<c:set var="showKeys" value='<%=lKeys%>'/>
<c:set var="showLoggedOnly" value='<%=showLoggedInOnlyState%>'/>
<%
    String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
    // get data ref object
    String objName=(String)jspContext.findAttribute("refObjectName");
    String ref=(String)jspContext.getAttribute("ref");
    //System.out.println(objName+"===="+ref);
    if (objName!=null)
        if (ref!=null)
            ref=ref.replaceFirst(ref.substring(0,ref.indexOf(".")), objName);
        else
            ref=objName;
    jspContext.setAttribute("objRef", ref);

    // sort results collection if required
    Collection objCollection=NLAContext.getInstance().getObjectMap(ref).values();
	
    String sortKey=request.getParameter("sortBy");
    boolean isReverseOrder=request.getParameter("reverseOrder") != null;
    
    if (sortKey!=null) {
        Comparator dataComparator = isReverseOrder ? 
            new AbsDataComparator(sortKey) : 
                Collections.reverseOrder(new AbsDataComparator(sortKey));
        Vector sortedObjCollection=new Vector(objCollection);
        Collections.sort(sortedObjCollection, dataComparator);
        jspContext.setAttribute("objRefData", sortedObjCollection);
    }
    else
        jspContext.setAttribute("objRefData", objCollection);
%>

<c:if test='${nlatRendersRev[nlatName]=="AgentsBriefStatus"}'>
    <div width="10">
        <label for="showLoggedin_CB">
            <input type="checkbox" id="showLoggedin_CB" name="showLoggedin_CB" value="false" onchange="onShowLoggedInOnlySelect(this.checked, '${uniqueNlatName}');">
             Show Logged In Only
        </label>
        <c:if test='${showLoggedOnly=="true"}'>
            <script type="text/javascript">
                var obj=document.getElementById("showLoggedin_CB");
                if (!obj.checked) {
                    obj.checked=true;
                }
            </script>
        </c:if>
    </div>
</c:if>

<c:if test='${!header["RefreshMode"]}'>
    <div style="width:100%;<nla:render mask="(Firefox|Chrome|Safari)">height:93%;</nla:render>overflow-y:auto;overflow-x:auto;">
</c:if>
<%
    //10-Aug-2022 YR BZ#56641
    //System.out.println("accServerTime: " + accServerTime); 
    response.setHeader("accServerTime", accServerTime);
%>


<table id="${tableName}" class="dataTable ${dynamicFrontSize}" width="100%" border="1">
    <c:forEach var="item" items="${objRefData}" varStatus="rowCounter">
        <c:set var="itemData" value="${item.data}"/>
        <c:if test="${rowCounter.count==1}">
            <tr class="dataTableHeader ${dynamicFrontSize}">
                <% String field; %>
                <c:forEach var="field" items="${showKeys}">
                    <% field=(String)jspContext.getAttribute("field"); %>
                    <c:if test='<%=! visibleKeys.contains(field)%>'>
                        <c:if test="${!empty itemData[field].name}">
                            <td onClick="sortBy('${field}', ${!empty param.reverseOrder})">
                            <c:if test="${param.sortBy==field && empty param.reverseOrder}">
                                <span style="color:blue;">^</span>
                            </c:if>
                            <c:if test="${param.sortBy==field && !empty param.reverseOrder}">
                                <span style="color:blue;">v</span>
                            </c:if>

                            <%=((AbsDataClass)jspContext.getAttribute("item")).getDataName(field, langName)%>&nbsp;</td>
                            <% visibleKeys.add(field); %>
                        </c:if>
                    </c:if>
                </c:forEach>
                <c:if test="${!empty optionalInKeys}">
                    <td onclick="return selectFields(event,'<%=ref%>','${optionalInKeys}+${optionalOutKeys}','<%=selectedKeys%>');" title="<nla:text message='win.FieldsMng'/>" class="editFields">>></td>
                </c:if>
            </tr>
        </c:if>

        <c:if test='${(nlatRendersRev[nlatName]!="AgentsBriefStatus") ||
                      (nlatRendersRev[nlatName]=="AgentsBriefStatus" && showLoggedOnly=="false") ||
                      (nlatRendersRev[nlatName]=="AgentsBriefStatus" && showLoggedOnly=="true" && itemData["6_3_2_2_1"].value!="Logout")}'>
            <tr id="itm${item.id}" class='dataTableRow${(rowCounter.count%2==1)?" rowOdd ":" "} ${dynamicFrontSize}'
                <c:if test='${item.objectInfo=="Agent" || nlatRendersRev[nlatName]=="GroupBriefStatus" || nlatRendersRev[nlatName]=="GroupEmailBriefStatus"}'>
                    onmousedown="return openActivityWin(event,'${objRef}',${item.id});"
                </c:if>>
                <c:forEach var="field" items="<%=visibleKeys%>">
                    <c:set var="bgcolor" value="${itemData[field].BValue}"/>
                    <c:set var="itemValue" value="${itemData[field]}"/>
                    <%
                        // calculate background color from text color
                        Long bgcolor=(Long)jspContext.getAttribute("bgcolor");
                        if (bgcolor!=null && bgcolor!=0xFFFFFF) {
                            long color=0;
                            String style=String.format("style='background-color:#%1$06x;color:#%2$x%2$x%2$x;'", bgcolor, color);
                            jspContext.setAttribute("bgcolor",style);
                            //System.out.println("style: " + style);
                        }
                        else
                            jspContext.setAttribute("bgcolor",null);

                        String field=(String)jspContext.getAttribute("field");
                        DataItem dataItem = ((AbsDataClass)jspContext.getAttribute("item")).getData(field);
                        //System.out.println("table.tag - field:" + field + ", dataItem:" + dataItem + ", itemValue:" + ${itemValue});
                        //System.out.println("table.tag - field:" + field + ", dataItem:" + dataItem);
                        if ((dataItem != null) && ("State".equals(dataItem.getName()) || "Release Code".equals(dataItem.getName()))) {
                            jspContext.setAttribute("itemValue",dataItem.getTranslatedValue(langName));
                        }
                    %>

                    <td ${bgcolor} nowrap ${(itemData[field].isNumber)?"align='center' ":""}>
                        <%
                            String md_ViewLevel = (String)jspContext.getAttribute("md_ViewLevel");
                            String req_md_ViewLevel = (String)request.getParameter("md_ViewLevel"); //(String)session.getAttribute("md_ViewLevel");
                            String sess_md_ViewLevel=(String)session.getAttribute("md_ViewLevel");
                            //System.out.println("table.tag - md_ViewLevel: " + md_ViewLevel + ", req_md_ViewLevel: " + req_md_ViewLevel + ", sess_md_ViewLevel: " + sess_md_ViewLevel);
                            //String md_Selected = request.getParameter("md_Selected");
                        %>
                        <c:choose>
                            <c:when test='${item.objectInfo=="SuperGroup" && nlatRendersRev[nlatName]=="MD_SuperGroupBriefReport"}'>
                            <%
                                //System.out.println("item.objectInfo: " + {item.objectInfo});
                                if(dataItem.getKey().equals("6_3_4_1_1"))
                                {
                                    String itemValue = dataItem.getValue() != null ? dataItem.getValue().toString() : "";
                                    SessionData sessionData = (SessionData) session.getAttribute("sessionData");
                                    Long md_Selected = sessionData.getMdSelected("Company", itemValue);
                                    String winUrl = "../main_md.jsp?md_ViewLevel=Department&md_Selected=" + md_Selected;
                                    //System.out.println("table.tag - viewLevel:" + md_ViewLevel + ", itemValue:" + itemValue);
                                    jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\">" + itemValue + "</a>");
                                    //jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\" title='<nla:text message=\"tools.md\"/>'>" + itemValue + "</a>");
                                    //String attrItemValue=(String)jspContext.getAttribute("itemValue");
                                    //System.out.println("table.tag - itemValue: " + attrItemValue);
                                }
                            %>
                            </c:when>
                            <c:when test='${item.objectInfo=="Group" && nlatRendersRev[nlatName]=="MD_GroupBriefStatus"}'>
                            <%
                                if(dataItem.getKey().equals("6_3_1_1_1") && sess_md_ViewLevel.equals("Department"))
                                {
                                    String itemValue = dataItem.getValue() != null ? dataItem.getValue().toString() : "";
                                    SessionData sessionData = (SessionData) session.getAttribute("sessionData");
                                    Long md_Selected = sessionData.getMdSelected("Department", itemValue);
                                    Long md_SelectedRb = sessionData.getMdSelectedId("Department", itemValue);
                                    String winUrl = "../main_md.jsp?md_ViewLevel=Group&md_Selected=" + md_Selected + "&md_SelectedRb=" + md_SelectedRb;
                                    //System.out.println("table.tag - viewLevel:" + md_ViewLevel + ", itemValue:" + itemValue);
                                    jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\">" + itemValue + "</a>");
                                    //jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\" title='<nla:text message=\"tools.md\"/>'>" + itemValue + "</a>");
                                    //System.out.println("table.tag - itemValue: " + attrItemValue);
                                }
                            %>
                            </c:when>
                        </c:choose>
                        ${itemValue}
                    </td>
                </c:forEach>
            </tr>
         </c:if>
    </c:forEach>
        <c:if test="${empty objRefData}">
            <tr class='rowOdd'>
                <td align='center'><nla:text message='win.NoData'/></td>
            </tr>
        </c:if>
</table>

<c:if test='${!header["RefreshMode"]}'>
</div>
</c:if>
<nla:render mask="(Firefox|MSIE|Chrome|Safari)">
    <onRefresh event="${tableName}_update"></onRefresh>

    <c:if test='${!header["RefreshMode"]}'>
        <script src="${pageContext.request.contextPath}/js/tableMng.js" type= "text/javascript"></script>

        <script type="text/javascript">
            // on table update
            function ${tableName}_update(ref) {
                data_update("${tableName}",ref);
                if (activeRowId!=null && document.getElementById(activeRowId)!=null)
                    document.getElementById(activeRowId).style.backgroundColor="Gold";
            }
        </script>
    </c:if>
</nla:render>
<script type="text/javascript">
    function onShowLoggedInOnlySelect(loggedin_only, unique_NlatName)
    { 
        var ctx = "${pageContext.request.contextPath}";
        //alert("here: "+loggedin_only);
        console.log("onShowLoggedInOnlySelect - " + loggedin_only );
        if (document.all)
            objDialog = document.createElement("<iframe name='changeLoggedInState'>");
        else
            objDialog = document.createElement("iframe");
        objDialog.src="about:blank";
        objDialog.name="saveWSWin";
        objDialog.style.display="none";
    
        var objForm = document.createElement('form');
        objForm.action=ctx+"/processActivity";
        objForm.target=objDialog.name;
        objForm.method="post";
    
        var objActivity=document.createElement('input');
        objActivity.type="hidden";
        objActivity.name="activity";
        objActivity.value="SHOW_LOGGED_IN_STATE";
        objForm.appendChild(objActivity);
        
        var objShowLoggedInOnly=document.createElement('input');
        objShowLoggedInOnly.type="hidden";
        objShowLoggedInOnly.name="show_logged_in_only";
        objShowLoggedInOnly.value=loggedin_only;
        objForm.appendChild(objShowLoggedInOnly);


        var objNlatName=document.createElement('input');
        objNlatName.type="hidden";
        objNlatName.name="unique_nlat_name";
        objNlatName.value=unique_NlatName;
        objForm.appendChild(objNlatName);
        console.log("onShowLoggedInOnlySelect - objNlatName " + objNlatName.value );
    
        document.body.appendChild(objDialog);
        document.body.appendChild(objForm);
        objForm.submit();
    
        document.body.removeChild(objForm);
    }
</script>
