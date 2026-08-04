<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Payment Detail" scope="request"/>
<c:set var="activeMenu" value="${bookingRole == 'customer' ? 'book' : 'bookings'}" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Review booking details and complete full prepayment.
    Room prices below are snapshots for this order.
</p>

<section class="form-panel" style="max-width: none;">
    <h2 class="list-section-title" style="margin-bottom: 16px;">Booking summary</h2>

    <div class="form-grid">
        <div class="form-group">
            <label>Customer</label>
            <div><c:out value="${customer.name}"/> (<c:out value="${customer.email}"/>)</div>
        </div>
        <div class="form-group">
            <label>Check-in</label>
            <div><c:out value="${checkInDate}"/></div>
        </div>
        <div class="form-group">
            <label>Check-out</label>
            <div><c:out value="${checkOutDate}"/></div>
        </div>
        <div class="form-group">
            <label>Nights</label>
            <div><c:out value="${nights}"/></div>
        </div>
    </div>

    <div class="data-table-wrap" style="margin-top: 20px;">
        <table class="data-table">
            <thead>
            <tr>
                <th>Room</th>
                <th>Type</th>
                <th>Price / night</th>
                <th>Nights</th>
                <th>Line total</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="room" items="${selectedRooms}" varStatus="st">
                <tr>
                    <td><c:out value="${room.roomNumber}"/></td>
                    <td><c:out value="${room.roomType}"/></td>
                    <td>
                        RM
                        <fmt:formatNumber value="${room.currentPrice}"
                                          minFractionDigits="2"
                                          maxFractionDigits="2"/>
                    </td>
                    <td><c:out value="${nights}"/></td>
                    <td>
                        RM
                        <fmt:formatNumber value="${lineTotals[st.index]}"
                                          minFractionDigits="2"
                                          maxFractionDigits="2"/>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>

    <p style="margin-top: 18px; font-size: 18px; font-weight: 700;">
        Total payable:
        RM
        <fmt:formatNumber value="${grandTotal}" minFractionDigits="2" maxFractionDigits="2"/>
    </p>

    <form method="post" action="${payActionUrl}" style="margin-top: 20px;">
        <input type="hidden" name="action" value="pay">
        <input type="hidden" name="customerId" value="${customer.id}">
        <input type="hidden" name="checkInDate" value="${checkInDate}">
        <input type="hidden" name="nights" value="${nights}">
        <input type="hidden" name="roomIds" value="${roomIdsCsv}">

        <div class="form-grid">
            <div class="form-group">
                <label for="paymentMethod">Payment method</label>
                <select id="paymentMethod" name="paymentMethod" required>
                    <option value="CASH" ${paymentMethod == 'CASH' ? 'selected' : ''}>Cash</option>
                    <option value="CARD" ${paymentMethod == 'CARD' ? 'selected' : ''}>Card</option>
                    <option value="ONLINE" ${paymentMethod == 'ONLINE' ? 'selected' : ''}>Online transfer</option>
                </select>
            </div>
        </div>

        <div class="form-actions">
            <a class="btn-secondary" href="${cancelUrl}">Back</a>
            <button class="btn-primary" type="submit">Confirm &amp; pay full amount</button>
        </div>
    </form>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
