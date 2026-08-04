<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:out value="${empty pageTitle ? 'APU Hotel' : pageTitle}"/>
        | APU Hotel
    </title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/layout.css">
</head>
<body>

<div class="app-shell">

    <jsp:include page="/WEB-INF/views/common/sidebar.jsp"/>

    <div class="app-main">
        <header class="app-topbar">
            <div class="app-topbar-title">
                <c:out value="${empty pageTitle ? 'APU Hotel' : pageTitle}"/>
            </div>
            <div class="app-topbar-meta">
                <c:out value="${sessionScope.loggedInUserName}"/>
            </div>
        </header>

        <main class="app-content">
