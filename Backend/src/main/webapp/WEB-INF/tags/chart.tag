<%------------------------------------------------------------
CHART - provide data in chart view
params: type - (mandatory param) -chart type (3Dpie or bar or bar-stack or area or line)
		keys - (mandatory param) - data fields to display. for bar you can use: field1-field2,... format to display bar-stack chart
		ref - ref object name, if not defined then required <nla:obj ref="..."> tag before table tag
		title - chart title
usage:
1.	<nla:obj ref="Group">
		<nla:chart type="3Dpie" keys="20_3_1_4_4,20_3_1_4_7" title="Calls Distribution Graph"/>
	</nla:obj>

2.	<nla:obj ref="Group">
		<nla:chart type="bar" keys="6_3_1_2_1-20_3_1_2_1,6_3_1_2_7-20_3_1_2_7" title="Calls in Queue"/>
	</nla:obj>
-----------------------------------------------------------------%>

<%@attribute name="type" required="true"%>
<%@attribute name="keys" required="true"%>
<%@attribute name="ref" %>
<%@attribute name="title"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>
<nla:define name="chartName"/>

<c:if test='${!header["RefreshMode"]}'>
    <c:set var="src" value='${pageContext.request.contextPath}/drawChart?type=${type}&refObjectName=${(!empty ref)?ref:(refObjectName)}&keys=${keys}&title=${title}'/>
    <img name="chart" id="${chartName}" border="0" src="${src}" align="top" onload="onLoaded();"/>

    <nla:render mask="(Firefox|MSIE|Chrome|Safari)">
        <script type="text/javascript">
            var UPDATE_INTERVAL=2000;

            // initialized by document
            var ${chartName}_ref=document.getElementById("${chartName}");
            var ${chartName}_url=${chartName}_ref.src;
            var ${chartName}_size="";
            var chartsNum=${chartNameId}-1;
            var ${chartName}_lastUpdate=0;
            //var isPaused=false;
            
            function onLoaded() {
                //isPaused=false;
            }

            // on chart update
            function ${chartName}_update(ref) {
                //alert(chartName+"_update("+ref+")");
                //if (isPaused==true) {
                //    return;
                //}
                
                // rescale chart dim
                var w=document.body.clientWidth-20;
                var h=document.body.clientHeight-((document.all)?10:30);
                if (chartsNum>1) {
                    var c=parseInt((chartsNum==2)?2:(chartsNum+1)/2);
                    var r=parseInt((chartsNum+1)/c);

                    if (h>w) {
                        var t=c;
                        c=r;
                        r=t;
                    }
                    w=parseInt(w/c);
                    if (document.getElementsByTagName("onRefresh").length==chartsNum) {
                        //alert(h+":"+r);
                        h=parseInt(h/r);
                    }else {
                        h=230;
                    }
                }
            
                if (${chartName}_size!=((w-2)+"x"+h)) {
                    ${chartName}_size=((w-2)+"x"+h);
                    ${chartName}_lastUpdate=0;
                }

                if ((new Date()-${chartName}_lastUpdate) > UPDATE_INTERVAL) { 
                    //isPaused=true;
                    ${chartName}_lastUpdate=new Date();

                    ${chartName}_ref.src=${chartName}_url+"&size="+${chartName}_size+"&ts="+Math.random();
                }
            }
        
            ${chartName}_update();
        </script>
    </nla:render>
</c:if>
<nla:render mask="(Firefox|MSIE|Chrome|Safari)">
    <onRefresh event="${chartName}_update"></onRefresh>
</nla:render>
