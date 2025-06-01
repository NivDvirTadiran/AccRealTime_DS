<%@attribute name="text"%>
<%@attribute name="type"%>

<%@tag pageEncoding="UTF-8" import="tadiran.webnla.NLAContext, tadiran.webnla.bean.AbsDataClass, java.util.Collection, java.util.Iterator, tadiran.webnla.tag.RefObject, tadiran.webnla.tag.LocaleMessage" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>

<c:if test="${empty text}">
<%
	int FONT_SIZE=7;
	int width=99999;
	String size=(String)request.getAttribute("size");
	if (size!=null)
		width=Integer.parseInt(size.replaceAll("x.*", ""));

	String langName=(String)session.getAttribute("Accept-Language");
	// get template's category, name, and id
	String text=request.getRequestURI();
	int ind1=text.lastIndexOf('/');
	int ind2=text.lastIndexOf(".nla");
	int ind3=text.indexOf(".",ind1+1);
	String nlatName=text.substring(ind1+1,ind2);
	int ind=nlatName.indexOf(".");
	nlatName=LocaleMessage.getMessage(nlatName.substring(0,ind), langName)+"."+LocaleMessage.getMessage(nlatName.substring(ind+1), langName);

	String nlatCategory=text.substring(ind1+1,ind3);
	if (nlatCategory.charAt(nlatCategory.length()-1)=='s')
		nlatCategory=nlatCategory.substring(0,nlatCategory.length()-1);

	text=LocaleMessage.getMessage("win.ChangeTip", langName);
	String nlatId=request.getParameter(nlatCategory.toLowerCase()+"Id");
	String nlatNum="";
	if (nlatId!=null && !nlatId.equals("")) {
		String objName=RefObject.getRefObjName(nlatCategory.substring(0,1).toUpperCase()+nlatCategory.substring(1), request);
		Collection objCollection=NLAContext.getInstance().getObjectMap(objName).values();
		Iterator iterator=objCollection.iterator();
		AbsDataClass item;
		objName="";
		while(iterator.hasNext()) {
			item=(AbsDataClass)iterator.next();
			objName=item.getName()+", "+objName;
			nlatNum=item.getNum()+", "+nlatNum;
			//String objNameTmp=item.getName();
			//String objNumTmp=item.getNum();
			//if(objNameTmp!=null)
			//    objName = objNameTmp + ", " + objName;
			//if(objNumTmp!=null)
			//    nlatNum = objNumTmp + ", " + nlatNum;
		}
		objName=objName.replaceAll(", $", "");
		nlatNum=nlatNum.replaceAll(", $", "");

		// reduce width of template param's names
		if ((nlatName.length()+objName.length())*FONT_SIZE>width) {
			text="["+objName+"] "+text;
			objName=nlatNum;
		}
                //console.log("nlatName: " + nlatName);
                //console.log("objName:  " + objName);
		// cut-fit width of template param's names
		if ((nlatName.length()+objName.length())*FONT_SIZE>width) {
			objName=objName.substring(0,(width-nlatName.length()*FONT_SIZE)/FONT_SIZE)+"...";
		}
                text="["+objName+"] "+text;
                objName = "...";
%>
<nla:render mask="(Firefox|MSIE|Chrome|Safari)">
	<%	text="<span onclick='changeId(this,\""+nlatCategory.toLowerCase()+"Id="+nlatId+"\")' style='color:#bbb; cursor:pointer;' title='"+text+"'>["+objName+"]</span>";
	%>
</nla:render>
<nla:render mask="(BlackBerry|IEMobile)">
	<%	text="["+objName+"]";
	%>
</nla:render>
<%
	}
	else {
		text="";
		/*nlatParams=request.getQueryString();
		if (nlatParams!=null)
			nlatParams="("+nlatParams+")";
		else
			nlatParams="";*/
	}

	out.print(nlatName+" "+text);
%>
</c:if>
<c:if test="${!empty text}">
	<c:if test='${!header["RefreshMode"]}'>
		<c:if test="${empty type}"><br><br></c:if>
		<div class="${(!empty type)?type:'title'}"><nla:text message="${text}"/></div>
	</c:if>
</c:if>
