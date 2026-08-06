<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Housekeeper Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<section class="action-list" aria-label="Housekeeper actions">
    <article class="action-card">
        <h2>
            <a href="${ctx}/housekeeper/tasks">My Tasks</a>
        </h2>
        <p>See open assignments and complete cleaning to free the room.</p>
    </article>

    <article class="action-card">
        <h2>
            <a href="${ctx}/housekeeper/feedback">Write Feedback</a>
        </h2>
        <p>Submit feedback linked to a specific room for managers to review.</p>
    </article>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
