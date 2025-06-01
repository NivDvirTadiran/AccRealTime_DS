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
<%@attribute name="optionalKeys" %>

<%@tag import="tadiran.webnla.NLAContext, tadiran.webnla.bean.AbsDataComparator, java.util.Collection, java.util.ArrayList, java.util.Arrays, java.util.Vector, java.util.Collections, java.util.Comparator, java.util.LinkedHashSet, tadiran.webnla.bean.AbsDataClass, tadiran.webnla.bean.DataItem, tadiran.webnla.bean.SessionData" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<nla:define name="tableName"/>
<%
    String langName=(String)session.getAttribute("Accept-Language");
    // normalize filed names
    String selectedKeys=request.getParameter("fields");
    if (selectedKeys!=null) {
        selectedKeys=selectedKeys.replaceFirst("^f","");
        selectedKeys=selectedKeys.replaceAll(",f",",");
        selectedKeys+=",.";
    }

    LinkedHashSet visibleKeys=new LinkedHashSet(); //visible fields
    
    ArrayList<String> lKeys=new ArrayList(Arrays.asList(((String)jspContext.getAttribute("keys")).split("[ ]*,[ ]*")));
    String optKeys=(String)jspContext.getAttribute("optionalKeys");
    if (optKeys==null) {
        optKeys="";
    }
    ArrayList<String> lOptKeys=new ArrayList(Arrays.asList((optKeys).split("[ ]*,[ ]*")));
    lOptKeys.retainAll(lKeys);
    lKeys.removeAll(lOptKeys);
    
    ArrayList<String> lSelKeys=new ArrayList();
    if (selectedKeys!=null) {
        lSelKeys.addAll(Arrays.asList(selectedKeys.split("[ ]*,[ ]*")));
    }
    else {
        lSelKeys.addAll(lOptKeys);
    }
    selectedKeys=lSelKeys.toString().replaceAll(",\\s", ",");
    selectedKeys=selectedKeys.substring(1,selectedKeys.length()-1);
    
    
    lKeys.addAll(lSelKeys);
%>
<c:set var="nlatName" value='<%=request.getServletPath().replaceAll("^(.)*/", "")%>'/>
<c:set var="showKeys" value='<%=lKeys%>'/>
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
<c:if test='${!header["RefreshMode"]}'>
    <div style="width:100%;<nla:render mask="(Firefox|Chrome|Safari)">height:93%;</nla:render>overflow-y:auto;overflow-x:auto;">
</c:if>
                

<table id="${tableName}" class="dataTable_MD ${dynamicFrontSize}" width="100%" border="1">
    <c:forEach var="item" items="${objRefData}" varStatus="rowCounter">
        <c:set var="itemData" value="${item.data}"/>
        <c:if test="${rowCounter.count==1}">
        <tr class="dataTableHeader_MD ${dynamicFrontSize}">
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
            <c:if test="${!empty optionalKeys}">
                <td onclick="return selectFields(event,'<%=ref%>','${optionalKeys}','<%=selectedKeys%>');" title="<nla:text message='win.FieldsMng'/>" class="editFields">>></td>
            </c:if>
        </tr>
    </c:if>

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
                        //String objInfo = (String)((AbsDataClass)jspContext.getAttribute("item")).getObjectInfo();
                        //System.out.println("objInfo " + objInfo);
                        DataItem dataItem = ((AbsDataClass)jspContext.getAttribute("item")).getData(field);
                        //System.out.println("table_md.tag - field:" + field + ", dataItem:" + dataItem);
                        if ("State".equals(dataItem.getName()) || "Release Code".equals(dataItem.getName())) {
                            jspContext.setAttribute("itemValue",dataItem.getTranslatedValue(langName));
                        }
                    %>

                    <td ${bgcolor} nowrap ${(itemData[field].isNumber)?"align='center' ":""}>
                        <%
                            String md_ViewLevel = (String)jspContext.getAttribute("md_ViewLevel");
                            String req_md_ViewLevel = (String)request.getParameter("md_ViewLevel"); //(String)session.getAttribute("md_ViewLevel");
                            String sess_md_ViewLevel=(String)session.getAttribute("md_ViewLevel");
                            //System.out.println("table_md.tag(1) - ViewLevel: " + md_ViewLevel + ", req_md_ViewLevel: " + req_md_ViewLevel + ", sess_md_ViewLevel: " + sess_md_ViewLevel);
                            //String md_Selected = request.getParameter("md_Selected");
                        %>
                        <c:choose>
                            <c:when test='${item.objectInfo=="PeriodData" && nlatRendersRev[nlatName]=="MD_SuperGroupDailyBriefReport"}'>
                            <%
                                if(dataItem.getKey().equals("6_3_4_1_1"))
                                {
                                    String itemValue = dataItem.getValue() != null ? dataItem.getValue().toString().replace("<","&lt;").replace(">","&gt;") : "";
                                    SessionData sessionData = (SessionData) session.getAttribute("sessionData");
                                    Long md_Selected = sessionData.getMdSelected("Company", itemValue);
                                    String winUrl = "../main_md.jsp?md_ViewLevel=Department&md_Selected=" + md_Selected;
                                    //System.out.println("table_md.tag(2) - viewLevel:" + md_ViewLevel + ", itemValue:" + itemValue);
                                    jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\">" + itemValue + "</a>");
                                    //jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\" title='<nla:text message=\"tools.md\"/>'>" + itemValue + "</a>");
                                    //String attrItemValue=(String)jspContext.getAttribute("itemValue");
                                    //System.out.println("table_md.tag - itemValue: " + attrItemValue);
                                }
                            %>
                            </c:when>
                            <c:when test='${item.objectInfo=="PeriodData" && nlatRendersRev[nlatName]=="MD_GroupDailyBriefReport"}'>
                            <%
                                if(dataItem.getKey().equals("6_3_1_1_1") && sess_md_ViewLevel.equals("Department"))
                                {
                                    String itemValue = dataItem.getValue() != null ? dataItem.getValue().toString() : "";
                                    SessionData sessionData = (SessionData) session.getAttribute("sessionData");
                                    Long md_Selected = sessionData.getMdSelected("Department", itemValue);
                                    Long md_SelectedRb = sessionData.getMdSelectedId("Department", itemValue);
                                    String winUrl = "../main_md.jsp?md_ViewLevel=Group&md_Selected=" + md_Selected + "&md_SelectedRb=" + md_SelectedRb;
                                    //System.out.println("table_md.tag - viewLevel:" + md_ViewLevel + ", itemValue:" + itemValue);
                                    jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\">" + itemValue + "</a>");
                                    //jspContext.setAttribute("itemValue", "<a href=\"" + winUrl + "\" style=\"color:blue;\" target=\"_parent\" title='<nla:text message=\"tools.md\"/>'>" + itemValue + "</a>");
                                    //System.out.println("table_md.tag - itemValue: " + attrItemValue);
                                }
                            %>
                            </c:when>
                        </c:choose>
                        ${itemValue}
                    </td>
                </c:forEach>
            </tr>
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