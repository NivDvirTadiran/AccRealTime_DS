<%------------------------------------------------------------
DATA - display data field
params: key - (mandatory param) field to display
		name - field name
		format - field format
usage:
1.	...
	<nla:pane caption="Agents" width="280>
		<nla:data key="6_3_1_3_1" name="Logged In"/>
		<nla:data key="6_3_1_3_2"/>
		...
	</nla:pane>
2. <nla:obj ref="Groups">
		<nla:data key="20_3_1_2_1"/>
	</nla:obj>
-----------------------------------------------------------------%>

<%@attribute name="key" required="true"%>
<%@attribute name="name"%>
<%@attribute name="format"%>

<%@tag import="tadiran.webnla.NLAContext, tadiran.webnla.bean.AbsDataClass, tadiran.webnla.tag.LocaleMessage, java.util.Collection, java.util.Iterator" %>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>

<c:if test="${!empty cols && empty currRow}">
    <c:if test="${currCol==cols}">
        </tr>
        <tr>
    </c:if>
    <c:if test="${currCol!=-1}">
        <td width="${(colWidth!="100%")?colWidth:''}">
    </c:if>
	
    <c:if test="${currCol==cols || currCol==-1}">
        <c:set var="currCol" value="0" scope="request"/>
    </c:if>
        <c:set var="currCol" value="${currCol+1}" scope="request"/>
</c:if>

<c:if test="${!empty tabName}">
    <c:set var="value" value="${refObject.data[key]}"/>
    <c:set var="bgcolor" value="${refObject.data[key].BValue}"/>
    <%
        // calculate background color from text color
        Long bgcolor=(Long)jspContext.getAttribute("bgcolor");
        if (bgcolor!=null && bgcolor!=16777215) {
            long color=0;
            String style=String.format("style='background-color:#%1$06x;color:#%2$x%2$x%2$x;'", bgcolor, color);
            jspContext.setAttribute("bgcolor",style);
            //System.out.println("style: " + style);
        }
        else
            jspContext.setAttribute("bgcolor",null);
    %>
</c:if>
<c:if test="${empty tabName}">
    <%
        // get data field (key) value
        String key=(String)jspContext.getAttribute("key");
        String tempKey1="";
        String tempKey2="";
        String objName=(String)request.getAttribute("refObjectName");
        Collection objCollection=NLAContext.getInstance().getObjectMap(objName).values();
        Iterator iterator=objCollection.iterator();
        Long cumvalue=0L, temp=0L, numGroups=0L;
        Object  tempObj;
        AbsDataClass item;
        boolean percent = false;
        if(key.contains("a"))
        {
            percent = true;
            if(key.equals("6_3_1_4_3a"))
            {
                tempKey1="6_3_1_4_3";
                tempKey2="6_3_1_4_2";
            }
            else if(key.equals("6_3_4_4_3a"))
            {
                tempKey1="6_3_4_4_3";
                tempKey2="6_3_4_4_2";
            }
        }
        if(percent)
        {
            Long tempVal1=0L,tempVal2=0L;
            Long cumVal1=0L,cumVal2=0L;
            while(iterator.hasNext())
            {
                item=(AbsDataClass)iterator.next();
                tempObj=item.getData(); //refresh data
                if(objName.contains("Period"))
                {
                    //System.out.println("DataTag update for Period" + tempObj.toString());
                    String s1 = item.getDataValue(tempKey1).toString();
                    String s2 = item.getDataValue(tempKey2).toString();
                    //System.out.println("Type of item " + item.getClass().toString() + ", Value " + item.getDataValue(key).toString());
                    tempVal1 = Long.parseLong(s1);
                    tempVal2 = Long.parseLong(s2);
                    if (tempVal1!=null)
                        cumVal1+=tempVal1;
                    if (tempVal2!=null)
                        cumVal2+=tempVal2;
                    //System.out.println("DataTag update for Period - [tempKey1:" + s1 + "," + tempVal1 + "," + cumVal1 + "],[tempKey2:" + s2 + "," + tempVal2 + "," + cumVal2 + "]" );
                }
                else
                {
                    String tempS=item.getDataValue(key).toString();
                    if(tempS!=null && !tempS.isEmpty())
                        temp=Long.parseLong(tempS);
                    else
                        temp=0L;
                    if (temp!=null)
                        cumvalue+=temp;
                }
            }
            if(cumVal2!=0)
            {
                cumvalue=(100*cumVal1)/cumVal2;
                if(cumvalue > 100)
                {
                    System.out.println("DataTag calculating percentage for ERS " + key + " - cumVal1: " + cumVal1.toString() + ", cumVal2: " + cumVal2.toString());
                    cumvalue = 100L;
                }
            }
            //System.out.println("DataTag update Period for key " + key + " - [cumVal1: " + cumVal1 + "],[cumVal2: " + cumVal2 + "] - Final: " + cumvalue);
        }
        else
        {
            while(iterator.hasNext())
            {
                item=(AbsDataClass)iterator.next();
                tempObj=item.getData(); //refresh data
                if(objName.contains("Period"))
                {
                    //System.out.println("DataTag update for Period" + tempObj.toString());
                    String s = item.getDataValue(key).toString();
                    //System.out.println("Type of item " + item.getClass().toString() + ", Value " + item.getDataValue(key).toString());
                    if(s!=null && s.length()>0)
                        temp = Long.parseLong(s);
                    if (temp!=null)
                        cumvalue+=temp;
                }
                else
                {
                    String tempS=item.getDataValue(key).toString();
                    if(tempS!=null && !tempS.isEmpty())
                        temp=Long.parseLong(tempS);

                    //temp=(Long)item.getDataValue(key);
                    if (temp!=null)
                    {
                        if(key.equals("6_3_1_2_4"))
                            cumvalue = (temp > cumvalue) ? temp : cumvalue;
                        else
                            cumvalue+=temp;
                    }
                }
            }
        }
        
        //System.out.println("DataTag setAttribute(value) [" + key + ":" + cumvalue + "]");
        jspContext.setAttribute("value", cumvalue);
    %>
</c:if>

<c:if test="${format=='time' && !empty value}">
    <%
        // convert data value into time format
        String frmOut=jspContext.getAttribute("value").toString();
        try {
            Long value=Long.parseLong(frmOut);
            if (value/60<60)
                frmOut=String.format("%1$d:%2$02d",value/60,value%60);
            else
                frmOut=String.format("%1$d:%2$02d:%3$02d",value/3600,(value%3600)/60,value%60);
        }
        catch(Exception e) {
        }

        jspContext.setAttribute("value",frmOut);
    %>
</c:if>
<c:if test="${format=='percent' && !empty value}">
    <c:set var="value" value="${value}%"/>
</c:if>

<c:if test="${!empty name}">
    <%
        //8-Jul-2020 YR BZ#52540
        String nameBody="name."+name;
        //System.out.println("nameBody");
        session.setAttribute("nameBody", nameBody);
    %>
    <c:set var="nameBody" value='${sessionScope.nameBody}'/>
</c:if>

<c:if test="${!empty tabName}">
<div id="${key}" class="field">
    
    <%
	session.setAttribute("lang", (String)session.getAttribute("Accept-Language"));
    %>
    
    <c:set var="langName" value='${sessionScope.lang}'/>
    
    <%--span class="fieldName">${(!empty name)?name:(refObject.data[key].name)}</span><span class='fieldValue <nla:render mask="(Chrome|Safari)">fieldValueChrome</nla:render>' ${bgcolor}>${value}</span--%>
    <%--span class="fieldName">${(!empty name)?name:(refObject.data[key].getName(langName))}</span><span class='fieldValue <nla:render mask="(Chrome|Safari)">fieldValueChrome</nla:render>' ${bgcolor}>${value}</span--%>
    <%-- 8-Jul-2020 YR BZ#52540 --%>
    <span class="fieldName">${(!empty name)?LocaleMessage.getMessage(nameBody, langName):(refObject.data[key].getName(langName))}</span><span class='fieldValue <nla:render mask="(Chrome|Safari)">fieldValueChrome</nla:render>' ${bgcolor}>${value}</span>
</div>
</c:if>
            
<c:if test="${empty tabName}">
    <div id="data_${key}" align="center">${value}</div>
    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
        <onRefresh event="data${key}_update"></onRefresh>
        <c:if test='${!header["RefreshMode"]}'>
            <script type="text/javascript">
                var obj=document.getElementById("data_${key}");
                obj.style.fontSize="5em";
                var docHeight=0;

                // on data value (pane) update
                function data${key}_update(ref) {
                    obj.innerHTML=ref.getElementsByTagName("div")["data_${key}"].innerHTML;
                    //alert(ref.getElementsByTagName("div")["data_${key}"].innerHTML);
                    if (docHeight!=document.body.clientHeight) {
                        docHeight=document.body.clientHeight;
                        obj.style.marginTop="-20px";
                        obj.style.fontSize=docHeight/22+"em";
                    }
                }
            </script>
        </c:if>
    </nla:render>
</c:if>

<c:if test="${!empty cols && empty currRow}">
    </td>
</c:if>
