<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Counter Staff Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div class="counter-dashboard">
    <section class="counter-metric-grid" aria-label="Today counter operations">
        <a class="counter-metric-card metric-check-in" href="${ctx}/counter/check-in">
            <div class="counter-metric-top">
                <span class="counter-metric-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M4 12h10"></path>
                        <path d="m10 8 4 4-4 4"></path>
                        <path d="M14 5h5v14h-5"></path>
                    </svg>
                </span>
                <span class="counter-metric-date">Today</span>
            </div>
            <p class="counter-metric-label">Waiting check-in</p>
            <div class="counter-metric-value">
                <strong><c:out value="${empty todayCheckInCount ? 0 : todayCheckInCount}"/></strong>
                <span>rooms expected</span>
            </div>
            <span class="counter-metric-action">
                Open check-in queue <span aria-hidden="true">&#8594;</span>
            </span>
        </a>

        <a class="counter-metric-card metric-check-out" href="${ctx}/counter/check-out">
            <div class="counter-metric-top">
                <span class="counter-metric-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M10 12h10"></path>
                        <path d="m14 8-4 4 4 4"></path>
                        <path d="M10 5H5v14h5"></path>
                    </svg>
                </span>
                <span class="counter-metric-date">Today</span>
            </div>
            <p class="counter-metric-label">Scheduled check-out</p>
            <div class="counter-metric-value">
                <strong><c:out value="${empty todayCheckOutCount ? 0 : todayCheckOutCount}"/></strong>
                <span>rooms departing</span>
            </div>
            <span class="counter-metric-action">
                Open check-out queue <span aria-hidden="true">&#8594;</span>
            </span>
        </a>

        <a class="counter-metric-card metric-cleaning" href="${ctx}/counter/assign-cleaning">
            <div class="counter-metric-top">
                <span class="counter-metric-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="m14 4 6 6"></path>
                        <path d="m12 6 6 6"></path>
                        <path d="M5 19c3-1 5-3 7-7l2-2 4 4-2 2c-4 2-6 4-7 7"></path>
                        <path d="M5 19h4"></path>
                    </svg>
                </span>
                <span class="counter-metric-date">Live</span>
            </div>
            <p class="counter-metric-label">Cleaning assignment</p>
            <div class="counter-metric-value">
                <strong><c:out value="${empty unassignedCleaningCount ? 0 : unassignedCleaningCount}"/></strong>
                <span>rooms unassigned</span>
            </div>
            <span class="counter-metric-action">
                Assign housekeepers <span aria-hidden="true">&#8594;</span>
            </span>
        </a>
    </section>

    <section class="counter-booking-panel" aria-labelledby="current-bookings-title">
        <div class="counter-panel-header">
            <div>
                <p class="counter-panel-kicker">Bookings</p>
                <h2 id="current-bookings-title">Upcoming booking list</h2>
            </div>
            <div class="counter-panel-actions">
                <a class="btn-secondary" href="${ctx}/counter/bookings">View all bookings</a>
                <a class="btn-primary" href="${ctx}/counter/bookings/new">New booking</a>
            </div>
        </div>

        <div class="counter-booking-table-wrap">
            <table class="counter-booking-table">
                <thead>
                <tr>
                    <th>Order</th>
                    <th>Customer</th>
                    <th>Stay dates</th>
                    <th>Rooms</th>
                    <th>Total</th>
                    <th>Status</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty currentBookings}">
                        <tr>
                            <td class="counter-booking-empty" colspan="6">
                                There are no bookings scheduled for today or later.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="order" items="${currentBookings}">
                            <tr>
                                <td>
                                    <span class="booking-order-number">
                                        <c:out value="${order.orderNo}"/>
                                    </span>
                                </td>
                                <td>
                                    <strong class="booking-customer-name">
                                        <c:out value="${order.customer.name}"/>
                                    </strong>
                                </td>
                                <td>
                                    <div class="booking-stay-dates">
                                        <span><c:out value="${order.checkInDate}"/></span>
                                        <span aria-hidden="true">&#8594;</span>
                                        <span><c:out value="${order.checkOutDate}"/></span>
                                    </div>
                                </td>
                                <td>
                                    <div class="booking-room-list">
                                        <c:forEach var="room" items="${order.rooms}">
                                            <span><c:out value="${room.roomNumberSnapshot}"/></span>
                                        </c:forEach>
                                    </div>
                                </td>
                                <td class="booking-total">
                                    RM <fmt:formatNumber value="${order.totalAmount}"
                                                         minFractionDigits="2"
                                                         maxFractionDigits="2"/>
                                </td>
                                <td>
                                    <span class="booking-status" data-status="${order.status}">
                                        <c:out value="${order.status.displayName}"/>
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </section>
</div>

<style>
    .counter-dashboard {
        display: grid;
        gap: 22px;
    }

    .counter-metric-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 16px;
    }

    .counter-metric-card {
        min-width: 0;
        display: flex;
        flex-direction: column;
        padding: 20px;
        border: 1px solid var(--card-border);
        border-radius: 14px;
        background: #ffffff;
        color: var(--main-text);
        text-decoration: none;
        box-shadow: 0 8px 24px rgba(43, 36, 29, 0.045);
        transition: border-color 0.15s ease, box-shadow 0.15s ease, transform 0.15s ease;
    }

    .counter-metric-card:hover {
        border-color: var(--metric-colour);
        color: var(--main-text);
        box-shadow: 0 12px 28px rgba(43, 36, 29, 0.08);
        transform: translateY(-2px);
    }

    .metric-check-in {
        --metric-colour: #3f7650;
        --metric-soft: rgba(63, 118, 80, 0.13);
    }

    .metric-check-out {
        --metric-colour: #56738b;
        --metric-soft: rgba(86, 115, 139, 0.13);
    }

    .metric-cleaning {
        --metric-colour: var(--accent-hover);
        --metric-soft: rgba(168, 121, 61, 0.14);
    }

    .counter-metric-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 17px;
    }

    .counter-metric-icon {
        width: 42px;
        height: 42px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 11px;
        background: var(--metric-soft);
        color: var(--metric-colour);
    }

    .counter-metric-icon svg {
        width: 22px;
        height: 22px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .counter-metric-date {
        padding: 6px 9px;
        border-radius: 999px;
        background: var(--metric-soft);
        color: var(--metric-colour);
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 0.07em;
        text-transform: uppercase;
    }

    .counter-metric-label {
        margin: 0 0 7px;
        color: var(--label-text);
        font-size: 13px;
        font-weight: 700;
    }

    .counter-metric-value {
        display: flex;
        align-items: baseline;
        gap: 9px;
        margin-bottom: 19px;
    }

    .counter-metric-value strong {
        color: var(--main-text);
        font-size: 36px;
        line-height: 1;
    }

    .counter-metric-value span {
        color: var(--muted-text);
        font-size: 12px;
    }

    .counter-metric-action {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        margin-top: auto;
        padding-top: 14px;
        border-top: 1px solid #eee7dd;
        color: var(--metric-colour);
        font-size: 12px;
        font-weight: 700;
    }

    .counter-booking-panel {
        min-width: 0;
        padding: 20px;
        border: 1px solid var(--card-border);
        border-radius: 14px;
        background: #ffffff;
        box-shadow: 0 8px 24px rgba(43, 36, 29, 0.045);
    }

    .counter-panel-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        margin-bottom: 18px;
    }

    .counter-panel-kicker {
        margin: 0 0 5px;
        color: var(--accent-hover);
        font-size: 11px;
        font-weight: 800;
        letter-spacing: 0.1em;
        text-transform: uppercase;
    }

    .counter-panel-header h2 {
        margin: 0;
        color: var(--main-text);
        font-size: 21px;
    }

    .counter-panel-actions {
        display: flex;
        align-items: center;
        gap: 9px;
        flex: 0 0 auto;
    }

    .counter-booking-table-wrap {
        overflow-x: auto;
        border: 1px solid #e5dccf;
        border-radius: 11px;
    }

    .counter-booking-table {
        width: 100%;
        min-width: 900px;
        border-collapse: collapse;
        font-size: 13px;
    }

    .counter-booking-table th,
    .counter-booking-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #eee7dd;
        text-align: left;
        vertical-align: middle;
    }

    .counter-booking-table th {
        background: #f7f2ea;
        color: var(--label-text);
        font-size: 11px;
        font-weight: 800;
        letter-spacing: 0.055em;
        text-transform: uppercase;
        white-space: nowrap;
    }

    .counter-booking-table tbody tr:last-child td {
        border-bottom: 0;
    }

    .counter-booking-table tbody tr:hover td {
        background: #fdfaf6;
    }

    .booking-order-number {
        color: var(--accent-hover);
        font-weight: 700;
        white-space: nowrap;
    }

    .booking-customer-name,
    .booking-total {
        color: var(--main-text);
        font-weight: 700;
        white-space: nowrap;
    }

    .booking-stay-dates {
        display: flex;
        align-items: center;
        gap: 7px;
        color: var(--muted-text);
        white-space: nowrap;
    }

    .booking-stay-dates span[aria-hidden="true"] {
        color: var(--accent);
    }

    .booking-room-list {
        display: flex;
        flex-wrap: wrap;
        gap: 5px;
    }

    .booking-room-list span {
        padding: 4px 7px;
        border-radius: 6px;
        background: #f2ece3;
        color: var(--label-text);
        font-size: 11px;
        font-weight: 700;
    }

    .booking-status {
        display: inline-flex;
        align-items: center;
        min-height: 26px;
        padding: 4px 9px;
        border-radius: 999px;
        background: #eee8df;
        color: var(--label-text);
        font-size: 11px;
        font-weight: 800;
        white-space: nowrap;
    }

    .booking-status[data-status="CONFIRMED"] {
        background: #e8f3eb;
        color: #356743;
    }

    .booking-status[data-status="PENDING_PAYMENT"] {
        background: #fff3d8;
        color: #8a621e;
    }

    .booking-status[data-status="PARTIAL_CHECKED_IN"] {
        background: #e8f0f6;
        color: #49677f;
    }

    .booking-status[data-status="CHECKED_IN"] {
        background: #f2e9dc;
        color: #7a5427;
    }

    .counter-booking-empty {
        height: 110px;
        color: var(--muted-text);
        text-align: center !important;
    }

    @media (max-width: 980px) {
        .counter-metric-grid {
            grid-template-columns: 1fr;
        }

        .counter-panel-header {
            align-items: flex-start;
            flex-direction: column;
        }
    }

    @media (max-width: 620px) {
        .counter-panel-actions {
            width: 100%;
            flex-wrap: wrap;
        }

        .counter-panel-actions .btn-primary,
        .counter-panel-actions .btn-secondary {
            flex: 1 1 auto;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
