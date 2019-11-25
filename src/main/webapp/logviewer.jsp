<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page
	import="java.util.logging.*,io.funxion.logviewer.WebsocketAppender,io.funxion.logviewer.LogGenerator"%>
<!DOCTYPE html>
<html>
<head>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Server Log</title>
<%
	//Only needed in the demo
	LogGenerator.init();

	String logLevel = request.getParameter("loggerLevel");
	String loggerName = request.getParameter("loggerName");
	if (logLevel == null)
		logLevel = "INFO";
	if (loggerName == null)
		loggerName = "io.funxion";
	LogManager logManager = LogManager.getLogManager();
	Logger log = Logger.getLogger(loggerName);
	Handler[] handlers = log.getHandlers();
	if (handlers.length != 0) {
		log.removeHandler(handlers[0]);
	} 
	
	log.addHandler(new WebsocketAppender());
	System.out.println("WebsocketAppender added as log handler");
	log.setLevel(Level.parse(logLevel));
	logManager.addLogger(log);
%>
<script type="text/javascript">
	function init() {
		output = document.getElementById("output");
		var path = document.location.pathname;
		var protocol = document.location.origin.split(':')[0];
		var wsProtocol;
		if(protocol == 'http'){
			wsProtocol = 'ws';
		} else {
			wsProtocol = 'wss';
		}
		
		pathparts = path.split('/');
		pathparts.pop();
		ctx = pathparts.join('/');

		var wsUri = wsProtocol + "://" + document.location.host + ctx + "/serverlog";
		writeToScreen("Connecting to " + wsUri);

		var websocket = new WebSocket(wsUri);
		websocket.onopen = function(evt) {
			onOpen(evt)
		};
		websocket.onmessage = function(evt) {
			onMessage(evt)
		};
		websocket.onerror = function(evt) {
			onError(evt)
		};
		websocket.onclose = function(evt) {
			onClosed(evt)
		};
	}

	function onOpen(evt) {
		writeToScreen("CONNECTED");
	}
	function onClosed(evt) {
		writeToScreen("SERVER CLOSED CONNECTION");
	}

	function onMessage(evt) {
		//writeToScreen("RECEIVED: " + evt.data);
		appendLog(evt.data);
	}

	function onError(evt) {
		writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
	}

	function writeToScreen(message) {
		//output = document.getElementById("output");
		var pre = document.createElement("p");
		pre.style.wordWrap = "break-word";
		var d = new Date();
		pre.innerHTML = d.toLocaleTimeString() + ' : ' + message;
		output.appendChild(pre);
	}
	function appendLog(message) {
		output = document.getElementById("logoutput");
		var d = new Date();
		output.innerHTML = output.innerHTML + '\n' + d.toLocaleTimeString()
				+ ' : ' + message;
		window.scrollTo(0, document.body.scrollHeight);
	}
	window.addEventListener("load", init, false);
</script>
</head>
<body style="margin: 0px">
	<h1 style="background-color: #3071a9;color:white;margin: 0px; padding:15px">Log Messages from Application</h1>
		<div id="output" style="background-color: white; padding:15px"></div>
		<form action="logviewer.jsp" method="get">
			<c:set var="level" scope="session" value='${param["loggerLevel"]}'/>
			<div class="">
				<label for="loggerLevel">Logger Level :</label> <select class=""
					id="loggerLevel" name="loggerLevel" >
					<option value="SEVERE" ${'SEVERE' == level ? 'selected' : ''}>SEVERE</option>
					<option value="WARNING" ${'WARNING' == level ? 'selected' : ''}>WARNING</option>
					<option value="INFO" ${'INFO' == level ? 'selected' : ''}>INFO</option>
					<option value="CONFIG" ${'CONFIG' == level ? 'selected' : ''}>CONFIG</option>
					<option value="FINE" ${'FINE' == level ? 'selected' : ''}>FINE</option>
					<option value="FINER" ${'FINER' == level ? 'selected' : ''}>FINER</option>
					<option value="FINEST" ${'FINEST' == level ? 'selected' : ''}>FINEST</option>
				</select> <label for="loggerName">Logger Name:</label> <input type="text"
					size="50px" name="loggerName" id="loggerName"
					value="<%=request.getParameter("loggerName")%>">
				<button type="submit" class="">Refresh</button>
			</div>

		</form>
	<div>
		<hr/>
		<pre id="logoutput"></pre>
	</div>
</body>
</html>
