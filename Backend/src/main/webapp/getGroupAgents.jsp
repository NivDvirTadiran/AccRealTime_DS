<%@page pageEncoding="UTF-8" import="tadiran.webnla.bean.SessionData, tadiran.emisweb.GenListDataItemType, java.util.List, java.util.Iterator, tadiran.webnla.bean.Agent, java.util.Iterator, tadiran.webnla.NLAContext, tadiran.webnla.servlet.ProcessActivity, tadiran.webnla.tag.LocaleMessage" %>

<%
	String logged="";
	String available="";
	String ticket=((SessionData)session.getAttribute("sessionData")).getTicket();
	List<GenListDataItemType> items[]=null;
	if (request.getParameter("groupId")!=null) {
		items=ProcessActivity.getLoggedAgents(request.getParameter("groupId"), ticket);
	}
	else
	if (request.getParameter("agentId")!=null) {
		items=ProcessActivity.getLoggedGroups(request.getParameter("agentId"), ticket);
	}
	
	if (items!=null) {
		GenListDataItemType item;
		for (int i=0; i<items[0].size(); i++) {
			item=items[0].get(i);
                        String out1 = null;
                        //String out2 = null;
                        try {
                            out1 = new String(item.getName().getBytes("ISO-8859-1"), "UTF-8"); //convertFromUTF8
                            item.setName(out1);
                        } catch (java.io.UnsupportedEncodingException e) {
                            //log.error("GroupsUpdater.forceUpdate - UnsupportedEncodingException: " + e);
                        }
			logged += ",[" + item.getId() + ","+"'" + item.getName().replace("'","\\'") + "'"+"]";
		}
		for (int i=0; i<items[1].size(); i++) {
			item=items[1].get(i);
                        String out1 = null;
                        //String out2 = null;
                        try {
                            out1 = new String(item.getName().getBytes("ISO-8859-1"), "UTF-8"); //convertFromUTF8
                            item.setName(out1);
                        } catch (java.io.UnsupportedEncodingException e) {
                            //log.error("GroupsUpdater.forceUpdate - UnsupportedEncodingException: " + e);
                        }
			available += ",[" + item.getId() + ","+"'" + item.getName().replace("'","\\'") + "'"+"]";
			//available+=",["+item.getId()+",'"+LocaleMessage.encode(item.getName())+"']";
		}

		if (logged.length()>0)
			logged=logged.substring(1);
		if (available.length()>0)
			available=available.substring(1);
	}
%>
.<%=items[1]%>.
<script language="javascript">
	//alert("<%=logged%>"+"<%=available%>");
	parent.setGroupAgents([<%=logged%>]);
	parent.setItems([<%=available%>]);
</script>
