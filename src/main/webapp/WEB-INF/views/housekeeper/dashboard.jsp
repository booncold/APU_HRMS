<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Housekeeper Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div class="housekeeper-dashboard">
    <section class="hk-metric-grid" aria-label="Housekeeping status summary">
        <article class="hk-metric-card metric-required">
            <span class="hk-metric-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24">
                    <path d="m14 4 6 6"></path>
                    <path d="m12 6 6 6"></path>
                    <path d="M5 19c3-1 5-3 7-7l2-2 4 4-2 2c-4 2-6 4-7 7"></path>
                </svg>
            </span>
            <div>
                <p>Cleaning required</p>
                <strong><c:out value="${cleaningRoomCount}"/></strong>
                <span>rooms in the hotel</span>
            </div>
        </article>

        <article class="hk-metric-card metric-mine">
            <span class="hk-metric-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24">
                    <path d="M8 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z"></path>
                    <path d="M2 21v-3a5 5 0 0 1 5-5h2a5 5 0 0 1 5 5v3"></path>
                    <path d="m16 16 2 2 4-5"></path>
                </svg>
            </span>
            <div>
                <p>Assigned to you</p>
                <strong><c:out value="${myOpenTaskCount}"/></strong>
                <span>open cleaning tasks</span>
            </div>
        </article>

        <article class="hk-metric-card metric-floors">
            <span class="hk-metric-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24">
                    <path d="M4 21h16"></path>
                    <path d="M6 21V4h12v17"></path>
                    <path d="M9 8h2"></path>
                    <path d="M13 8h2"></path>
                    <path d="M9 12h2"></path>
                    <path d="M13 12h2"></path>
                    <path d="M9 16h2"></path>
                    <path d="M13 16h2"></path>
                </svg>
            </span>
            <div>
                <p>Floors affected</p>
                <strong><c:out value="${affectedFloorCount}"/></strong>
                <span>of 5 hotel floors</span>
            </div>
        </article>
    </section>

    <div class="hk-dashboard-grid">
        <section class="hotel-map-panel" aria-labelledby="hotel-map-title">
            <div class="hk-panel-header hotel-map-header">
                <div>
                    <p class="hk-panel-kicker">Hotel overview</p>
                    <h2 id="hotel-map-title">Room cleaning map</h2>
                </div>
                <div class="room-map-legend" aria-label="Room cleaning legend">
                    <span><i class="legend-swatch legend-mine"></i>Assigned to you</span>
                    <span><i class="legend-swatch legend-cleaning"></i>Cleaning required</span>
                    <span><i class="legend-swatch legend-clear"></i>No cleaning needed</span>
                </div>
            </div>

            <div class="hotel-building">
                <div class="hotel-building-top">
                    <span>APU HOTEL</span>
                    <small>HOUSEKEEPING MAP</small>
                </div>

                <c:forEach var="floor" items="${floorNumbers}">
                    <section class="hotel-floor" aria-label="Floor ${floor}">
                        <div class="floor-number">
                            <strong><c:out value="${floor}"/>F</strong>
                            <span>Floor</span>
                        </div>
                        <div class="floor-doors">
                            <c:forEach var="room" items="${roomsByFloor[floor]}">
                                <c:set var="needsCleaning" value="${cleaningRoomIds[room.id]}"/>
                                <c:set var="myTask" value="${myTasksByRoomId[room.id]}"/>
                                <div class="room-door-card ${not empty myTask ? 'is-mine' : needsCleaning ? 'needs-cleaning' : ''}"
                                     title="Room ${room.roomNumber} — ${not empty myTask ? 'Assigned to you' : needsCleaning ? 'Cleaning required' : 'No cleaning needed'}">
                                    <div class="room-door">
                                        <span class="room-door-number"><c:out value="${room.roomNumber}"/></span>
                                        <span class="room-door-panel" aria-hidden="true"></span>
                                    </div>
                                    <span class="room-door-label">
                                        <c:choose>
                                            <c:when test="${not empty myTask}">Your task</c:when>
                                            <c:when test="${needsCleaning}">Clean</c:when>
                                            <c:otherwise>Clear</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </c:forEach>
                        </div>
                    </section>
                </c:forEach>
            </div>
        </section>

        <aside class="hk-task-panel" aria-labelledby="cleaning-list-title">
            <div class="hk-panel-header">
                <div>
                    <p class="hk-panel-kicker">My assignments</p>
                    <h2 id="cleaning-list-title">Rooms to clean</h2>
                </div>
                <span class="hk-task-count"><c:out value="${fn:length(openTasks)}"/></span>
            </div>

            <div class="hk-task-list">
                <c:choose>
                    <c:when test="${empty openTasks}">
                        <div class="hk-empty-state">
                            <span class="hk-empty-icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24">
                                    <path d="M4 12.5 9 17l11-11"></path>
                                </svg>
                            </span>
                            <strong>No rooms assigned</strong>
                            <p>You are currently free for a new cleaning assignment.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="task" items="${openTasks}">
                            <article class="hk-task-item">
                                <div class="hk-task-room-row">
                                    <div>
                                        <span class="hk-task-floor">Floor <c:out value="${task.room.floor}"/></span>
                                        <h3>Room <c:out value="${task.room.roomNumber}"/></h3>
                                    </div>
                                    <span class="hk-task-status">Needs cleaning</span>
                                </div>
                                <dl class="hk-task-details">
                                    <div>
                                        <dt>Room type</dt>
                                        <dd><c:out value="${task.room.roomType.displayName}"/></dd>
                                    </div>
                                    <div>
                                        <dt>Assigned at</dt>
                                        <dd><c:out value="${task.assignedAtDisplay}"/></dd>
                                    </div>
                                    <div>
                                        <dt>Assigned by</dt>
                                        <dd><c:out value="${task.assignedBy.name}"/></dd>
                                    </div>
                                </dl>
                                <div class="hk-task-notes">
                                    <span>Notes</span>
                                    <p><c:out value="${empty task.notes ? 'No notes provided.' : task.notes}"/></p>
                                </div>
                            </article>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="hk-task-actions">
                <a class="btn-primary" href="${ctx}/housekeeper/tasks">Open My Tasks</a>
                <a class="btn-secondary" href="${ctx}/housekeeper/feedback">Write Feedback</a>
            </div>
        </aside>
    </div>
</div>

<style>
    .housekeeper-dashboard {
        display: grid;
        gap: 20px;
    }

    .hk-metric-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 14px;
    }

    .hk-metric-card {
        --metric-colour: var(--accent-hover);
        --metric-soft: rgba(168, 121, 61, 0.13);
        min-width: 0;
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 17px 18px;
        border: 1px solid var(--card-border);
        border-radius: 13px;
        background: #ffffff;
        box-shadow: 0 7px 22px rgba(43, 36, 29, 0.04);
    }

    .metric-required {
        --metric-colour: #b46b2e;
        --metric-soft: #f8eadb;
    }

    .metric-mine {
        --metric-colour: #a8493e;
        --metric-soft: #fae8e5;
    }

    .metric-floors {
        --metric-colour: #557086;
        --metric-soft: #e8eef2;
    }

    .hk-metric-icon {
        width: 46px;
        height: 46px;
        flex: 0 0 46px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 12px;
        background: var(--metric-soft);
        color: var(--metric-colour);
    }

    .hk-metric-icon svg,
    .hk-empty-icon svg {
        width: 23px;
        height: 23px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .hk-metric-card p {
        margin: 0 0 3px;
        color: var(--label-text);
        font-size: 12px;
        font-weight: 700;
    }

    .hk-metric-card strong {
        margin-right: 6px;
        color: var(--main-text);
        font-size: 28px;
        line-height: 1;
    }

    .hk-metric-card > div > span {
        color: var(--muted-text);
        font-size: 11px;
    }

    .hk-dashboard-grid {
        min-width: 0;
        display: grid;
        grid-template-columns: minmax(0, 1.7fr) minmax(310px, 0.7fr);
        align-items: start;
        gap: 18px;
    }

    .hotel-map-panel,
    .hk-task-panel {
        min-width: 0;
        padding: 20px;
        border: 1px solid var(--card-border);
        border-radius: 14px;
        background: #ffffff;
        box-shadow: 0 8px 24px rgba(43, 36, 29, 0.045);
    }

    .hk-task-panel {
        position: sticky;
        top: 88px;
    }

    .hk-panel-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 17px;
    }

    .hk-panel-kicker {
        margin: 0 0 4px;
        color: var(--accent-hover);
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 0.1em;
        text-transform: uppercase;
    }

    .hk-panel-header h2 {
        margin: 0;
        color: var(--main-text);
        font-size: 20px;
    }

    .room-map-legend {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        flex-wrap: wrap;
        gap: 8px 13px;
        color: var(--muted-text);
        font-size: 10px;
        font-weight: 600;
    }

    .room-map-legend > span {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
    }

    .legend-swatch {
        width: 9px;
        height: 9px;
        display: inline-block;
        border: 1px solid transparent;
        border-radius: 50%;
    }

    .legend-mine {
        background: #a8493e;
        border-color: #87362e;
    }

    .legend-cleaning {
        background: #efc792;
        border-color: #c98639;
    }

    .legend-clear {
        background: #e9e5df;
        border-color: #c9c1b7;
    }

    .hotel-building {
        overflow: hidden;
        border: 1px solid #cbbca8;
        border-radius: 12px;
        background: #e7ded1;
        box-shadow: inset 0 0 0 4px rgba(255, 255, 255, 0.4);
    }

    .hotel-building-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 11px 17px;
        border-bottom: 3px solid #6f6255;
        background: #332b24;
        color: #ffffff;
    }

    .hotel-building-top span {
        font-size: 13px;
        font-weight: 800;
        letter-spacing: 0.12em;
    }

    .hotel-building-top small {
        color: #d8c6ad;
        font-size: 9px;
        font-weight: 700;
        letter-spacing: 0.11em;
    }

    .hotel-floor {
        display: grid;
        grid-template-columns: 64px minmax(0, 1fr);
        min-width: 0;
        border-bottom: 3px solid #827668;
        background: linear-gradient(180deg, #f7f2eb 0%, #ede4d7 100%);
    }

    .hotel-floor:last-child {
        border-bottom: 0;
    }

    .floor-number {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        border-right: 1px solid #cbbca8;
        background: rgba(255, 255, 255, 0.48);
        color: var(--main-text);
    }

    .floor-number strong {
        font-size: 18px;
    }

    .floor-number span {
        margin-top: 2px;
        color: var(--muted-text);
        font-size: 8px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    .floor-doors {
        min-width: 0;
        display: grid;
        grid-template-columns: repeat(10, minmax(48px, 1fr));
        gap: 7px;
        padding: 10px;
    }

    .room-door-card {
        --door-colour: #f4f1ec;
        --door-border: #bcb3a9;
        --door-text: #51473d;
        --door-accent: #aaa198;
        min-width: 0;
        display: grid;
        gap: 4px;
        text-align: center;
    }

    .room-door-card.needs-cleaning {
        --door-colour: #f5d6ad;
        --door-border: #c98335;
        --door-text: #7d4618;
        --door-accent: #b45f20;
    }

    .room-door-card.is-mine {
        --door-colour: #ad5045;
        --door-border: #7f332c;
        --door-text: #ffffff;
        --door-accent: #ffe1b8;
    }

    .room-door {
        position: relative;
        min-width: 0;
        height: 67px;
        overflow: hidden;
        border: 1px solid var(--door-border);
        border-bottom-width: 3px;
        border-radius: 8px 8px 3px 3px;
        background: var(--door-colour);
        color: var(--door-text);
        box-shadow: 0 3px 7px rgba(43, 36, 29, 0.1);
    }

    .room-door-number {
        position: relative;
        z-index: 2;
        display: block;
        padding-top: 8px;
        font-size: 11px;
        font-weight: 800;
    }

    .room-door-panel {
        position: absolute;
        top: 28px;
        right: 10px;
        bottom: 9px;
        left: 10px;
        border: 1px solid color-mix(in srgb, var(--door-border) 72%, transparent);
        border-radius: 3px;
        opacity: 0.72;
    }

    .room-door-label {
        overflow: hidden;
        color: var(--door-text);
        font-size: 8px;
        font-weight: 800;
        letter-spacing: 0.035em;
        text-overflow: ellipsis;
        text-transform: uppercase;
        white-space: nowrap;
    }

    .hk-task-count {
        min-width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        background: #fae8e5;
        color: #a8493e;
        font-size: 14px;
        font-weight: 800;
    }

    .hk-task-list {
        display: grid;
        gap: 12px;
    }

    .hk-task-item {
        padding: 15px;
        border: 1px solid #e4d8ca;
        border-left: 4px solid #a8493e;
        border-radius: 11px;
        background: #fdfbf8;
    }

    .hk-task-room-row {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 10px;
    }

    .hk-task-floor {
        color: var(--accent-hover);
        font-size: 9px;
        font-weight: 800;
        letter-spacing: 0.08em;
        text-transform: uppercase;
    }

    .hk-task-room-row h3 {
        margin: 3px 0 0;
        font-size: 19px;
    }

    .hk-task-status {
        padding: 5px 8px;
        border-radius: 999px;
        background: #fae8e5;
        color: #9d4137;
        font-size: 9px;
        font-weight: 800;
        text-transform: uppercase;
        white-space: nowrap;
    }

    .hk-task-details {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
        margin: 14px 0 0;
    }

    .hk-task-details > div:last-child {
        grid-column: 1 / -1;
    }

    .hk-task-details dt,
    .hk-task-notes > span {
        margin-bottom: 3px;
        color: var(--muted-text);
        font-size: 9px;
        font-weight: 800;
        letter-spacing: 0.06em;
        text-transform: uppercase;
    }

    .hk-task-details dd {
        margin: 0;
        color: var(--main-text);
        font-size: 11px;
        font-weight: 600;
    }

    .hk-task-notes {
        margin-top: 12px;
        padding-top: 10px;
        border-top: 1px solid #eadfd2;
    }

    .hk-task-notes p {
        margin: 4px 0 0;
        color: var(--label-text);
        font-size: 11px;
        line-height: 1.45;
    }

    .hk-empty-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 31px 18px;
        border: 1px dashed #d7c9b9;
        border-radius: 12px;
        background: #fbf8f3;
        text-align: center;
    }

    .hk-empty-icon {
        width: 48px;
        height: 48px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 11px;
        border-radius: 50%;
        background: #eaf3ec;
        color: #3f7650;
    }

    .hk-empty-state strong {
        font-size: 14px;
    }

    .hk-empty-state p {
        max-width: 240px;
        margin: 6px 0 0;
        color: var(--muted-text);
        font-size: 11px;
        line-height: 1.5;
    }

    .hk-task-actions {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 9px;
        margin-top: 15px;
        padding-top: 15px;
        border-top: 1px solid #ece3d8;
    }

    .hk-task-actions .btn-primary,
    .hk-task-actions .btn-secondary {
        justify-content: center;
        text-align: center;
    }

    @media (max-width: 1250px) {
        .hk-dashboard-grid {
            grid-template-columns: 1fr;
        }

        .hk-task-panel {
            position: static;
        }
    }

    @media (max-width: 850px) {
        .hk-metric-grid {
            grid-template-columns: 1fr;
        }

        .hotel-map-header {
            align-items: flex-start;
            flex-direction: column;
        }

        .room-map-legend {
            justify-content: flex-start;
        }

        .hotel-building {
            overflow-x: auto;
        }

        .hotel-floor,
        .hotel-building-top {
            min-width: 760px;
        }
    }

    @media (max-width: 560px) {
        .hotel-map-panel,
        .hk-task-panel {
            padding: 15px;
        }

        .hk-task-actions {
            grid-template-columns: 1fr;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
