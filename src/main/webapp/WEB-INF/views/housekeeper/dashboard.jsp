<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Housekeeper Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    View assigned cleaning tasks, mark them complete, and submit room feedback from My Tasks.
</p>

<section class="action-list" aria-label="Housekeeper actions">
    <article class="action-card">
        <h2>
            <a href="${ctx}/housekeeper/tasks">My Tasks</a>
        </h2>
        <p>See open assignments, complete cleaning, and submit feedback for ongoing or completed tasks.</p>
    </article>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
