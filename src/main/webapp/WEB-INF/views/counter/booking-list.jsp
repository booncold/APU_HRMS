<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Bookings" scope="request"/>
<c:set var="activeMenu" value="bookings" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    View bookings created at the counter or by customers.
    Create a new booking with full prepayment.
</p>

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
               placeholder="Search order no, customer, status"
               autocomplete="off"
               aria-label="Search bookings">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
    <a class="btn-primary" href="${ctx}/counter/bookings/new">New Booking</a>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No bookings match &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Order</th>
            <th>Customer</th>
            <th>Check-in</th>
            <th>Nights</th>
            <th>Rooms</th>
            <th>Total</th>
            <th>Status</th>
            <th>Receipt</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty bookingList}">
                <tr>
                    <td colspan="8" class="empty-row">No bookings yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="order" items="${bookingList}">
                    <tr class="live-search-row">
                        <td><c:out value="${order.orderNo}"/></td>
                        <td><c:out value="${order.customer.name}"/></td>
                        <td><c:out value="${order.checkInDate}"/></td>
                        <td><c:out value="${order.nights}"/></td>
                        <td>
                            <c:forEach var="br" items="${order.rooms}" varStatus="st">
                                <c:out value="${br.roomNumberSnapshot}"/><c:if test="${!st.last}">, </c:if>
                            </c:forEach>
                        </td>
                        <td>
                            RM
                            <fmt:formatNumber value="${order.totalAmount}"
                                              minFractionDigits="2"
                                              maxFractionDigits="2"/>
                        </td>
                        <td><c:out value="${order.status}"/></td>
                        <td class="actions">
                            <div class="actions-inner">
                                <c:if test="${not empty order.payment and not empty order.payment.receiptNo}">
                                    <a class="btn-link"
                                       href="${ctx}/counter/receipts/view?orderId=${order.id}">
                                        View
                                    </a>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="8">No matching bookings.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
