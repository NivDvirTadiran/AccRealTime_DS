<%@page pageEncoding="UTF-8" import="java.util.List, java.util.Vector, java.util.Collections, java.util.Comparator, java.util.HashMap,
										tadiran.webnla.bean.Agent, tadiran.webnla.bean.SessionData, tadiran.webnla.NLAContext,
										tadiran.emisweb.GroupListDataItemType" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="nla" uri="/WEB-INF/nlaTags.tld" %>

<%
        String dynamicFrontSize=(String)session.getAttribute("dynamicFrontSize");
	String type=request.getParameter("type");
	if (type==null) type="groups";

	if (type.equalsIgnoreCase("groups"))
		type="Agents";
	else
	if (type.equalsIgnoreCase("agents"))
		type="Groups";
	else
		type="Agents";

	List<Agent> agents=new Vector(NLAContext.getInstance().getAgents().getData().values());
	Collections.sort(agents,new Comparator() {
							public int compare (Object o1, Object o2) {
								String o1_name=((Agent)o1).getName();
								String o2_name=((Agent)o2).getName();
								return o1_name.compareTo(o2_name);
							}});


	SessionData sessionData = (SessionData) session.getAttribute("sessionData");
	List groups=sessionData.getGroups();
	Collections.sort(groups, new Comparator() {
							public int compare (Object o1, Object o2) {
								String o1_name=((GroupListDataItemType)o1).getGrpName();
								String o2_name=((GroupListDataItemType)o2).getGrpName();
								return o1_name.compareTo(o2_name);
							}});
%>

<html>
	<head>
		<title><nla:text message='loginMng.Title'/></title>
		<style>
			body {
				font-family:Arial;
				background:none;
			}

			.listbox {
				width: 160px; height:200px;
				border:1px dotted #DBDBDB;
				padding-left:5px;
			}

			.button {
				width: 70px;
				margin:2px;
				/*font-size:11px;*/
			}

			.caption {
				font-weight:bold; font-size:13px;
				text-align:center;
				color:DarkSlateBlue;
				height:25px;
			}
		</style>
		<link href="css/nlaApp.css" type="text/css" rel="stylesheet"/>

		<script language="Javascript">
			function load() {
				if (category.selectedIndex==-1)
					category.selectedIndex=0;

				onCategoryChange();
				setInterval(onCategoryChangeReq,5000);
			}

			function login() {
				if (items.selectedIndex==-1)
					return;

				var id_list=[];
				for (var i=0; i< items.options.length; i++) {
					if (items.options[i].selected) {
						var item=items.options[i--];
						var obj=item.cloneNode(true);
						obj.selected=false;
						agtINgrp.appendChild(obj);
						items.removeChild(item);

						id_list.push(obj.id);
					}
				}

				srv.src="processActivity?activity=login&"+getCategory()+"&"+getItemsName()+"Id="+id_list.join(",");
				srv.location=srv.src;
			}

			function logout() {
				if (agtINgrp.selectedIndex==-1)
					return;

				var id_list=[];
				for (var i=0; i< agtINgrp.options.length; i++) {
					if (agtINgrp.options[i].selected) {
						var item=agtINgrp.options[i--];
						var obj=item.cloneNode(true);
						obj.selected=false;
						items.appendChild(obj);
						agtINgrp.removeChild(item);

						id_list.push(obj.id);
					}
				}

				srv.src="processActivity?activity=logout&"+getCategory()+"&"+getItemsName()+"Id="+id_list.join(",");
				srv.location=srv.src;
			}

			function getItemsName() {
				<c:if test='<%=type.equals("Agents")%>'>
					return "agent";
				</c:if>
				<c:if test='<%=type.equals("Groups")%>'>
					return "group";
				</c:if>
			}

			function getCategory() {
				var id=category.options[category.selectedIndex].id;
				<c:if test='<%=type.equals("Agents")%>'>
					return "groupId="+id;
				</c:if>
				<c:if test='<%=type.equals("Groups")%>'>
					return "agentId="+id;
				</c:if>
			}

			function onCategoryChange() {
				agtINgrp.innerHTML="";
				items.innerHTML="";
				onCategoryChangeReq();
			}

			function onCategoryChangeReq() {
				srv.src="getGroupAgents.jsp?"+getCategory();
				srv.location=srv.src;
			}

			function setGroupAgents(data) {
				//alert(data);
				for (var i=0; i<data.length; i++) {
					itm=agtINgrp.namedItem(data[i][0]);
					if (itm==null) {
						var obj=document.createElement("OPTION");
						obj.id=data[i][0];
						obj.text=data[i][1];
						obj.isNew=true;
						if (document.all) //IE
							agtINgrp.add(obj);
						else
							agtINgrp.appendChild(obj);
					}
					else
						itm.isNew=true;
				}
				for(i=0; i<agtINgrp.options.length; i++) {
					if (!agtINgrp.options[i].isNew)
						agtINgrp.remove(i);
					else
						agtINgrp.options[i].isNew=false;
				}
			}

			function setItems(data) {
				for (var i=0; i<data.length; i++) {
					itm=items.namedItem(data[i][0]);
					if (itm==null) {
						var obj=document.createElement("OPTION");
						obj.id=data[i][0];
						obj.text=data[i][1];
						obj.isNew=true;
						if (document.all) //IE
							items.add(obj);
						else
							items.appendChild(obj);
					}
					else
						itm.isNew=true;
				}
				for(i=0; i<items.options.length; i++) {
					if (!items.options[i].isNew)
						items.remove(i);
					else
						items.options[i].isNew=false;
				}
			}

			function changeType(type) {
				document.location=document.location.pathname+"?type="+type;
			}

			function closeActivityWin(errorMessage) {
				if (errorMessage!=null)
					alert(errorMessage);
			}
		</script>
	</head>
	<body onload="load()" class="toolsBody">
		<iframe id="srv" style="display:none;"></iframe>
		<div style="background-color:LightSlateGray; padding-top:4px; padding-bottom:2px;">
                    <span class="closeBtn2  ${dynamicFrontSize}" onmousedown="parent.closeDialog();" title="<nla:text message='tools.CloseWin'/>">x&nbsp;</span>
                    <span unselectable="ON" style="color:white; position:relative; bottom:1px; padding-left:5px; font-weight:bold; -moz-user-select: none;"><nla:text message='loginMng.Title'/></span>
                    <span style="position:fixed; width:80%; text-align:right;">
                        <span id="AgentsSpan" class="navTab <%=(type.equals("Agents"))?"navActiveTab":""%>  ${dynamicFrontSize}" onclick="changeType('groups');"><nla:text message='loginMng.TitleAgents'/></span><span id="GroupsSpan" class="navTab <%=(type.equals("Groups"))?"navActiveTab ":""%> ${dynamicFrontSize}" onclick="changeType('agents');"><nla:text message='loginMng.TitleGroups'/></span>
                    </span>
		</div>
		<table width="640" cellspacing=0 cellpadding=2>
			<tr>
				<td colspan="5">&nbsp;</td>
			</tr>
			<tr class="caption  ${dynamicFrontSize}">
				<td>
					<c:if test='<%=type.equals("Agents")%>'><nla:text message='loginMng.Groups'/></c:if>
					<c:if test='<%=type.equals("Groups")%>'><nla:text message='loginMng.Agents'/></c:if>
				</td>
				<td width="5" rowspan="2" style="border-left:3px dotted lightSlateGray;">&nbsp;</td>
				<td>
					<nla:text message='loginMng.Logged'/>&nbsp;<%=type%>
				</td>
				<td></td>
				<td>
					<nla:text message='loginMng.Available'/>&nbsp;<%=type%>
				</td>
			</tr>
			<tr>
				<td>
					<select class="listbox" id="category" size="10" onchange="onCategoryChange();" style="border:none; margin-left:7px;">
						<c:if test='<%=type.equals("Agents")%>'>
							<c:forEach var="group" items="<%=groups%>">
							<option id="${group.grpId}">${group.grpName}</option>
							</c:forEach>
						</c:if>
						<c:if test='<%=type.equals("Groups")%>'>
							<c:forEach var="agent" items="<%=agents%>">
								<c:if test="${!empty agent.ext}">
									<option id="${agent.id}">${agent.name}</option>
								</c:if>
							</c:forEach>
						</c:if>
					</select>
				</td>
				<td align="center">
					<select class="listbox" size="10" multiple id="agtINgrp">
					</select>
				</td>
				<td align="center">
					<input type="button" value="<nla:text message='loginMng.Login'/>" class="button" onclick="login();"><br>
					<input type="button" value="<nla:text message='loginMng.Logout'/>" class="button" onclick="logout();"><br>
				</td>
				<td align="center">
					<select class="listbox" id="items" size="10" multiple>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2"></td>
				<td colspan="3" align="center">
					<br>
				</td>
			</tr>
		</table>
	</body>
</html>
