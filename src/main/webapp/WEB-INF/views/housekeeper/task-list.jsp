<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="My Tasks" scope="request"/>
<c:set var="activeMenu" value="tasks" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<c:if test="${not empty successMessage}">
    <div class="status-message" role="status">
        <c:out value="${successMessage}"/>
    </div>
</c:if>

<c:if test="${not empty errorMessage}">
    <div class="alert-error" role="alert">
        <c:out value="${errorMessage}"/>
    </div>
</c:if>

<section class="list-section">
    <div class="list-section-header">
        <h2 class="list-section-title">Open tasks</h2>
        <span class="list-section-count">
            <c:out value="${fn:length(openTasks)}"/> Task(s)
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Type</th>
                <th>Assigned at</th>
                <th>Notes</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty openTasks}">
                    <tr>
                        <td colspan="6" class="empty-row">No open tasks. You are free for new assignments.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${openTasks}">
                        <tr>
                            <td><c:out value="${t.room.roomNumber}"/></td>
                            <td><c:out value="${t.room.floor}"/></td>
                            <td><c:out value="${t.room.roomType}"/></td>
                            <td><c:out value="${t.assignedAtDisplay}"/></td>
                            <td><c:out value="${empty t.notes ? '—' : t.notes}"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <form method="post" action="${ctx}/housekeeper/tasks"
                                          onsubmit="return confirm('Mark room ${t.room.roomNumber} as cleaned?');">
                                        <input type="hidden" name="taskId" value="${t.id}">
                                        <button class="btn-primary" type="submit"
                                                style="min-height:32px; height:32px; padding:0 12px; font-size:13px;">
                                            Complete
                                        </button>
                                    </form>
                                    <a class="btn-link"
                                       href="${ctx}/housekeeper/feedback?roomId=${t.room.id}">
                                        Feedback
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<section class="list-section">
    <div class="list-section-header">
        <h2 class="list-section-title">Task history</h2>
        <span class="list-section-count">
            <c:out value="${fn:length(allTasks)}"/> Task(s)
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Room</th>
                <th>Status</th>
                <th>Assigned at</th>
                <th>Completed at</th>
                <th>Notes</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty allTasks}">
                    <tr>
                        <td colspan="5" class="empty-row">No tasks assigned yet.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${allTasks}">
                        <tr>
                            <td><c:out value="${t.room.roomNumber}"/></td>
                            <td><c:out value="${t.status}"/></td>
                            <td><c:out value="${t.assignedAtDisplay}"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${empty t.completedAtDisplay}">—</c:when>
                                    <c:otherwise><c:out value="${t.completedAtDisplay}"/></c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${empty t.notes ? '—' : t.notes}"/></td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
