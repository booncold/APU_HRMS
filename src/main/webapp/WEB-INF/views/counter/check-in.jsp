<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Check-in" scope="request"/>
<c:set var="activeMenu" value="check-in" scope="request"/>
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

<div class="toolbar" style="margin-bottom: 12px;">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               placeholder="Search room, order, customer"
               autocomplete="off"
               aria-label="Search check-ins">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
    <span class="list-section-count">
        <c:out value="${fn:length(checkInList)}"/> Room(s)
    </span>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No check-ins match &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Room</th>
            <th>Type</th>
            <th>Order</th>
            <th>Customer</th>
            <th>Check-in date</th>
            <th>Nights</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty checkInList}">
                <tr>
                    <td colspan="7" class="empty-row">No rooms are due for check-in yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="line" items="${checkInList}">
                    <tr class="live-search-row">
                        <td><c:out value="${line.roomNumberSnapshot}"/></td>
                        <td><c:out value="${line.roomTypeSnapshot}"/></td>
                        <td><c:out value="${line.order.orderNo}"/></td>
                        <td><c:out value="${line.order.customer.name}"/></td>
                        <td>
                            <div class="check-in-date-cell">
                                <span><c:out value="${line.order.checkInDate}"/></span>
                                <c:if test="${line.order.checkInDate lt today}">
                                    <span class="overdue-badge">Overdue</span>
                                </c:if>
                            </div>
                        </td>
                        <td><c:out value="${line.nights}"/></td>
                        <td class="actions">
                            <div class="actions-inner">
                                <form method="post" action="${ctx}/counter/check-in"
                                      onsubmit="return confirm('Check in room ${line.roomNumberSnapshot}?');">
                                    <input type="hidden" name="bookingRoomId" value="${line.id}">
                                    <button class="btn-primary" type="submit"
                                            style="min-height:32px; height:32px; padding:0 12px; font-size:13px;">
                                        Check-in
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="7">No matching check-ins.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<style>
    .check-in-date-cell {
        display: flex;
        align-items: center;
        gap: 8px;
        white-space: nowrap;
    }

    .overdue-badge {
        display: inline-flex;
        align-items: center;
        min-height: 23px;
        padding: 0 8px;
        border-radius: 999px;
        background: #fbe9e7;
        color: #a33d35;
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 0.05em;
        text-transform: uppercase;
    }
</style>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
