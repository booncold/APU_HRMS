<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Assign Cleaning" scope="request"/>
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

<section class="form-panel" style="max-width: none; margin-bottom: 28px;">
    <h2 class="list-section-title" style="margin-bottom: 12px;">New assignment</h2>
    <p class="field-hint" style="margin-bottom: 12px;">
        Each housekeeper may hold up to <c:out value="${maxOpenTasks}"/>
        open cleaning tasks at the same time.
    </p>

    <c:choose>
        <c:when test="${empty dirtyRooms}">
            <p class="field-hint">
                No rooms are currently waiting for a cleaning assignment.
            </p>
        </c:when>
        <c:when test="${empty housekeepers}">
            <p class="field-hint">
                There are rooms needing cleaning, but no active housekeepers are available.
            </p>
        </c:when>
        <c:when test="${empty availableHousekeepers}">
            <p class="field-hint">
                There are rooms needing cleaning, but every active housekeeper
                is currently at the <c:out value="${maxOpenTasks}"/>-task limit.
            </p>
            <p class="field-hint" style="margin-top: 8px;">
                Dirty rooms:
                <c:forEach var="r" items="${dirtyRooms}" varStatus="st">
                    <c:out value="${r.roomNumber}"/><c:if test="${!st.last}">, </c:if>
                </c:forEach>
            </p>
        </c:when>
        <c:otherwise>
            <form class="toolbar-form" method="post" action="${ctx}/counter/assign-cleaning">
                <select name="roomId" required aria-label="Room needing cleaning"
                        style="min-width: 160px; height: 44px; padding: 0 12px; border: 1px solid var(--border-colour); border-radius: var(--radius-md); background: #fff;">
                    <option value="">Select room</option>
                    <c:forEach var="r" items="${dirtyRooms}">
                        <option value="${r.id}">
                            <c:out value="${r.roomNumber}"/>
                            (Floor <c:out value="${r.floor}"/> · <c:out value="${r.roomType}"/>)
                        </option>
                    </c:forEach>
                </select>

                <select name="housekeeperId" required aria-label="Available housekeeper"
                        style="min-width: 280px; height: 44px; padding: 0 12px; border: 1px solid var(--border-colour); border-radius: var(--radius-md); background: #fff;">
                    <option value="">Select housekeeper</option>
                    <c:forEach var="hk" items="${availableHousekeepers}">
                        <c:set var="openCount" value="${housekeeperOpenTaskCounts[hk.id]}"/>
                        <option value="${hk.id}">
                            <c:out value="${hk.name}"/> —
                            <c:out value="${empty openCount ? 0 : openCount}"/>/<c:out value="${maxOpenTasks}"/>
                            open tasks
                        </option>
                    </c:forEach>
                </select>

                <input type="text"
                       name="notes"
                       placeholder="Notes (optional)"
                       maxlength="500"
                       style="min-width: 200px; height: 44px; padding: 0 12px; border: 1px solid var(--border-colour); border-radius: var(--radius-md);">

                <button class="btn-primary" type="submit">Assign</button>
            </form>
        </c:otherwise>
    </c:choose>
</section>

<section class="list-section" style="margin-bottom: 28px;">
    <div class="list-section-header">
        <h2 class="list-section-title">Housekeeper workload</h2>
        <span class="list-section-count">
            <c:out value="${fn:length(housekeepers)}"/> Active
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Housekeeper</th>
                <th>Current open tasks</th>
                <th>Assignment capacity</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty housekeepers}">
                    <tr>
                        <td colspan="3" class="empty-row">No active housekeepers found.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="hk" items="${housekeepers}">
                        <c:set var="openCount" value="${housekeeperOpenTaskCounts[hk.id]}"/>
                        <c:set var="displayOpenCount" value="${empty openCount ? 0 : openCount}"/>
                        <tr>
                            <td><c:out value="${hk.name}"/></td>
                            <td>
                                <c:out value="${displayOpenCount}"/>/<c:out value="${maxOpenTasks}"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${displayOpenCount >= maxOpenTasks}">
                                        Full
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${maxOpenTasks - displayOpenCount}"/> slot(s) available
                                    </c:otherwise>
                                </c:choose>
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
        <h2 class="list-section-title">Cleaning tasks</h2>
        <span class="list-section-count">
            <c:out value="${fn:length(taskList)}"/> Task(s)
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Room</th>
                <th>Housekeeper</th>
                <th>Assigned by</th>
                <th>Status</th>
                <th>Assigned at</th>
                <th>Completed at</th>
                <th>Notes</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty taskList}">
                    <tr>
                        <td colspan="7" class="empty-row">No cleaning tasks yet.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${taskList}">
                        <tr>
                            <td><c:out value="${t.room.roomNumber}"/></td>
                            <td><c:out value="${t.housekeeper.name}"/></td>
                            <td><c:out value="${t.assignedBy.name}"/></td>
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
