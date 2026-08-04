<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="New Booking" scope="request"/>
<c:set var="activeMenu" value="bookings" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Book one or more rooms for a customer.
    Check-in date must be within the next 5 days (including today). Full prepayment is required.
</p>

<c:if test="${not empty formError}">
    <div class="alert-error" role="alert">
        <c:out value="${formError}"/>
    </div>
</c:if>

<form class="form-panel" method="post" action="${ctx}/counter/bookings/new" style="max-width: none;">
    <input type="hidden" name="action" value="preview">

    <div class="form-grid">
        <div class="form-group">
            <label for="customerId">Customer</label>
            <select id="customerId" name="customerId" required>
                <option value="">Select customer</option>
                <c:forEach var="c" items="${customers}">
                    <option value="${c.id}"
                        ${enteredCustomerId == c.id ? 'selected' : ''}>
                        <c:out value="${c.name}"/> — <c:out value="${c.email}"/>
                    </option>
                </c:forEach>
            </select>
            <c:if test="${not empty errors.customerId}">
                <div class="field-error"><c:out value="${errors.customerId}"/></div>
            </c:if>
        </div>

        <div class="form-group">
            <label for="checkInDate">Check-in date</label>
            <input id="checkInDate"
                   type="date"
                   name="checkInDate"
                   min="${today}"
                   max="${maxCheckIn}"
                   value="${fn:escapeXml(enteredCheckIn)}"
                   required>
            <c:if test="${not empty errors.checkInDate}">
                <div class="field-error"><c:out value="${errors.checkInDate}"/></div>
            </c:if>
        </div>

        <div class="form-group">
            <label for="nights">Nights</label>
            <input id="nights"
                   type="number"
                   name="nights"
                   min="1"
                   max="30"
                   value="${fn:escapeXml(enteredNights)}"
                   required>
            <c:if test="${not empty errors.nights}">
                <div class="field-error"><c:out value="${errors.nights}"/></div>
            </c:if>
        </div>
    </div>

    <div class="form-group full-width" style="margin-top: 24px;">
        <label>Available rooms (select one or more)</label>
        <c:if test="${not empty errors.roomIds}">
            <div class="alert-error" style="margin-top: 8px;"><c:out value="${errors.roomIds}"/></div>
        </c:if>

        <div class="data-table-wrap" style="margin-top: 10px;">
            <table class="data-table">
                <thead>
                <tr>
                    <th>Select</th>
                    <th>Room</th>
                    <th>Floor</th>
                    <th>Type</th>
                    <th>Price / night</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty availableRooms}">
                        <tr>
                            <td colspan="5" class="empty-row">No rooms are currently available.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="room" items="${availableRooms}">
                            <c:set var="checked" value="false"/>
                            <c:forEach var="sid" items="${enteredRoomIds}">
                                <c:if test="${sid == room.id}">
                                    <c:set var="checked" value="true"/>
                                </c:if>
                            </c:forEach>
                            <tr>
                                <td>
                                    <input type="checkbox"
                                           name="roomIds"
                                           value="${room.id}"
                                           ${checked ? 'checked' : ''}
                                           aria-label="Select room ${room.roomNumber}">
                                </td>
                                <td><c:out value="${room.roomNumber}"/></td>
                                <td><c:out value="${room.floor}"/></td>
                                <td><c:out value="${room.roomType}"/></td>
                                <td>
                                    RM
                                    <fmt:formatNumber value="${room.currentPrice}"
                                                      minFractionDigits="2"
                                                      maxFractionDigits="2"/>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <div class="form-actions">
        <a class="btn-secondary" href="${ctx}/counter/bookings">Cancel</a>
        <button class="btn-primary" type="submit">Continue to payment</button>
    </div>
</form>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
