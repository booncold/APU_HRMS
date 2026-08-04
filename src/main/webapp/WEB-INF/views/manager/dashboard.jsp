<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Manager Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Staff management, room pricing, feedback review, comments, and reports.
</p>

<section class="action-list" aria-label="Manager actions">
    <article class="action-card">
        <h2><a href="${ctx}/manager/staff/new">Add Staff</a></h2>
        <p>Create Manager, Counter Staff, and Housekeeper accounts.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/manager/staff">Manage Staff</a></h2>
        <p>Search, update, and delete staff records.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/manager/rooms">Rooms &amp; Pricing</a></h2>
        <p>Filter rooms and update current nightly rates (snapshot-safe).</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/manager/feedbacks">Feedbacks</a></h2>
        <p>Review housekeeper room feedbacks.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/manager/comments">Comments</a></h2>
        <p>Review customer booking comments and staff mentions.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/manager/reports">Reports</a></h2>
        <p>Five charts: occupancy, revenue, status, HK tasks, engagement.</p>
    </article>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
