<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Rooms & Pricing" scope="request"/>
<c:set var="activeMenu" value="rooms" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Manage room inventory and current nightly rates.
    Price changes do not affect already booked orders (snapshot pricing).
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
    <form class="toolbar-form" method="get" action="${ctx}/manager/rooms">
        <select name="type" aria-label="Filter by room type">
            <option value="">All types</option>
            <c:forEach var="type" items="${roomTypes}">
                <option value="${type}" ${filterType == type.name() ? 'selected' : ''}>
                    <c:out value="${type}"/>
                </option>
            </c:forEach>
        </select>

        <select name="floor" aria-label="Filter by floor">
            <option value="">All floors</option>
            <c:forEach var="f" begin="1" end="5">
                <option value="${f}" ${filterFloor == f ? 'selected' : ''}>
                    Floor <c:out value="${f}"/>
                </option>
            </c:forEach>
        </select>

        <select name="status" aria-label="Filter by status">
            <option value="">All statuses</option>
            <c:forEach var="st" items="${roomStatuses}">
                <option value="${st}" ${filterStatus == st.name() ? 'selected' : ''}>
                    <c:out value="${st}"/>
                </option>
            </c:forEach>
        </select>

        <button class="btn-secondary" type="submit">Filter</button>
        <a class="btn-secondary" href="${ctx}/manager/rooms">Reset</a>
    </form>
</div>

<section class="form-panel" style="margin-bottom: 24px; max-width: none;">
    <h2 class="list-section-title" style="margin-bottom: 12px;">Bulk price by type</h2>
    <p class="field-hint" style="margin-bottom: 14px;">
        Applies the new current price to every room of that type. Existing bookings keep their snapshot prices.
    </p>
    <form class="toolbar-form" method="post" action="${ctx}/manager/rooms/price">
        <input type="hidden" name="mode" value="type">
        <select name="roomType" required aria-label="Room type for bulk price">
            <c:forEach var="type" items="${roomTypes}">
                <option value="${type}"><c:out value="${type}"/></option>
            </c:forEach>
        </select>
        <input type="number"
               name="price"
               min="1"
               step="0.01"
               placeholder="New price (RM)"
               required
               style="min-width: 160px; height: 44px; padding: 0 12px; border: 1px solid var(--border-colour); border-radius: var(--radius-md);">
        <button class="btn-primary" type="submit">Update type price</button>
    </form>
</section>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No rooms match &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div class="toolbar" style="margin-bottom: 12px;">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               placeholder="Search room number, type, status"
               autocomplete="off"
               aria-label="Search rooms">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
    <span class="list-section-count"><c:out value="${totalRoomCount}"/> room(s) shown</span>
</div>

<div data-live-root>

<%-- STANDARD --%>
<section class="list-section" data-live-section>
    <div class="list-section-header">
        <h2 class="list-section-title">Standard</h2>
        <span class="list-section-count" data-live-count data-label="Rooms">
            <c:out value="${fn:length(standardRooms)}"/> Rooms
        </span>
    </div>
    <div class="data-table-wrap">
        <table class="data-table room-table">
            <colgroup>
                <col class="col-room">
                <col class="col-floor">
                <col class="col-status">
                <col class="col-timeline">
                <col class="col-price">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Status</th>
                <th>Active booking</th>
                <th>Price / night</th>
                <th>Update price</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty standardRooms}">
                    <tr><td colspan="6" class="empty-row">No standard rooms match filters.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="room" items="${standardRooms}">
                        <tr class="live-search-row">
                            <td><c:out value="${room.roomNumber}"/></td>
                            <td><c:out value="${room.floor}"/></td>
                            <td><c:out value="${room.status}"/></td>
                            <c:set var="activeBooking" value="${activeRoomBookings[room.id]}"/>
                            <td>
                                <c:choose>
                                    <c:when test="${empty activeBooking}">
                                        <span class="field-hint">No active booking</span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${activeBooking.order.checkInDate}"/>
                                        to
                                        <c:out value="${activeBooking.order.checkOutDate}"/>
                                        <br>
                                        <span class="field-hint">
                                            Booked rate:
                                            RM
                                            <fmt:formatNumber value="${activeBooking.pricePerNightSnapshot}"
                                                              minFractionDigits="2"
                                                              maxFractionDigits="2"/>
                                            / night
                                        </span>
                                        <br>
                                        <span class="field-hint">
                                            Booking total:
                                            RM
                                            <fmt:formatNumber value="${activeBooking.lineTotal}"
                                                              minFractionDigits="2"
                                                              maxFractionDigits="2"/>
                                        </span>
                                        <br>
                                        <span class="field-hint">
                                            <c:out value="${activeBooking.order.customer.name}"/>
                                            -
                                            <c:out value="${activeBooking.order.orderNo}"/>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>RM <fmt:formatNumber value="${room.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <form method="post" action="${ctx}/manager/rooms/price" class="inline-price-form">
                                        <input type="hidden" name="mode" value="single">
                                        <input type="hidden" name="roomId" value="${room.id}">
                                        <input type="number"
                                               name="price"
                                               min="1"
                                               step="0.01"
                                               value="${room.currentPrice}"
                                               required
                                               aria-label="New price for room ${room.roomNumber}">
                                        <button class="btn-secondary" type="submit">Save</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr class="live-search-empty empty-row" hidden>
                        <td colspan="6">No matching standard rooms.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<%-- VIP --%>
<section class="list-section" data-live-section>
    <div class="list-section-header">
        <h2 class="list-section-title">VIP</h2>
        <span class="list-section-count" data-live-count data-label="Rooms">
            <c:out value="${fn:length(vipRooms)}"/> Rooms
        </span>
    </div>
    <div class="data-table-wrap">
        <table class="data-table room-table">
            <colgroup>
                <col class="col-room">
                <col class="col-floor">
                <col class="col-status">
                <col class="col-timeline">
                <col class="col-price">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Status</th>
                <th>Active booking</th>
                <th>Price / night</th>
                <th>Update price</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty vipRooms}">
                    <tr><td colspan="6" class="empty-row">No VIP rooms match filters.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="room" items="${vipRooms}">
                        <tr class="live-search-row">
                            <td><c:out value="${room.roomNumber}"/></td>
                            <td><c:out value="${room.floor}"/></td>
                            <td><c:out value="${room.status}"/></td>
                            <c:set var="activeBooking" value="${activeRoomBookings[room.id]}"/>
                            <td>
                                <c:choose>
                                    <c:when test="${empty activeBooking}">
                                        <span class="field-hint">No active booking</span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${activeBooking.order.checkInDate}"/>
                                        to
                                        <c:out value="${activeBooking.order.checkOutDate}"/>
                                        <br>
                                        <span class="field-hint">
                                            Booked rate:
                                            RM
                                            <fmt:formatNumber value="${activeBooking.pricePerNightSnapshot}"
                                                              minFractionDigits="2"
                                                              maxFractionDigits="2"/>
                                            / night
                                        </span>
                                        <br>
                                        <span class="field-hint">
                                            Booking total:
                                            RM
                                            <fmt:formatNumber value="${activeBooking.lineTotal}"
                                                              minFractionDigits="2"
                                                              maxFractionDigits="2"/>
                                        </span>
                                        <br>
                                        <span class="field-hint">
                                            <c:out value="${activeBooking.order.customer.name}"/>
                                            -
                                            <c:out value="${activeBooking.order.orderNo}"/>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>RM <fmt:formatNumber value="${room.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <form method="post" action="${ctx}/manager/rooms/price" class="inline-price-form">
                                        <input type="hidden" name="mode" value="single">
                                        <input type="hidden" name="roomId" value="${room.id}">
                                        <input type="number"
                                               name="price"
                                               min="1"
                                               step="0.01"
                                               value="${room.currentPrice}"
                                               required
                                               aria-label="New price for room ${room.roomNumber}">
                                        <button class="btn-secondary" type="submit">Save</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr class="live-search-empty empty-row" hidden>
                        <td colspan="6">No matching VIP rooms.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<%-- PRESIDENTIAL --%>
<section class="list-section" data-live-section>
    <div class="list-section-header">
        <h2 class="list-section-title">Presidential</h2>
        <span class="list-section-count" data-live-count data-label="Rooms">
            <c:out value="${fn:length(presidentialRooms)}"/> Rooms
        </span>
    </div>
    <div class="data-table-wrap">
        <table class="data-table room-table">
            <colgroup>
                <col class="col-room">
                <col class="col-floor">
                <col class="col-status">
                <col class="col-timeline">
                <col class="col-price">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Status</th>
                <th>Active booking</th>
                <th>Price / night</th>
                <th>Update price</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty presidentialRooms}">
                    <tr><td colspan="6" class="empty-row">No presidential rooms match filters.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="room" items="${presidentialRooms}">
                        <tr class="live-search-row">
                            <td><c:out value="${room.roomNumber}"/></td>
                            <td><c:out value="${room.floor}"/></td>
                            <td><c:out value="${room.status}"/></td>
                            <c:set var="activeBooking" value="${activeRoomBookings[room.id]}"/>
                            <td>
                                <c:choose>
                                    <c:when test="${empty activeBooking}">
                                        <span class="field-hint">No active booking</span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${activeBooking.order.checkInDate}"/>
                                        to
                                        <c:out value="${activeBooking.order.checkOutDate}"/>
                                        <br>
                                        <span class="field-hint">
                                            Booked rate:
                                            RM
                                            <fmt:formatNumber value="${activeBooking.pricePerNightSnapshot}"
                                                              minFractionDigits="2"
                                                              maxFractionDigits="2"/>
                                            / night
                                        </span>
                                        <br>
                                        <span class="field-hint">
                                            Booking total:
                                            RM
                                            <fmt:formatNumber value="${activeBooking.lineTotal}"
                                                              minFractionDigits="2"
                                                              maxFractionDigits="2"/>
                                        </span>
                                        <br>
                                        <span class="field-hint">
                                            <c:out value="${activeBooking.order.customer.name}"/>
                                            -
                                            <c:out value="${activeBooking.order.orderNo}"/>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>RM <fmt:formatNumber value="${room.currentPrice}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td class="actions">
                                <div class="actions-inner">
                                    <form method="post" action="${ctx}/manager/rooms/price" class="inline-price-form">
                                        <input type="hidden" name="mode" value="single">
                                        <input type="hidden" name="roomId" value="${room.id}">
                                        <input type="number"
                                               name="price"
                                               min="1"
                                               step="0.01"
                                               value="${room.currentPrice}"
                                               required
                                               aria-label="New price for room ${room.roomNumber}">
                                        <button class="btn-secondary" type="submit">Save</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr class="live-search-empty empty-row" hidden>
                        <td colspan="6">No matching presidential rooms.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

</div>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
