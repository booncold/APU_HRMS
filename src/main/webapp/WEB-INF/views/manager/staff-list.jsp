<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Manage Staff" scope="request"/>
<c:set var="activeMenu" value="staff" scope="request"/>

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

<div class="toolbar">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               name="q"
               placeholder="Search name, email, IC, phone"
               autocomplete="off"
               aria-label="Search staff">
        <button class="btn-secondary live-search-reset" type="button">
            Reset
        </button>
    </form>

    <a class="btn-primary"
       href="${pageContext.request.contextPath}/manager/staff/new">
        Add Staff
    </a>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No staff found for &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root>

<%-- Managers --%>
<section class="list-section" data-live-section>
    <div class="list-section-header">
        <h2 class="list-section-title">Managers</h2>
        <span class="list-section-count" data-live-count data-label="Staff">
            <c:out value="${fn:length(managers)}"/> Staff
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table staff-table">
            <colgroup>
                <col class="col-name">
                <col class="col-email">
                <col class="col-phone">
                <col class="col-ic">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>IC</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty managers}">
                    <tr>
                        <td colspan="5" class="empty-row">No managers found.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="staff" items="${managers}">
                        <tr class="live-search-row">
                            <td>
                                <c:out value="${staff.name}"/>
                                <c:if test="${staff.seedAdmin}">
                                    <span class="badge">Seed</span>
                                </c:if>
                            </td>
                            <td><c:out value="${staff.email}"/></td>
                            <td>
                                <c:set var="p" value="${staff.phone}"/>
                                <c:choose>
                                    <c:when test="${fn:startsWith(p, '+60') && fn:length(p) > 3}">
                                        +60 <c:out value="${fn:substring(p, 3, fn:length(p))}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${p}"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${staff.ic}"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <c:if test="${canEditMap[staff.id]}">
                                        <a class="btn-link"
                                           href="${pageContext.request.contextPath}/manager/staff/edit?id=${staff.id}">
                                            Edit
                                        </a>
                                    </c:if>
                                    <c:if test="${canDeleteMap[staff.id]}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/manager/staff/delete"
                                              onsubmit="return confirm('Delete this staff account?');">
                                            <input type="hidden" name="id" value="${staff.id}">
                                            <button class="btn-danger" type="submit">Delete</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${not canEditMap[staff.id] and not canDeleteMap[staff.id]}">
                                        <span class="field-hint">No actions</span>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr class="live-search-empty empty-row" hidden>
                        <td colspan="5">No matching managers.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<%-- Counter Staff --%>
<section class="list-section" data-live-section>
    <div class="list-section-header">
        <h2 class="list-section-title">Counter Staff</h2>
        <span class="list-section-count" data-live-count data-label="Staff">
            <c:out value="${fn:length(counterStaff)}"/> Staff
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table staff-table">
            <colgroup>
                <col class="col-name">
                <col class="col-email">
                <col class="col-phone">
                <col class="col-ic">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>IC</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty counterStaff}">
                    <tr>
                        <td colspan="5" class="empty-row">No counter staff found.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="staff" items="${counterStaff}">
                        <tr class="live-search-row">
                            <td><c:out value="${staff.name}"/></td>
                            <td><c:out value="${staff.email}"/></td>
                            <td>
                                <c:set var="p" value="${staff.phone}"/>
                                <c:choose>
                                    <c:when test="${fn:startsWith(p, '+60') && fn:length(p) > 3}">
                                        +60 <c:out value="${fn:substring(p, 3, fn:length(p))}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${p}"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${staff.ic}"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <c:if test="${canEditMap[staff.id]}">
                                        <a class="btn-link"
                                           href="${pageContext.request.contextPath}/manager/staff/edit?id=${staff.id}">
                                            Edit
                                        </a>
                                    </c:if>
                                    <c:if test="${canDeleteMap[staff.id]}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/manager/staff/delete"
                                              onsubmit="return confirm('Delete this staff account?');">
                                            <input type="hidden" name="id" value="${staff.id}">
                                            <button class="btn-danger" type="submit">Delete</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${not canEditMap[staff.id] and not canDeleteMap[staff.id]}">
                                        <span class="field-hint">No actions</span>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr class="live-search-empty empty-row" hidden>
                        <td colspan="5">No matching counter staff.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<%-- Housekeepers --%>
<section class="list-section" data-live-section>
    <div class="list-section-header">
        <h2 class="list-section-title">Housekeepers</h2>
        <span class="list-section-count" data-live-count data-label="Staff">
            <c:out value="${fn:length(housekeepers)}"/> Staff
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table staff-table">
            <colgroup>
                <col class="col-name">
                <col class="col-email">
                <col class="col-phone">
                <col class="col-ic">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>IC</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty housekeepers}">
                    <tr>
                        <td colspan="5" class="empty-row">No housekeepers found.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="staff" items="${housekeepers}">
                        <tr class="live-search-row">
                            <td><c:out value="${staff.name}"/></td>
                            <td><c:out value="${staff.email}"/></td>
                            <td>
                                <c:set var="p" value="${staff.phone}"/>
                                <c:choose>
                                    <c:when test="${fn:startsWith(p, '+60') && fn:length(p) > 3}">
                                        +60 <c:out value="${fn:substring(p, 3, fn:length(p))}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${p}"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${staff.ic}"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <c:if test="${canEditMap[staff.id]}">
                                        <a class="btn-link"
                                           href="${pageContext.request.contextPath}/manager/staff/edit?id=${staff.id}">
                                            Edit
                                        </a>
                                    </c:if>
                                    <c:if test="${canDeleteMap[staff.id]}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/manager/staff/delete"
                                              onsubmit="return confirm('Delete this staff account?');">
                                            <input type="hidden" name="id" value="${staff.id}">
                                            <button class="btn-danger" type="submit">Delete</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${not canEditMap[staff.id] and not canDeleteMap[staff.id]}">
                                        <span class="field-hint">No actions</span>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr class="live-search-empty empty-row" hidden>
                        <td colspan="5">No matching housekeepers.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

</div>

<script src="${pageContext.request.contextPath}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
