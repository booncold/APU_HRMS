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
          href="${pageContext.request.contextPath}/assets/css/theme.css?v=20260806-1">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/layout.css?v=20260806-3">
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
                <svg class="app-topbar-clock-icon" aria-hidden="true" viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="8.5"></circle>
                    <path d="M12 7.5V12l3 2"></path>
                </svg>
                <time id="app-current-datetime" aria-label="Current date and time">
                    -- --- ---- &middot; --:--:--
                </time>
            </div>
        </header>

        <main class="app-content">
