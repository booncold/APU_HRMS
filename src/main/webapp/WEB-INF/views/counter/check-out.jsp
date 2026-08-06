<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Check-out" scope="request"/>
<c:set var="activeMenu" value="check-out" scope="request"/>
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
               aria-label="Search stays">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
    <span class="list-section-count">
        <c:out value="${fn:length(stayList)}"/> Stay(s)
    </span>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No stays match &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Room</th>
            <th>Type</th>
            <th>Order</th>
            <th>Customer</th>
            <th>Check-out date</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty stayList}">
                <tr>
                    <td colspan="6" class="empty-row">No stays are due for check-out yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="line" items="${stayList}">
                    <tr class="live-search-row">
                        <td><c:out value="${line.roomNumberSnapshot}"/></td>
                        <td><c:out value="${line.roomTypeSnapshot}"/></td>
                        <td><c:out value="${line.order.orderNo}"/></td>
                        <td><c:out value="${line.order.customer.name}"/></td>
                        <td><c:out value="${line.order.checkOutDate}"/></td>
                        <td class="actions">
                            <div class="actions-inner">
                                <form method="post" action="${ctx}/counter/check-out"
                                      onsubmit="return confirm('Check out room ${line.roomNumberSnapshot}?');">
                                    <input type="hidden" name="bookingRoomId" value="${line.id}">
                                    <button class="btn-primary" type="submit"
                                            style="min-height:32px; height:32px; padding:0 12px; font-size:13px;">
                                        Check-out
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="6">No matching stays.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
