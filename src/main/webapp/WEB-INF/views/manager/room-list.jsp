<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Rooms & Pricing" scope="request"/>
<c:set var="activeMenu" value="rooms" scope="request"/>
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

<div class="room-filter-panel">
    <form class="room-filter-form" method="get" action="${ctx}/manager/rooms">
        <label class="room-control-group" for="roomFilterType">
            <span>Room type</span>
            <span class="room-select-shell">
                <select class="room-select" id="roomFilterType" name="type">
                    <option value="">All room types</option>
                    <c:forEach var="type" items="${roomTypes}">
                        <option value="${type}" ${filterType == type.name() ? 'selected' : ''}>
                            <c:out value="${type.displayName}"/>
                        </option>
                    </c:forEach>
                </select>
            </span>
        </label>

        <label class="room-control-group" for="roomFilterFloor">
            <span>Floor</span>
            <span class="room-select-shell">
                <select class="room-select" id="roomFilterFloor" name="floor">
                    <option value="">All floors</option>
                    <c:forEach var="f" begin="1" end="5">
                        <option value="${f}" ${filterFloor == f ? 'selected' : ''}>
                            Floor <c:out value="${f}"/>
                        </option>
                    </c:forEach>
                </select>
            </span>
        </label>

        <label class="room-control-group" for="roomFilterStatus">
            <span>Room status</span>
            <span class="room-select-shell">
                <select class="room-select" id="roomFilterStatus" name="status">
                    <option value="">All statuses</option>
                    <c:forEach var="st" items="${roomStatuses}">
                        <option value="${st}" ${filterStatus == st.name() ? 'selected' : ''}>
                            <c:out value="${st.displayName}"/>
                        </option>
                    </c:forEach>
                </select>
            </span>
        </label>

        <div class="room-filter-actions">
            <button class="btn-primary" type="submit">Apply filters</button>
            <a class="btn-secondary" href="${ctx}/manager/rooms">Reset</a>
        </div>
    </form>
</div>

<section class="form-panel bulk-price-panel">
    <h2 class="list-section-title" style="margin-bottom: 12px;">Bulk price by type</h2>
    <p class="field-hint" style="margin-bottom: 14px;">
        Applies the new current price to every room of that type. Existing bookings keep their snapshot prices.
    </p>
    <form class="bulk-price-form" method="post" action="${ctx}/manager/rooms/price">
        <input type="hidden" name="mode" value="type">
        <label class="room-control-group" for="bulkRoomType">
            <span>Room type</span>
            <span class="room-select-shell">
                <select class="room-select" id="bulkRoomType" name="roomType" required>
                    <c:forEach var="type" items="${roomTypes}">
                        <option value="${type}"><c:out value="${type.displayName}"/></option>
                    </c:forEach>
                </select>
            </span>
        </label>
        <label class="room-control-group" for="bulkRoomPrice">
            <span>New nightly price</span>
            <span class="room-price-shell">
                <span class="room-price-prefix">RM</span>
                <input class="room-price-input"
                       id="bulkRoomPrice"
                       type="number"
                       name="price"
                       min="1"
                       step="0.01"
                       placeholder="0.00"
                       required>
            </span>
        </label>
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
                <col class="col-price">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Status</th>
                <th>Price / night</th>
                <th>Update price</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty standardRooms}">
                    <tr><td colspan="5" class="empty-row">No standard rooms match filters.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="room" items="${standardRooms}">
                        <tr class="live-search-row">
                            <td><c:out value="${room.roomNumber}"/></td>
                            <td><c:out value="${room.floor}"/></td>
                            <td><c:out value="${room.status.displayName}"/></td>
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
                        <td colspan="5">No matching standard rooms.</td>
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
                <col class="col-price">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Status</th>
                <th>Price / night</th>
                <th>Update price</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty vipRooms}">
                    <tr><td colspan="5" class="empty-row">No VIP rooms match filters.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="room" items="${vipRooms}">
                        <tr class="live-search-row">
                            <td><c:out value="${room.roomNumber}"/></td>
                            <td><c:out value="${room.floor}"/></td>
                            <td><c:out value="${room.status.displayName}"/></td>
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
                        <td colspan="5">No matching VIP rooms.</td>
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
                <col class="col-price">
                <col class="col-actions">
            </colgroup>
            <thead>
            <tr>
                <th>Room</th>
                <th>Floor</th>
                <th>Status</th>
                <th>Price / night</th>
                <th>Update price</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty presidentialRooms}">
                    <tr><td colspan="5" class="empty-row">No presidential rooms match filters.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="room" items="${presidentialRooms}">
                        <tr class="live-search-row">
                            <td><c:out value="${room.roomNumber}"/></td>
                            <td><c:out value="${room.floor}"/></td>
                            <td><c:out value="${room.status.displayName}"/></td>
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
                        <td colspan="5">No matching presidential rooms.</td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

</div>

<style>
    .room-filter-panel {
        margin-bottom: 20px;
        padding: 16px 18px;
        border: 1px solid var(--card-border);
        border-radius: 12px;
        background: #ffffff;
        box-shadow: 0 6px 18px rgba(43, 36, 29, 0.035);
    }

    .room-filter-form {
        display: grid;
        grid-template-columns: repeat(3, minmax(160px, 1fr)) auto;
        align-items: end;
        gap: 12px;
    }

    .room-control-group {
        min-width: 0;
        display: grid;
        gap: 7px;
        color: var(--label-text);
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 0.055em;
        text-transform: uppercase;
    }

    .room-select-shell,
    .room-price-shell {
        position: relative;
        display: block;
        min-width: 0;
    }

    .room-select-shell::after {
        content: "";
        position: absolute;
        top: 50%;
        right: 16px;
        width: 7px;
        height: 7px;
        border-right: 2px solid var(--muted-text);
        border-bottom: 2px solid var(--muted-text);
        pointer-events: none;
        transform: translateY(-70%) rotate(45deg);
    }

    .room-select,
    .room-price-input {
        width: 100%;
        height: 46px;
        border: 1px solid var(--border-colour);
        border-radius: 10px;
        background-color: #ffffff;
        color: var(--main-text);
        font: inherit;
        font-size: 14px;
        font-weight: 500;
        letter-spacing: normal;
        text-transform: none;
        transition: border-color 0.15s ease, box-shadow 0.15s ease, background-color 0.15s ease;
    }

    .room-select {
        -webkit-appearance: none;
        appearance: none;
        padding: 0 42px 0 14px;
        cursor: pointer;
    }

    .room-select:hover,
    .room-price-input:hover {
        border-color: var(--accent);
        background-color: #fefcf9;
    }

    .room-select:focus,
    .room-price-input:focus {
        outline: none;
        border-color: var(--accent);
        box-shadow: 0 0 0 3px rgba(168, 121, 61, 0.15);
    }

    .room-filter-actions {
        display: flex;
        align-items: center;
        gap: 9px;
    }

    .room-filter-actions .btn-primary,
    .room-filter-actions .btn-secondary,
    .bulk-price-form > .btn-primary {
        min-height: 46px;
        white-space: nowrap;
    }

    .bulk-price-panel {
        max-width: none;
        margin-bottom: 24px;
        border-radius: 12px;
    }

    .bulk-price-form {
        display: grid;
        grid-template-columns: minmax(190px, 250px) minmax(220px, 300px) auto;
        align-items: end;
        gap: 12px;
    }

    .room-price-prefix {
        position: absolute;
        top: 50%;
        left: 14px;
        z-index: 1;
        color: var(--muted-text);
        font-size: 13px;
        font-weight: 700;
        letter-spacing: normal;
        pointer-events: none;
        transform: translateY(-50%);
    }

    .room-price-input {
        padding: 0 14px 0 45px;
    }

    @media (max-width: 1160px) {
        .room-filter-form {
            grid-template-columns: repeat(2, minmax(180px, 1fr));
        }

        .room-filter-actions {
            align-self: end;
        }
    }

    @media (max-width: 720px) {
        .room-filter-form,
        .bulk-price-form {
            grid-template-columns: 1fr;
        }

        .room-filter-actions {
            flex-wrap: wrap;
        }

        .room-filter-actions .btn-primary,
        .room-filter-actions .btn-secondary,
        .bulk-price-form > .btn-primary {
            flex: 1 1 auto;
        }
    }
</style>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
