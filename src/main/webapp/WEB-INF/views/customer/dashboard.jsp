<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Customer Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div class="customer-dashboard">
    <section class="customer-booking-panel" aria-labelledby="customer-bookings-title">
        <div class="customer-panel-header">
            <div>
                <p class="customer-panel-kicker">My stays</p>
                <h2 id="customer-bookings-title">Booking records</h2>
            </div>
            <div class="customer-panel-header-actions">
                <span class="customer-booking-count">
                    <strong><c:out value="${totalBookingCount}"/></strong>
                    <span>total bookings</span>
                </span>
                <a class="btn-secondary" href="${ctx}/customer/bookings">View all</a>
            </div>
        </div>

        <div class="customer-booking-grid">
            <c:choose>
                <c:when test="${empty dashboardBookings}">
                    <div class="customer-booking-empty">
                        <span class="customer-empty-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24">
                                <path d="M4 19V8"></path>
                                <path d="M20 19V8"></path>
                                <path d="M4 14h16"></path>
                                <path d="M7 14v-3h4a3 3 0 0 1 3 3"></path>
                                <path d="M3 19h18"></path>
                            </svg>
                        </span>
                        <div>
                            <strong>No bookings yet</strong>
                            <span>Your confirmed stays will appear here.</span>
                        </div>
                        <a class="btn-primary" href="${ctx}/customer/book">Book your first stay</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="booking" items="${dashboardBookings}">
                        <article class="customer-booking-card">
                            <div class="booking-card-top">
                                <div>
                                    <span class="booking-order-label">Order</span>
                                    <strong class="booking-order-number">
                                        <c:out value="${booking.orderNo}"/>
                                    </strong>
                                </div>
                                <span class="customer-status-pill" data-status="${booking.status}">
                                    <c:out value="${booking.status.displayName}"/>
                                </span>
                            </div>

                            <div class="booking-stay-route">
                                <div>
                                    <span>Check-in</span>
                                    <strong><c:out value="${booking.checkInDate}"/></strong>
                                </div>
                                <div>
                                    <span>Check-out</span>
                                    <strong><c:out value="${booking.checkOutDate}"/></strong>
                                </div>
                            </div>

                            <div class="booking-room-row">
                                <span class="booking-room-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M4 19V8"></path>
                                        <path d="M20 19V8"></path>
                                        <path d="M4 14h16"></path>
                                        <path d="M7 14v-3h4a3 3 0 0 1 3 3"></path>
                                        <path d="M3 19h18"></path>
                                    </svg>
                                </span>
                                <div class="booking-room-details">
                                    <span>Room<c:if test="${fn:length(booking.rooms) > 1}">s</c:if></span>
                                    <div>
                                        <c:forEach var="room" items="${booking.rooms}">
                                            <i><c:out value="${room.roomNumberSnapshot}"/></i>
                                        </c:forEach>
                                    </div>
                                </div>
                                <span class="booking-night-count">
                                    <strong><c:out value="${booking.nights}"/></strong>
                                    night<c:if test="${booking.nights != 1}">s</c:if>
                                </span>
                            </div>

                            <div class="booking-card-footer">
                                <div class="booking-total">
                                    <span>Total paid</span>
                                    <strong>
                                        RM <fmt:formatNumber value="${booking.totalAmount}"
                                                             minFractionDigits="2"
                                                             maxFractionDigits="2"/>
                                    </strong>
                                </div>
                                <div class="booking-card-actions">
                                    <c:if test="${not empty booking.payment and not empty booking.payment.receiptNo}">
                                        <a href="${ctx}/customer/receipts/view?orderId=${booking.id}">Receipt</a>
                                    </c:if>
                                    <a href="${ctx}/customer/comments?orderId=${booking.id}">Comment</a>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <section class="stay-planner" aria-labelledby="stay-planner-title">
        <div class="stay-planner-backdrop" aria-hidden="true">
            <span class="planner-orb planner-orb-one"></span>
            <span class="planner-orb planner-orb-two"></span>
            <span class="planner-line-art"></span>
        </div>

        <div class="stay-planner-content">
            <div class="stay-planner-heading">
                <div>
                    <p>APU Hotel reservations</p>
                    <h2 id="stay-planner-title">Plan your next stay</h2>
                </div>
                <span class="planner-member-badge">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="m12 3 2.2 4.5 5 .7-3.6 3.5.9 5-4.5-2.4-4.5 2.4.9-5-3.6-3.5 5-.7L12 3Z"></path>
                    </svg>
                    Direct booking
                </span>
            </div>

            <div class="planner-feature-row" aria-label="Booking benefits">
                <span class="planner-feature is-active">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M4 19V8"></path>
                        <path d="M20 19V8"></path>
                        <path d="M4 14h16"></path>
                        <path d="M7 14v-3h4a3 3 0 0 1 3 3"></path>
                        <path d="M3 19h18"></path>
                    </svg>
                    Hotel stay
                </span>
                <span class="planner-feature">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                        <path d="M16 3v4"></path>
                        <path d="M8 3v4"></path>
                        <path d="M3 10h18"></path>
                    </svg>
                    Flexible dates
                </span>
                <span class="planner-feature">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"></path>
                        <path d="m9 12 2 2 4-5"></path>
                    </svg>
                    Secure payment
                </span>
                <span class="planner-feature">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M6 2h12v20l-3-2-3 2-3-2-3 2V2Z"></path>
                        <path d="M9 7h6"></path>
                        <path d="M9 11h6"></path>
                    </svg>
                    Instant receipt
                </span>
            </div>

            <form class="stay-search-bar" method="get" action="${ctx}/customer/book">
                <div class="stay-search-field location-field">
                    <span class="stay-search-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z"></path>
                            <circle cx="12" cy="10" r="2.5"></circle>
                        </svg>
                    </span>
                    <div>
                        <label>Destination</label>
                        <strong>APU Hotel, Kuala Lumpur</strong>
                    </div>
                </div>

                <label class="stay-search-field date-field" for="dashboardCheckIn">
                    <span class="stay-search-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                            <path d="M16 3v4"></path>
                            <path d="M8 3v4"></path>
                            <path d="M3 10h18"></path>
                        </svg>
                    </span>
                    <div>
                        <span>Check-in date</span>
                        <input id="dashboardCheckIn"
                               type="date"
                               name="checkInDate"
                               min="${today}"
                               max="${maxCheckIn}"
                               value="${today}"
                               required>
                    </div>
                </label>

                <label class="stay-search-field nights-field" for="dashboardNights">
                    <span class="stay-search-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M20 15.5A8 8 0 0 1 8.5 4 8.5 8.5 0 1 0 20 15.5Z"></path>
                        </svg>
                    </span>
                    <div>
                        <span>Length of stay</span>
                        <div class="nights-input-row">
                            <input id="dashboardNights"
                                   type="number"
                                   name="nights"
                                   min="1"
                                   max="30"
                                   value="1"
                                   required>
                            <strong>night(s)</strong>
                        </div>
                    </div>
                </label>

                <div class="stay-search-field room-field">
                    <span class="stay-search-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <circle cx="9" cy="7" r="4"></circle>
                            <path d="M2 21v-2a6 6 0 0 1 6-6h2a6 6 0 0 1 6 6v2"></path>
                            <path d="M17 11h5"></path>
                            <path d="M19.5 8.5v5"></path>
                        </svg>
                    </span>
                    <div>
                        <span>Rooms</span>
                        <strong>Select rooms next</strong>
                    </div>
                </div>

                <button class="stay-search-button" type="submit">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="11" cy="11" r="7"></circle>
                        <path d="m20 20-4-4"></path>
                    </svg>
                    Search rooms
                </button>
            </form>

            <div class="customer-quick-links">
                <a href="${ctx}/customer/bookings">
                    <span class="quick-link-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="4" y="3" width="16" height="18" rx="2"></rect>
                            <path d="M8 8h8"></path>
                            <path d="M8 12h8"></path>
                            <path d="M8 16h5"></path>
                        </svg>
                    </span>
                    <span><strong>Manage bookings</strong><small>View and manage every stay</small></span>
                    <i aria-hidden="true">&#8594;</i>
                </a>
                <a href="${ctx}/customer/receipts">
                    <span class="quick-link-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M6 2h12v20l-3-2-3 2-3-2-3 2V2Z"></path>
                            <path d="M9 7h6"></path>
                            <path d="M9 11h6"></path>
                        </svg>
                    </span>
                    <span><strong>Payments &amp; receipts</strong><small>Open printable payment records</small></span>
                    <i aria-hidden="true">&#8594;</i>
                </a>
                <a href="${ctx}/customer/comments">
                    <span class="quick-link-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4v8Z"></path>
                            <path d="M8 9h8"></path>
                            <path d="M8 13h5"></path>
                        </svg>
                    </span>
                    <span><strong>Write a comment</strong><small>Share your stay experience</small></span>
                    <i aria-hidden="true">&#8594;</i>
                </a>
            </div>
        </div>
    </section>
</div>

<style>
    .customer-dashboard {
        display: grid;
        gap: 22px;
    }

    .customer-booking-panel {
        min-width: 0;
        padding: 20px;
        border: 1px solid var(--card-border);
        border-radius: 14px;
        background: #ffffff;
        box-shadow: 0 8px 24px rgba(43, 36, 29, 0.045);
    }

    .customer-panel-header,
    .stay-planner-heading {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
    }

    .customer-panel-header {
        margin-bottom: 17px;
    }

    .customer-panel-kicker,
    .stay-planner-heading p {
        margin: 0 0 4px;
        color: var(--accent-hover);
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 0.1em;
        text-transform: uppercase;
    }

    .customer-panel-header h2,
    .stay-planner-heading h2 {
        margin: 0;
        color: var(--main-text);
        font-size: 21px;
    }

    .customer-panel-header-actions {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .customer-booking-count {
        display: inline-flex;
        align-items: baseline;
        gap: 5px;
        color: var(--muted-text);
        font-size: 11px;
    }

    .customer-booking-count strong {
        color: var(--main-text);
        font-size: 18px;
    }

    .customer-booking-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 14px;
    }

    .customer-booking-card {
        min-width: 0;
        display: flex;
        flex-direction: column;
        padding: 16px;
        border: 1px solid #e3d8ca;
        border-radius: 12px;
        background: linear-gradient(145deg, #ffffff, #fdfaf6);
        box-shadow: 0 5px 16px rgba(43, 36, 29, 0.035);
    }

    .booking-card-top,
    .booking-room-row,
    .booking-card-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
    }

    .booking-order-label,
    .booking-stay-route span,
    .booking-room-details > span,
    .booking-total span {
        display: block;
        margin-bottom: 3px;
        color: var(--muted-text);
        font-size: 9px;
        font-weight: 800;
        letter-spacing: 0.06em;
        text-transform: uppercase;
    }

    .booking-order-number {
        display: block;
        overflow: hidden;
        color: var(--main-text);
        font-size: 12px;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .customer-status-pill {
        padding: 6px 8px;
        border-radius: 999px;
        background: #f1ede7;
        color: #62584e;
        font-size: 9px;
        font-weight: 800;
        text-transform: uppercase;
        white-space: nowrap;
    }

    .customer-status-pill[data-status="CONFIRMED"] {
        background: #e8f3ea;
        color: #347047;
    }

    .customer-status-pill[data-status="CHECKED_IN"],
    .customer-status-pill[data-status="PARTIAL_CHECKED_IN"] {
        background: #e7eff5;
        color: #456b85;
    }

    .customer-status-pill[data-status="CANCELLED"] {
        background: #f9e7e4;
        color: #9a4038;
    }

    .customer-status-pill[data-status="PENDING_PAYMENT"] {
        background: #faeedc;
        color: #8b5d24;
    }

    .booking-stay-route {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        align-items: center;
        gap: 24px;
        margin: 17px 0;
        padding: 13px 0;
        border-top: 1px solid #eee5da;
        border-bottom: 1px solid #eee5da;
    }

    .booking-stay-route > div:last-child {
        text-align: right;
    }

    .booking-stay-route strong {
        font-size: 12px;
    }

    .booking-room-row {
        justify-content: flex-start;
    }

    .booking-room-icon,
    .quick-link-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        background: #f3eadf;
        color: var(--accent-hover);
    }

    .booking-room-icon {
        width: 36px;
        height: 36px;
        flex: 0 0 36px;
    }

    .booking-room-icon svg,
    .quick-link-icon svg {
        width: 19px;
        height: 19px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.7;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .booking-room-details {
        min-width: 0;
        flex: 1;
    }

    .booking-room-details > div {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
    }

    .booking-room-details i {
        padding: 3px 6px;
        border-radius: 5px;
        background: #f2eee8;
        color: var(--main-text);
        font-size: 10px;
        font-style: normal;
        font-weight: 800;
    }

    .booking-night-count {
        color: var(--muted-text);
        font-size: 10px;
        white-space: nowrap;
    }

    .booking-night-count strong {
        color: var(--main-text);
        font-size: 14px;
    }

    .booking-card-footer {
        margin-top: auto;
        padding-top: 15px;
    }

    .booking-total strong {
        font-size: 14px;
    }

    .booking-card-actions {
        display: flex;
        gap: 9px;
    }

    .booking-card-actions a {
        color: var(--accent-hover);
        font-size: 10px;
        font-weight: 800;
        text-decoration: none;
    }

    .booking-card-actions a:hover {
        text-decoration: underline;
    }

    .customer-booking-empty {
        grid-column: 1 / -1;
        display: flex;
        align-items: center;
        gap: 13px;
        padding: 22px;
        border: 1px dashed #d8c9b8;
        border-radius: 11px;
        background: #fbf8f3;
    }

    .customer-empty-icon {
        width: 44px;
        height: 44px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 12px;
        background: #f1e7db;
        color: var(--accent-hover);
    }

    .customer-empty-icon svg {
        width: 23px;
        height: 23px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.7;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .customer-booking-empty > div {
        flex: 1;
    }

    .customer-booking-empty > div strong,
    .customer-booking-empty > div span {
        display: block;
    }

    .customer-booking-empty > div span {
        margin-top: 4px;
        color: var(--muted-text);
        font-size: 11px;
    }

    .stay-planner {
        position: relative;
        min-width: 0;
        overflow: hidden;
        padding: 26px;
        border: 1px solid #725437;
        border-radius: 16px;
        background: linear-gradient(125deg, #33281f 0%, #61462d 62%, #8a6134 100%);
        box-shadow: 0 12px 30px rgba(43, 36, 29, 0.13);
    }

    .stay-planner-backdrop,
    .stay-planner-content {
        position: relative;
    }

    .stay-planner-backdrop {
        position: absolute;
        inset: 0;
        overflow: hidden;
        pointer-events: none;
    }

    .planner-orb {
        position: absolute;
        border: 1px solid rgba(255, 255, 255, 0.12);
        border-radius: 50%;
    }

    .planner-orb-one {
        top: -120px;
        right: 5%;
        width: 330px;
        height: 330px;
        background: rgba(255, 255, 255, 0.035);
    }

    .planner-orb-two {
        right: -70px;
        bottom: -150px;
        width: 300px;
        height: 300px;
        background: rgba(216, 169, 104, 0.08);
    }

    .planner-line-art {
        position: absolute;
        inset: 15% 4% auto auto;
        width: 280px;
        height: 120px;
        border-top: 1px solid rgba(255, 255, 255, 0.09);
        border-radius: 50%;
        transform: rotate(-8deg);
    }

    .stay-planner-heading p,
    .stay-planner-heading h2 {
        color: #ffffff;
    }

    .stay-planner-heading p {
        color: #dfc6a5;
    }

    .stay-planner-heading h2 {
        font-size: 24px;
    }

    .planner-member-badge {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        padding: 7px 10px;
        border: 1px solid rgba(255, 255, 255, 0.18);
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.09);
        color: #f6eadb;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
    }

    .planner-member-badge svg {
        width: 14px;
        height: 14px;
        fill: none;
        stroke: #e6bb7f;
        stroke-width: 1.7;
    }

    .planner-feature-row {
        display: flex;
        align-items: stretch;
        gap: 8px;
        margin: 21px 0 13px;
    }

    .planner-feature {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        padding: 9px 12px;
        border-bottom: 2px solid transparent;
        color: #dfd0be;
        font-size: 10px;
        font-weight: 700;
    }

    .planner-feature.is-active {
        border-bottom-color: #e3b36f;
        color: #ffffff;
    }

    .planner-feature svg {
        width: 18px;
        height: 18px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.7;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .stay-search-bar {
        display: grid;
        grid-template-columns: 1.25fr 0.9fr 0.72fr 0.9fr auto;
        align-items: stretch;
        overflow: hidden;
        border: 1px solid rgba(255, 255, 255, 0.34);
        border-radius: 12px;
        background: #ffffff;
        box-shadow: 0 12px 26px rgba(29, 20, 13, 0.19);
    }

    .stay-search-field {
        min-width: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        min-height: 70px;
        padding: 12px 14px;
        border-right: 1px solid #e7ded4;
        background: #ffffff;
    }

    .stay-search-field:hover,
    .stay-search-field:focus-within {
        background: #fdf9f4;
    }

    .stay-search-icon {
        width: 24px;
        height: 24px;
        flex: 0 0 24px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        color: var(--accent-hover);
    }

    .stay-search-icon svg,
    .stay-search-button svg {
        width: 21px;
        height: 21px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .stay-search-field > div {
        min-width: 0;
    }

    .stay-search-field label,
    .stay-search-field > div > span,
    .date-field > div > span,
    .nights-field > div > span {
        display: block;
        margin-bottom: 4px;
        color: var(--muted-text);
        font-size: 9px;
        font-weight: 800;
        letter-spacing: 0.06em;
        text-transform: uppercase;
    }

    .stay-search-field strong {
        display: block;
        overflow: hidden;
        color: var(--main-text);
        font-size: 11px;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .stay-search-field input {
        width: 100%;
        min-width: 0;
        height: auto;
        padding: 0;
        border: 0;
        border-radius: 0;
        background: transparent;
        color: var(--main-text);
        font: inherit;
        font-size: 11px;
        font-weight: 700;
        box-shadow: none;
    }

    .stay-search-field input:focus {
        outline: none;
        box-shadow: none;
    }

    .nights-input-row {
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .nights-input-row input {
        width: 34px;
    }

    .nights-input-row strong {
        font-size: 10px;
    }

    .stay-search-button {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        min-width: 150px;
        padding: 0 18px;
        border: 0;
        background: var(--accent);
        color: #ffffff;
        font: inherit;
        font-size: 12px;
        font-weight: 800;
        cursor: pointer;
        transition: background-color 0.15s ease;
    }

    .stay-search-button:hover {
        background: var(--accent-hover);
    }

    .customer-quick-links {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 10px;
        margin-top: 14px;
    }

    .customer-quick-links > a {
        min-width: 0;
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px;
        border: 1px solid rgba(255, 255, 255, 0.14);
        border-radius: 11px;
        background: rgba(255, 255, 255, 0.08);
        color: #ffffff;
        text-decoration: none;
        transition: background-color 0.15s ease, transform 0.15s ease;
    }

    .customer-quick-links > a:hover {
        background: rgba(255, 255, 255, 0.13);
        color: #ffffff;
        transform: translateY(-1px);
    }

    .customer-quick-links .quick-link-icon {
        width: 37px;
        height: 37px;
        flex: 0 0 37px;
        background: rgba(255, 255, 255, 0.11);
        color: #e5bb80;
    }

    .customer-quick-links > a > span:nth-child(2) {
        min-width: 0;
        flex: 1;
    }

    .customer-quick-links strong,
    .customer-quick-links small {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .customer-quick-links strong {
        font-size: 11px;
    }

    .customer-quick-links small {
        margin-top: 3px;
        color: #d7c8b8;
        font-size: 9px;
    }

    .customer-quick-links i {
        color: #e1b77e;
        font-size: 15px;
        font-style: normal;
    }

    @media (max-width: 1250px) {
        .customer-booking-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .stay-search-bar {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .stay-search-field {
            border-bottom: 1px solid #e7ded4;
        }

        .stay-search-button {
            min-height: 58px;
        }
    }

    @media (max-width: 780px) {
        .customer-booking-grid,
        .customer-quick-links,
        .stay-search-bar {
            grid-template-columns: 1fr;
        }

        .customer-panel-header,
        .stay-planner-heading {
            align-items: flex-start;
            flex-direction: column;
        }

        .customer-panel-header-actions {
            width: 100%;
            justify-content: space-between;
        }

        .planner-feature-row {
            overflow-x: auto;
        }

        .planner-feature {
            flex: 0 0 auto;
        }

        .stay-search-field {
            border-right: 0;
        }
    }

    @media (max-width: 520px) {
        .customer-booking-panel,
        .stay-planner {
            padding: 15px;
        }

        .customer-booking-empty {
            align-items: flex-start;
            flex-direction: column;
        }

        .booking-card-top,
        .booking-card-footer {
            align-items: flex-start;
            flex-direction: column;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
