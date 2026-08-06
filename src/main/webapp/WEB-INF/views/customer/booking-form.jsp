<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Book a Room" scope="request"/>
<c:set var="activeMenu" value="book" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:set var="standardSelected" value="false"/>
<c:set var="vipSelected" value="false"/>
<c:set var="presidentialSelected" value="false"/>
<c:forEach var="selectedId" items="${enteredRoomIds}">
    <c:forEach var="room" items="${standardRooms}">
        <c:if test="${selectedId == room.id}"><c:set var="standardSelected" value="true"/></c:if>
    </c:forEach>
    <c:forEach var="room" items="${vipRooms}">
        <c:if test="${selectedId == room.id}"><c:set var="vipSelected" value="true"/></c:if>
    </c:forEach>
    <c:forEach var="room" items="${presidentialRooms}">
        <c:if test="${selectedId == room.id}"><c:set var="presidentialSelected" value="true"/></c:if>
    </c:forEach>
</c:forEach>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<style>
    .booking-page {
        --booking-ink: #2b241d;
        --booking-muted: #73685c;
        --booking-line: #ded4c6;
        --booking-soft: #f8f4ed;
        --booking-gold-soft: #f3e8d8;
        --booking-green: #2f6b4f;
        width: 100%;
    }

    .booking-page button,
    .booking-page input {
        font: inherit;
    }

    .stay-search-panel {
        display: grid;
        grid-template-columns: minmax(210px, 1.25fr) minmax(160px, 0.75fr) minmax(210px, 1fr);
        align-items: end;
        gap: 0;
        margin-bottom: 24px;
        padding: 14px;
        border: 1px solid var(--booking-line);
        border-radius: 16px;
        background: #ffffff;
        box-shadow: 0 10px 30px rgba(64, 47, 28, 0.07);
    }

    .stay-field {
        min-width: 0;
        padding: 4px 18px;
        border-right: 1px solid #e9e1d7;
    }

    .stay-field:last-child {
        border-right: 0;
    }

    .stay-field label,
    .stay-field-label {
        display: block;
        margin-bottom: 7px;
        color: var(--booking-muted);
        font-size: 11px;
        font-weight: 800;
        letter-spacing: 0.07em;
        text-transform: uppercase;
    }

    .stay-field input {
        width: 100%;
        min-height: 42px;
        padding: 0;
        border: 0;
        outline: 0;
        background: transparent;
        color: var(--booking-ink);
        font-size: 16px;
        font-weight: 750;
    }

    .stay-field input:focus-visible {
        border-radius: 6px;
        box-shadow: 0 0 0 3px rgba(168, 121, 61, 0.2);
    }

    .stay-field-value {
        display: flex;
        align-items: center;
        min-height: 42px;
        color: var(--booking-ink);
        font-size: 16px;
        font-weight: 750;
    }

    .booking-field-error {
        margin-top: 5px;
        color: var(--error-text);
        font-size: 12px;
        font-weight: 650;
        line-height: 1.35;
    }

    .booking-error-banner {
        margin-bottom: 20px;
        padding: 13px 15px;
        border: 1px solid var(--error-border);
        border-radius: 10px;
        background: var(--error-background);
        color: var(--error-text);
        font-size: 14px;
        font-weight: 650;
    }

    .booking-layout {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 330px;
        align-items: start;
        gap: 24px;
    }

    .room-catalog {
        display: grid;
        gap: 20px;
        min-width: 0;
    }

    .room-card {
        overflow: hidden;
        border: 1px solid var(--booking-line);
        border-radius: 18px;
        background: #ffffff;
        box-shadow: 0 8px 24px rgba(64, 47, 28, 0.055);
        transition: border-color 0.2s ease, box-shadow 0.2s ease, transform 0.2s ease;
    }

    .room-card:hover,
    .room-card.has-selection {
        border-color: #c5a77e;
        box-shadow: 0 14px 34px rgba(64, 47, 28, 0.1);
    }

    .room-card-overview {
        display: grid;
        grid-template-columns: minmax(240px, 31%) minmax(0, 1fr) 178px;
        min-height: 238px;
    }

    .room-photo-button {
        position: relative;
        display: block;
        min-width: 0;
        min-height: 238px;
        padding: 0;
        overflow: hidden;
        border: 0;
        background: #e9e0d5;
        cursor: pointer;
    }

    .room-photo-button img {
        display: block;
        width: 100%;
        height: 100%;
        min-height: 238px;
        object-fit: cover;
        transition: transform 0.35s ease;
    }

    .room-photo-button:hover img {
        transform: scale(1.025);
    }

    .photo-action {
        position: absolute;
        right: 12px;
        bottom: 12px;
        padding: 8px 11px;
        border-radius: 999px;
        background: rgba(43, 36, 29, 0.84);
        color: #ffffff;
        font-size: 12px;
        font-weight: 750;
        backdrop-filter: blur(5px);
    }

    .room-card-main {
        min-width: 0;
        padding: 23px 22px;
        border-right: 1px solid #eee7dd;
    }

    .room-card-flags {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 8px;
        margin-bottom: 10px;
    }

    .room-tier-badge,
    .room-availability {
        display: inline-flex;
        align-items: center;
        min-height: 25px;
        padding: 0 9px;
        border-radius: 999px;
        font-size: 11px;
        font-weight: 800;
        letter-spacing: 0.035em;
        text-transform: uppercase;
    }

    .room-tier-badge {
        background: var(--booking-gold-soft);
        color: #765126;
    }

    .room-availability {
        background: #eaf4ee;
        color: var(--booking-green);
    }

    .room-availability.is-sold-out {
        background: #f2efeb;
        color: #82786d;
    }

    .room-card h2 {
        margin: 0 0 7px;
        color: var(--booking-ink);
        font-size: 23px;
        line-height: 1.2;
    }

    .room-subtitle {
        margin: 0 0 15px;
        color: var(--booking-muted);
        font-size: 13px;
        line-height: 1.45;
    }

    .room-facts {
        display: flex;
        flex-wrap: wrap;
        gap: 8px 16px;
        margin-bottom: 15px;
    }

    .room-fact {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #4e453d;
        font-size: 13px;
        font-weight: 650;
    }

    .room-fact svg {
        width: 17px;
        height: 17px;
        fill: none;
        stroke: var(--accent);
        stroke-width: 1.75;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .feature-preview {
        display: flex;
        flex-wrap: wrap;
        gap: 7px;
    }

    .feature-preview span {
        padding: 6px 9px;
        border: 1px solid #e2d8ca;
        border-radius: 7px;
        background: #fbf8f3;
        color: #655b50;
        font-size: 11px;
        font-weight: 650;
    }

    .room-price-panel {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        justify-content: flex-end;
        padding: 22px 18px;
        text-align: right;
    }

    .price-prefix {
        color: var(--booking-muted);
        font-size: 11px;
        font-weight: 650;
    }

    .room-price {
        margin-top: 2px;
        color: #8a5d28;
        font-size: 25px;
        font-weight: 850;
        letter-spacing: -0.025em;
        white-space: nowrap;
    }

    .price-unit {
        margin: 2px 0 14px;
        color: var(--booking-muted);
        font-size: 11px;
        line-height: 1.35;
    }

    .choose-room-button,
    .sold-out-button {
        width: 100%;
        min-height: 42px;
        padding: 0 12px;
        border-radius: 9px;
        font-size: 13px;
        font-weight: 800;
    }

    .choose-room-button {
        border: 0;
        background: var(--accent);
        color: #ffffff;
        cursor: pointer;
    }

    .choose-room-button:hover {
        background: var(--accent-hover);
    }

    .sold-out-button {
        border: 1px solid #ddd5cb;
        background: #f2efeb;
        color: #8a8178;
        cursor: not-allowed;
    }

    .room-details {
        display: none;
        border-top: 1px solid var(--booking-line);
        background: #fcfaf6;
    }

    .room-details.is-open {
        display: block;
    }

    .room-detail-grid {
        display: grid;
        grid-template-columns: minmax(260px, 0.85fr) minmax(320px, 1.15fr);
        gap: 24px;
        padding: 24px;
    }

    .detail-section-title {
        margin: 0 0 6px;
        color: var(--booking-ink);
        font-size: 16px;
    }

    .detail-section-copy {
        margin: 0 0 16px;
        color: var(--booking-muted);
        font-size: 12px;
        line-height: 1.5;
    }

    .facility-list {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px 14px;
        margin: 0;
        padding: 0;
        list-style: none;
    }

    .facility-list li {
        display: flex;
        align-items: flex-start;
        gap: 8px;
        color: #514941;
        font-size: 12px;
        line-height: 1.35;
    }

    .facility-check {
        color: var(--booking-green);
        font-weight: 900;
    }

    .room-options-panel {
        padding: 18px;
        border: 1px solid #dfd5c8;
        border-radius: 13px;
        background: #ffffff;
    }

    .rate-note {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 14px;
        padding-bottom: 13px;
        border-bottom: 1px solid #eee7de;
    }

    .rate-note strong {
        display: block;
        margin-bottom: 3px;
        color: var(--booking-ink);
        font-size: 13px;
    }

    .rate-note span {
        color: var(--booking-muted);
        font-size: 11px;
    }

    .rate-confirmation {
        flex: 0 0 auto;
        padding: 6px 9px;
        border-radius: 7px;
        background: #eaf4ee;
        color: var(--booking-green) !important;
        font-weight: 800;
    }

    .room-choice-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 9px;
        max-height: 264px;
        padding: 2px;
        overflow-y: auto;
    }

    .room-choice {
        position: relative;
        display: block;
        min-width: 0;
        cursor: pointer;
    }

    .room-choice input {
        position: absolute;
        width: 1px;
        height: 1px;
        opacity: 0;
    }

    .room-choice-surface {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 8px;
        min-height: 61px;
        padding: 10px 30px 10px 11px;
        border: 1px solid #ded5ca;
        border-radius: 9px;
        background: #ffffff;
        transition: border-color 0.15s ease, background 0.15s ease, box-shadow 0.15s ease;
    }

    .room-choice:hover .room-choice-surface {
        border-color: #b99668;
    }

    .room-choice input:focus-visible + .room-choice-surface {
        box-shadow: 0 0 0 3px rgba(168, 121, 61, 0.18);
    }

    .room-choice input:checked + .room-choice-surface {
        border-color: var(--accent);
        background: #fbf4e9;
        box-shadow: inset 0 0 0 1px var(--accent);
    }

    .room-choice input:checked + .room-choice-surface::after {
        content: "\2713";
        position: absolute;
        top: 9px;
        right: 10px;
        color: var(--booking-green);
        font-size: 14px;
        font-weight: 900;
    }

    .room-choice-name strong,
    .room-choice-name small {
        display: block;
    }

    .room-choice-name strong {
        color: var(--booking-ink);
        font-size: 12px;
    }

    .room-choice-name small {
        margin-top: 3px;
        color: var(--booking-muted);
        font-size: 10px;
    }

    .room-choice-price {
        flex: 0 0 auto;
        color: #7b5529;
        font-size: 11px;
        font-weight: 800;
    }

    .booking-summary {
        position: sticky;
        top: 20px;
    }

    .booking-summary-card {
        overflow: hidden;
        border: 1px solid var(--booking-line);
        border-radius: 18px;
        background: #ffffff;
        box-shadow: 0 12px 32px rgba(64, 47, 28, 0.09);
    }

    .summary-heading {
        padding: 20px 21px 17px;
        border-bottom: 1px solid #eee7de;
    }

    .summary-heading h2 {
        margin: 0;
        color: var(--booking-ink);
        font-size: 18px;
    }

    .summary-body {
        padding: 18px 21px 21px;
    }

    .summary-stay {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
        margin-bottom: 17px;
    }

    .summary-stay-item {
        padding: 10px;
        border-radius: 9px;
        background: var(--booking-soft);
    }

    .summary-label {
        display: block;
        margin-bottom: 5px;
        color: var(--booking-muted);
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 0.05em;
        text-transform: uppercase;
    }

    .summary-value {
        color: var(--booking-ink);
        font-size: 12px;
        font-weight: 750;
    }

    .selected-room-heading {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        margin-bottom: 9px;
    }

    .selected-room-heading strong {
        color: var(--booking-ink);
        font-size: 13px;
    }

    .selected-count {
        color: var(--booking-muted);
        font-size: 11px;
        font-weight: 700;
    }

    .selected-room-empty {
        margin: 0 0 15px;
        padding: 12px;
        border: 1px dashed #d9cdbf;
        border-radius: 9px;
        color: var(--booking-muted);
        font-size: 12px;
        line-height: 1.4;
        text-align: center;
    }

    .selected-room-list {
        display: grid;
        gap: 7px;
        max-height: 158px;
        margin: 0 0 15px;
        padding: 0;
        overflow-y: auto;
        list-style: none;
    }

    .selected-room-list:empty {
        display: none;
    }

    .selected-room-list li {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        padding: 8px 10px;
        border-radius: 8px;
        background: #faf7f2;
        color: #514941;
        font-size: 11px;
    }

    .selected-room-list strong {
        color: #775329;
        white-space: nowrap;
    }

    .summary-total {
        display: flex;
        align-items: end;
        justify-content: space-between;
        gap: 10px;
        padding: 15px 0;
        border-top: 1px solid #eee7de;
    }

    .summary-total-label {
        color: var(--booking-muted);
        font-size: 12px;
        font-weight: 700;
    }

    .summary-total-price {
        color: #825725;
        font-size: 24px;
        font-weight: 850;
        letter-spacing: -0.025em;
    }

    .summary-submit {
        width: 100%;
        min-height: 47px;
        border: 0;
        border-radius: 10px;
        background: var(--accent);
        color: #ffffff;
        font-size: 14px;
        font-weight: 800;
        cursor: pointer;
    }

    .summary-submit:hover {
        background: var(--accent-hover);
    }

    .summary-submit:disabled {
        background: #c7bbae;
        cursor: not-allowed;
    }

    .summary-security {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        margin: 10px 0 0;
        color: var(--booking-muted);
        font-size: 10px;
        text-align: center;
    }

    .summary-security svg {
        width: 13px;
        height: 13px;
        fill: none;
        stroke: var(--booking-green);
        stroke-width: 1.8;
    }

    .summary-link {
        display: flex;
        justify-content: center;
        margin-top: 13px;
        color: #765126;
        font-size: 12px;
        font-weight: 750;
        text-decoration: none;
    }

    .summary-link:hover {
        text-decoration: underline;
    }

    @media (max-width: 1180px) {
        .booking-layout {
            grid-template-columns: minmax(0, 1fr) 292px;
        }

        .room-card-overview {
            grid-template-columns: minmax(210px, 34%) minmax(0, 1fr);
        }

        .room-price-panel {
            grid-column: 1 / -1;
            flex-direction: row;
            align-items: center;
            justify-content: flex-end;
            gap: 10px;
            padding: 13px 18px;
            border-top: 1px solid #eee7dd;
            text-align: left;
        }

        .price-unit {
            margin: 0 auto 0 0;
        }

        .choose-room-button,
        .sold-out-button {
            width: auto;
            min-width: 138px;
        }
    }

    @media (max-width: 980px) {
        .booking-layout {
            grid-template-columns: 1fr;
        }

        .booking-summary {
            position: static;
        }

        .summary-stay {
            grid-template-columns: repeat(3, 1fr);
        }
    }

    @media (max-width: 720px) {
        .stay-search-panel {
            grid-template-columns: 1fr;
        }

        .stay-field {
            padding: 12px 8px;
            border-right: 0;
            border-bottom: 1px solid #e9e1d7;
        }

        .stay-field:last-child {
            border-bottom: 0;
        }

        .room-card-overview {
            grid-template-columns: 1fr;
        }

        .room-photo-button,
        .room-photo-button img {
            min-height: 210px;
            max-height: 260px;
        }

        .room-card-main {
            border-right: 0;
        }

        .room-detail-grid,
        .room-choice-grid,
        .facility-list {
            grid-template-columns: 1fr;
        }

        .room-price-panel {
            flex-wrap: wrap;
        }

        .price-unit {
            width: 100%;
            order: 2;
        }

        .choose-room-button,
        .sold-out-button {
            width: 100%;
            order: 3;
        }

        .summary-stay {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="booking-page">
    <c:if test="${not empty formError}">
        <div class="booking-error-banner" role="alert">
            <c:out value="${formError}"/>
        </div>
    </c:if>

    <form id="roomBookingForm" method="post" action="${ctx}/customer/book">
        <input type="hidden" name="action" value="preview">

        <div class="stay-search-panel" aria-label="Stay dates">
            <div class="stay-field">
                <label for="checkInDate">Check-in date</label>
                <input id="checkInDate"
                       type="date"
                       name="checkInDate"
                       min="${today}"
                       max="${maxCheckIn}"
                       value="${fn:escapeXml(enteredCheckIn)}"
                       required>
                <c:if test="${not empty errors.checkInDate}">
                    <div class="booking-field-error"><c:out value="${errors.checkInDate}"/></div>
                </c:if>
            </div>

            <div class="stay-field">
                <label for="nights">Length of stay</label>
                <input id="nights"
                       type="number"
                       name="nights"
                       min="1"
                       max="30"
                       value="${fn:escapeXml(enteredNights)}"
                       required>
                <c:if test="${not empty errors.nights}">
                    <div class="booking-field-error"><c:out value="${errors.nights}"/></div>
                </c:if>
            </div>

            <div class="stay-field">
                <span class="stay-field-label">Check-out date</span>
                <span id="checkoutDateDisplay" class="stay-field-value">&mdash;</span>
            </div>
        </div>

        <c:if test="${not empty errors.roomIds}">
            <div class="booking-error-banner" role="alert">
                <c:out value="${errors.roomIds}"/>
            </div>
        </c:if>

        <div class="booking-layout">
            <div class="room-catalog">
                <article class="room-card" data-room-card="standard">
                    <div class="room-card-overview">
                        <button class="room-photo-button js-tier-toggle"
                                type="button"
                                data-target="standard-details"
                                aria-controls="standard-details"
                                aria-expanded="${standardSelected}">
                            <img src="${ctx}/assets/images/rooms/standard-room.png"
                                 alt="Warm modern Standard room with a queen bed, desk and private shower">
                            <span class="photo-action">View room</span>
                        </button>

                        <div class="room-card-main">
                            <div class="room-card-flags">
                                <span class="room-tier-badge">Essential comfort</span>
                                <c:choose>
                                    <c:when test="${empty standardRooms}">
                                        <span class="room-availability is-sold-out">Currently unavailable</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="room-availability">${fn:length(standardRooms)} rooms available</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <h2>Standard Room</h2>
                            <p class="room-subtitle">A practical, comfortable stay with everything needed for work or rest.</p>
                            <div class="room-facts">
                                <span class="room-fact">
                                    <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="12" cy="7.5" r="3.2"/><path d="M5.5 20c.5-4 2.7-6 6.5-6s6 2 6.5 6"/></svg>
                                    Up to 2 guests
                                </span>
                                <span class="room-fact">
                                    <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M3.5 17.5V9.8M20.5 17.5v-5.2a2 2 0 0 0-2-2H8.2a2 2 0 0 0-2 2v5.2M3.5 15h17M6.2 10.3V8.7a1.7 1.7 0 0 1 1.7-1.7h3.2a1.7 1.7 0 0 1 1.7 1.7v1.6"/></svg>
                                    1 queen bed
                                </span>
                            </div>
                            <div class="feature-preview" aria-label="Key facilities">
                                <span>Free Wi-Fi</span><span>Air conditioning</span><span>Smart TV</span><span>Private shower</span>
                            </div>
                        </div>

                        <div class="room-price-panel">
                            <span class="price-prefix">From</span>
                            <strong class="room-price">RM <fmt:formatNumber value="${standardPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                            <span class="price-unit">per room / night</span>
                            <c:choose>
                                <c:when test="${empty standardRooms}">
                                    <button class="sold-out-button" type="button" disabled>Sold out</button>
                                </c:when>
                                <c:otherwise>
                                    <button class="choose-room-button js-tier-toggle"
                                            type="button"
                                            data-target="standard-details"
                                            aria-controls="standard-details"
                                            aria-expanded="${standardSelected}">Choose room</button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div id="standard-details" class="room-details ${standardSelected ? 'is-open' : ''}" aria-hidden="${not standardSelected}">
                        <div class="room-detail-grid">
                            <section>
                                <h3 class="detail-section-title">Standard room facilities</h3>
                                <p class="detail-section-copy">Designed for one or two guests, with a focused set of everyday hotel essentials.</p>
                                <ul class="facility-list">
                                    <li><span class="facility-check">&#10003;</span>High-speed Wi-Fi</li>
                                    <li><span class="facility-check">&#10003;</span>Air conditioning</li>
                                    <li><span class="facility-check">&#10003;</span>Smart TV</li>
                                    <li><span class="facility-check">&#10003;</span>Private shower</li>
                                    <li><span class="facility-check">&#10003;</span>Work desk</li>
                                    <li><span class="facility-check">&#10003;</span>Electric kettle</li>
                                </ul>
                            </section>
                            <section class="room-options-panel">
                                <div class="rate-note">
                                    <div><strong>Room-only rate</strong><span>Choose any available Standard room below.</span></div>
                                    <span class="rate-confirmation">Instant confirmation</span>
                                </div>
                                <div class="room-choice-grid">
                                    <c:forEach var="room" items="${standardRooms}">
                                        <c:set var="checked" value="false"/>
                                        <c:forEach var="selectedId" items="${enteredRoomIds}">
                                            <c:if test="${selectedId == room.id}"><c:set var="checked" value="true"/></c:if>
                                        </c:forEach>
                                        <label class="room-choice">
                                            <input class="room-checkbox"
                                                   type="checkbox"
                                                   name="roomIds"
                                                   value="${room.id}"
                                                   data-room-number="${fn:escapeXml(room.roomNumber)}"
                                                   data-room-type="Standard"
                                                   data-price="${room.currentPrice}"
                                                   ${checked ? 'checked' : ''}>
                                            <span class="room-choice-surface">
                                                <span class="room-choice-name"><strong>Room <c:out value="${room.roomNumber}"/></strong><small>Floor <c:out value="${room.floor}"/></small></span>
                                                <span class="room-choice-price">RM <fmt:formatNumber value="${room.currentPrice}" minFractionDigits="0" maxFractionDigits="2"/></span>
                                            </span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </section>
                        </div>
                    </div>
                </article>

                <article class="room-card" data-room-card="vip">
                    <div class="room-card-overview">
                        <button class="room-photo-button js-tier-toggle"
                                type="button"
                                data-target="vip-details"
                                aria-controls="vip-details"
                                aria-expanded="${vipSelected}">
                            <img src="${ctx}/assets/images/rooms/vip-room.png"
                                 alt="Spacious VIP room with a king bed, lounge and city view">
                            <span class="photo-action">View room</span>
                        </button>

                        <div class="room-card-main">
                            <div class="room-card-flags">
                                <span class="room-tier-badge">Elevated stay</span>
                                <c:choose>
                                    <c:when test="${empty vipRooms}">
                                        <span class="room-availability is-sold-out">Currently unavailable</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="room-availability">${fn:length(vipRooms)} rooms available</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <h2>VIP Room</h2>
                            <p class="room-subtitle">More space, a king bed and enhanced bathroom comforts for a premium stay.</p>
                            <div class="room-facts">
                                <span class="room-fact">
                                    <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="12" cy="7.5" r="3.2"/><path d="M5.5 20c.5-4 2.7-6 6.5-6s6 2 6.5 6"/></svg>
                                    Up to 3 guests
                                </span>
                                <span class="room-fact">
                                    <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M3.5 17.5V9.8M20.5 17.5v-5.2a2 2 0 0 0-2-2H8.2a2 2 0 0 0-2 2v5.2M3.5 15h17M6.2 10.3V8.7a1.7 1.7 0 0 1 1.7-1.7h3.2a1.7 1.7 0 0 1 1.7 1.7v1.6"/></svg>
                                    1 king bed + sofa bed
                                </span>
                            </div>
                            <div class="feature-preview" aria-label="Key facilities">
                                <span>Free Wi-Fi</span><span>Bathtub</span><span>Lounge area</span><span>Mini fridge</span>
                            </div>
                        </div>

                        <div class="room-price-panel">
                            <span class="price-prefix">From</span>
                            <strong class="room-price">RM <fmt:formatNumber value="${vipPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                            <span class="price-unit">per room / night</span>
                            <c:choose>
                                <c:when test="${empty vipRooms}">
                                    <button class="sold-out-button" type="button" disabled>Sold out</button>
                                </c:when>
                                <c:otherwise>
                                    <button class="choose-room-button js-tier-toggle"
                                            type="button"
                                            data-target="vip-details"
                                            aria-controls="vip-details"
                                            aria-expanded="${vipSelected}">Choose room</button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div id="vip-details" class="room-details ${vipSelected ? 'is-open' : ''}" aria-hidden="${not vipSelected}">
                        <div class="room-detail-grid">
                            <section>
                                <h3 class="detail-section-title">VIP room facilities</h3>
                                <p class="detail-section-copy">Suitable for up to three guests, with extra living space and upgraded in-room comforts.</p>
                                <ul class="facility-list">
                                    <li><span class="facility-check">&#10003;</span>High-speed Wi-Fi</li>
                                    <li><span class="facility-check">&#10003;</span>King bed + sofa bed</li>
                                    <li><span class="facility-check">&#10003;</span>Private bathtub</li>
                                    <li><span class="facility-check">&#10003;</span>Mini fridge</li>
                                    <li><span class="facility-check">&#10003;</span>Lounge area</li>
                                    <li><span class="facility-check">&#10003;</span>Premium toiletries</li>
                                    <li><span class="facility-check">&#10003;</span>Smart TV</li>
                                    <li><span class="facility-check">&#10003;</span>City view</li>
                                </ul>
                            </section>
                            <section class="room-options-panel">
                                <div class="rate-note">
                                    <div><strong>Room-only rate</strong><span>Choose any available VIP room below.</span></div>
                                    <span class="rate-confirmation">Instant confirmation</span>
                                </div>
                                <div class="room-choice-grid">
                                    <c:forEach var="room" items="${vipRooms}">
                                        <c:set var="checked" value="false"/>
                                        <c:forEach var="selectedId" items="${enteredRoomIds}">
                                            <c:if test="${selectedId == room.id}"><c:set var="checked" value="true"/></c:if>
                                        </c:forEach>
                                        <label class="room-choice">
                                            <input class="room-checkbox"
                                                   type="checkbox"
                                                   name="roomIds"
                                                   value="${room.id}"
                                                   data-room-number="${fn:escapeXml(room.roomNumber)}"
                                                   data-room-type="VIP"
                                                   data-price="${room.currentPrice}"
                                                   ${checked ? 'checked' : ''}>
                                            <span class="room-choice-surface">
                                                <span class="room-choice-name"><strong>Room <c:out value="${room.roomNumber}"/></strong><small>Floor <c:out value="${room.floor}"/></small></span>
                                                <span class="room-choice-price">RM <fmt:formatNumber value="${room.currentPrice}" minFractionDigits="0" maxFractionDigits="2"/></span>
                                            </span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </section>
                        </div>
                    </div>
                </article>

                <article class="room-card" data-room-card="presidential">
                    <div class="room-card-overview">
                        <button class="room-photo-button js-tier-toggle"
                                type="button"
                                data-target="presidential-details"
                                aria-controls="presidential-details"
                                aria-expanded="${presidentialSelected}">
                            <img src="${ctx}/assets/images/rooms/presidential-room.png"
                                 alt="Luxury Presidential suite with a king bed, living area and panoramic city view">
                            <span class="photo-action">View room</span>
                        </button>

                        <div class="room-card-main">
                            <div class="room-card-flags">
                                <span class="room-tier-badge">Signature suite</span>
                                <c:choose>
                                    <c:when test="${empty presidentialRooms}">
                                        <span class="room-availability is-sold-out">Currently unavailable</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="room-availability">${fn:length(presidentialRooms)} rooms available</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <h2>Presidential Suite</h2>
                            <p class="room-subtitle">Our most spacious stay, with private living, dining and extended-stay facilities.</p>
                            <div class="room-facts">
                                <span class="room-fact">
                                    <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="12" cy="7.5" r="3.2"/><path d="M5.5 20c.5-4 2.7-6 6.5-6s6 2 6.5 6"/></svg>
                                    Up to 4 guests
                                </span>
                                <span class="room-fact">
                                    <svg aria-hidden="true" viewBox="0 0 24 24"><path d="M3.5 17.5V9.8M20.5 17.5v-5.2a2 2 0 0 0-2-2H8.2a2 2 0 0 0-2 2v5.2M3.5 15h17M6.2 10.3V8.7a1.7 1.7 0 0 1 1.7-1.7h3.2a1.7 1.7 0 0 1 1.7 1.7v1.6"/></svg>
                                    1 king bed + 2 single beds
                                </span>
                            </div>
                            <div class="feature-preview" aria-label="Key facilities">
                                <span>Free Wi-Fi</span><span>Private living room</span><span>Washing machine</span><span>Kitchenette</span>
                            </div>
                        </div>

                        <div class="room-price-panel">
                            <span class="price-prefix">From</span>
                            <strong class="room-price">RM <fmt:formatNumber value="${presidentialPrice}" minFractionDigits="2" maxFractionDigits="2"/></strong>
                            <span class="price-unit">per room / night</span>
                            <c:choose>
                                <c:when test="${empty presidentialRooms}">
                                    <button class="sold-out-button" type="button" disabled>Sold out</button>
                                </c:when>
                                <c:otherwise>
                                    <button class="choose-room-button js-tier-toggle"
                                            type="button"
                                            data-target="presidential-details"
                                            aria-controls="presidential-details"
                                            aria-expanded="${presidentialSelected}">Choose room</button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div id="presidential-details" class="room-details ${presidentialSelected ? 'is-open' : ''}" aria-hidden="${not presidentialSelected}">
                        <div class="room-detail-grid">
                            <section>
                                <h3 class="detail-section-title">Presidential suite facilities</h3>
                                <p class="detail-section-copy">Built for up to four guests, with separate zones for sleeping, relaxing, dining and longer stays.</p>
                                <ul class="facility-list">
                                    <li><span class="facility-check">&#10003;</span>High-speed Wi-Fi</li>
                                    <li><span class="facility-check">&#10003;</span>King bed + 2 single beds</li>
                                    <li><span class="facility-check">&#10003;</span>Private living room</li>
                                    <li><span class="facility-check">&#10003;</span>Dining area</li>
                                    <li><span class="facility-check">&#10003;</span>Premium bathtub</li>
                                    <li><span class="facility-check">&#10003;</span>Washing machine</li>
                                    <li><span class="facility-check">&#10003;</span>Kitchenette</li>
                                    <li><span class="facility-check">&#10003;</span>Panoramic city view</li>
                                </ul>
                            </section>
                            <section class="room-options-panel">
                                <div class="rate-note">
                                    <div><strong>Room-only rate</strong><span>Choose any available Presidential suite below.</span></div>
                                    <span class="rate-confirmation">Instant confirmation</span>
                                </div>
                                <div class="room-choice-grid">
                                    <c:forEach var="room" items="${presidentialRooms}">
                                        <c:set var="checked" value="false"/>
                                        <c:forEach var="selectedId" items="${enteredRoomIds}">
                                            <c:if test="${selectedId == room.id}"><c:set var="checked" value="true"/></c:if>
                                        </c:forEach>
                                        <label class="room-choice">
                                            <input class="room-checkbox"
                                                   type="checkbox"
                                                   name="roomIds"
                                                   value="${room.id}"
                                                   data-room-number="${fn:escapeXml(room.roomNumber)}"
                                                   data-room-type="Presidential"
                                                   data-price="${room.currentPrice}"
                                                   ${checked ? 'checked' : ''}>
                                            <span class="room-choice-surface">
                                                <span class="room-choice-name"><strong>Room <c:out value="${room.roomNumber}"/></strong><small>Floor <c:out value="${room.floor}"/></small></span>
                                                <span class="room-choice-price">RM <fmt:formatNumber value="${room.currentPrice}" minFractionDigits="0" maxFractionDigits="2"/></span>
                                            </span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </section>
                        </div>
                    </div>
                </article>
            </div>

            <aside class="booking-summary" aria-label="Booking summary">
                <div class="booking-summary-card">
                    <div class="summary-heading"><h2>Your stay</h2></div>
                    <div class="summary-body">
                        <div class="summary-stay">
                            <div class="summary-stay-item"><span class="summary-label">Check-in</span><span id="summaryCheckIn" class="summary-value">&mdash;</span></div>
                            <div class="summary-stay-item"><span class="summary-label">Check-out</span><span id="summaryCheckOut" class="summary-value">&mdash;</span></div>
                            <div class="summary-stay-item"><span class="summary-label">Nights</span><span id="summaryNights" class="summary-value">1 night</span></div>
                        </div>

                        <div class="selected-room-heading">
                            <strong>Selected rooms</strong>
                            <span id="selectedRoomCount" class="selected-count">0 rooms</span>
                        </div>
                        <p id="selectedRoomEmpty" class="selected-room-empty">Choose a room type, then select an available room number.</p>
                        <ul id="selectedRoomList" class="selected-room-list"></ul>

                        <div class="summary-total">
                            <span class="summary-total-label">Estimated total</span>
                            <strong id="estimatedTotal" class="summary-total-price">RM 0.00</strong>
                        </div>

                        <button id="continuePayment" class="summary-submit" type="submit">Continue to payment</button>
                        <p class="summary-security">
                            <svg aria-hidden="true" viewBox="0 0 24 24"><rect x="5" y="10" width="14" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg>
                            Payment details are entered securely in the next step.
                        </p>
                    </div>
                </div>
                <a class="summary-link" href="${ctx}/customer/bookings">View my bookings</a>
            </aside>
        </div>
    </form>
</div>

<script>
    (function () {
        "use strict";

        var form = document.getElementById("roomBookingForm");
        var checkInInput = document.getElementById("checkInDate");
        var nightsInput = document.getElementById("nights");
        var checkOutDisplay = document.getElementById("checkoutDateDisplay");
        var summaryCheckIn = document.getElementById("summaryCheckIn");
        var summaryCheckOut = document.getElementById("summaryCheckOut");
        var summaryNights = document.getElementById("summaryNights");
        var selectedRoomCount = document.getElementById("selectedRoomCount");
        var selectedRoomEmpty = document.getElementById("selectedRoomEmpty");
        var selectedRoomList = document.getElementById("selectedRoomList");
        var estimatedTotal = document.getElementById("estimatedTotal");
        var continuePayment = document.getElementById("continuePayment");
        var roomCheckboxes = Array.prototype.slice.call(document.querySelectorAll(".room-checkbox"));

        function parseLocalDate(value) {
            var parts = String(value || "").split("-");
            if (parts.length !== 3) {
                return null;
            }
            var date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
            return Number.isNaN(date.getTime()) ? null : date;
        }

        function formatDate(date) {
            if (!date) {
                return "—";
            }
            return new Intl.DateTimeFormat("en-MY", {
                day: "2-digit",
                month: "short",
                year: "numeric"
            }).format(date);
        }

        function normalisedNights() {
            var nights = Number.parseInt(nightsInput.value, 10);
            return Number.isFinite(nights) && nights >= 1 ? nights : 1;
        }

        function updateStayDates() {
            var checkIn = parseLocalDate(checkInInput.value);
            var nights = normalisedNights();
            var checkOut = checkIn ? new Date(checkIn.getTime()) : null;
            if (checkOut) {
                checkOut.setDate(checkOut.getDate() + nights);
            }

            var checkInText = formatDate(checkIn);
            var checkOutText = formatDate(checkOut);
            checkOutDisplay.textContent = checkOutText;
            summaryCheckIn.textContent = checkInText;
            summaryCheckOut.textContent = checkOutText;
            summaryNights.textContent = nights + (nights === 1 ? " night" : " nights");
        }

        function updateRoomCards() {
            document.querySelectorAll("[data-room-card]").forEach(function (card) {
                var hasSelection = Boolean(card.querySelector(".room-checkbox:checked"));
                card.classList.toggle("has-selection", hasSelection);
            });
        }

        function updateSummary() {
            var nights = normalisedNights();
            var selected = roomCheckboxes.filter(function (checkbox) {
                return checkbox.checked;
            });
            var total = selected.reduce(function (sum, checkbox) {
                return sum + (Number.parseFloat(checkbox.dataset.price) || 0) * nights;
            }, 0);

            selectedRoomList.replaceChildren();
            selected.forEach(function (checkbox) {
                var item = document.createElement("li");
                var name = document.createElement("span");
                var amount = document.createElement("strong");
                name.textContent = checkbox.dataset.roomType + " · Room " + checkbox.dataset.roomNumber;
                amount.textContent = "RM " + ((Number.parseFloat(checkbox.dataset.price) || 0) * nights).toFixed(2);
                item.append(name, amount);
                selectedRoomList.appendChild(item);
            });

            selectedRoomCount.textContent = selected.length + (selected.length === 1 ? " room" : " rooms");
            selectedRoomEmpty.hidden = selected.length > 0;
            estimatedTotal.textContent = "RM " + total.toFixed(2);
            continuePayment.disabled = selected.length === 0;
            updateRoomCards();
        }

        document.querySelectorAll(".js-tier-toggle").forEach(function (button) {
            button.addEventListener("click", function () {
                var targetId = button.dataset.target;
                var details = document.getElementById(targetId);
                if (!details) {
                    return;
                }
                var shouldOpen = !details.classList.contains("is-open");
                details.classList.toggle("is-open", shouldOpen);
                details.setAttribute("aria-hidden", String(!shouldOpen));
                document.querySelectorAll("[data-target='" + targetId + "']").forEach(function (toggle) {
                    toggle.setAttribute("aria-expanded", String(shouldOpen));
                    if (toggle.classList.contains("choose-room-button")) {
                        toggle.textContent = shouldOpen ? "Hide options" : "Choose room";
                    }
                });
            });
        });

        roomCheckboxes.forEach(function (checkbox) {
            checkbox.addEventListener("change", updateSummary);
        });
        checkInInput.addEventListener("change", function () {
            updateStayDates();
        });
        nightsInput.addEventListener("input", function () {
            updateStayDates();
            updateSummary();
        });
        form.addEventListener("submit", function (event) {
            if (!roomCheckboxes.some(function (checkbox) { return checkbox.checked; })) {
                event.preventDefault();
            }
        });

        updateStayDates();
        updateSummary();
    })();
</script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
