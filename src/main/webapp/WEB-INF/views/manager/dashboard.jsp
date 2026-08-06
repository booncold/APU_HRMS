<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Manager Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div class="manager-dashboard">
    <section class="dashboard-overview-grid" aria-label="Operational overview">
        <article class="dashboard-panel availability-panel">
            <div class="dashboard-panel-header">
                <div>
                    <p class="dashboard-panel-kicker">Room inventory</p>
                    <h2>Available rooms by type</h2>
                    <p>Current rooms ready for booking across each room category.</p>
                </div>
                <a href="${ctx}/manager/rooms">Manage rooms</a>
            </div>

            <div class="availability-grid">
                <c:forEach var="room" items="${roomAvailability}">
                    <article class="availability-card">
                        <div class="availability-card-top">
                            <div class="availability-room-icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24">
                                    <path d="M3 18v-7"></path>
                                    <path d="M21 18v-5a2 2 0 0 0-2-2H9v7"></path>
                                    <path d="M3 14h18"></path>
                                    <path d="M5 11V8h4a2 2 0 0 1 2 2v1"></path>
                                </svg>
                            </div>
                            <span class="availability-status">
                                <span aria-hidden="true"></span> Live
                            </span>
                        </div>
                        <h3><c:out value="${room.label}"/></h3>
                        <div class="availability-number-row">
                            <strong><c:out value="${room.available}"/></strong>
                            <span>available of <c:out value="${room.total}"/></span>
                        </div>
                        <progress class="availability-progress"
                                  value="${room.available}"
                                  max="${room.progressMax}"
                                  aria-label="${room.label} room availability">
                        </progress>
                        <p><c:out value="${room.unavailable}"/> currently unavailable</p>
                    </article>
                </c:forEach>
            </div>
        </article>

        <article class="dashboard-panel review-panel">
            <div class="dashboard-panel-header">
                <div>
                    <p class="dashboard-panel-kicker">Review inbox</p>
                    <h2>Guest &amp; staff updates</h2>
                    <p>Submitted items ready for manager review.</p>
                </div>
            </div>

            <div class="review-list">
                <a class="review-item" href="${ctx}/manager/comments">
                    <span class="review-item-icon review-item-icon-comment" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M5 5h14v10H9l-4 4V5z"></path>
                            <path d="M8 9h8M8 12h5"></path>
                        </svg>
                    </span>
                    <span class="review-item-copy">
                        <strong>Comments</strong>
                        <small>Customer booking comments</small>
                    </span>
                    <span class="review-item-count"><c:out value="${reviewQueue.comments}"/></span>
                </a>

                <a class="review-item" href="${ctx}/manager/feedbacks">
                    <span class="review-item-icon review-item-icon-feedback" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 3 4 7v5c0 5 3.4 8 8 9 4.6-1 8-4 8-9V7l-8-4z"></path>
                            <path d="m9 12 2 2 4-5"></path>
                        </svg>
                    </span>
                    <span class="review-item-copy">
                        <strong>Feedbacks</strong>
                        <small>Housekeeper room reports</small>
                    </span>
                    <span class="review-item-count"><c:out value="${reviewQueue.feedbacks}"/></span>
                </a>
            </div>

            <div class="review-note">
                <span class="review-note-dot" aria-hidden="true"></span>
                Counts reflect all currently submitted records.
            </div>
        </article>
    </section>

    <section class="dashboard-panel dashboard-chart-section" aria-labelledby="dashboard-chart-title">
        <div class="dashboard-panel-header chart-section-header">
            <div>
                <p class="dashboard-panel-kicker">Performance</p>
                <h2 id="dashboard-chart-title">Key report insights</h2>
                <p>Three high-value charts from the full manager report.</p>
            </div>
            <div class="chart-section-actions">
                <span class="chart-live-label">
                    <span aria-hidden="true"></span> Current data
                </span>
                <a class="dashboard-report-link" href="${ctx}/manager/reports">
                    View full reports <span aria-hidden="true">&#8594;</span>
                </a>
            </div>
        </div>

        <div class="dashboard-chart-grid">
            <article class="dashboard-chart-card">
                <div class="dashboard-chart-card-header">
                    <div>
                        <h3>Occupancy by room type</h3>
                        <p>Booked and occupied rooms as a percentage.</p>
                    </div>
                    <span class="chart-badge">%</span>
                </div>
                <div class="dashboard-chart-frame">
                    <canvas id="dashboardChartType"></canvas>
                </div>
            </article>

            <article class="dashboard-chart-card">
                <div class="dashboard-chart-card-header">
                    <div>
                        <h3>Revenue (14 days)</h3>
                        <p>Daily revenue from completed payments.</p>
                    </div>
                    <span class="chart-badge">RM</span>
                </div>
                <div class="dashboard-chart-frame">
                    <canvas id="dashboardChartRevenue"></canvas>
                </div>
            </article>

            <article class="dashboard-chart-card">
                <div class="dashboard-chart-card-header">
                    <div>
                        <h3>Booking status distribution</h3>
                        <p>All bookings grouped by current status.</p>
                    </div>
                    <span class="chart-badge">#</span>
                </div>
                <div class="dashboard-chart-frame dashboard-chart-frame-doughnut">
                    <canvas id="dashboardChartStatus"></canvas>
                </div>
            </article>
        </div>
    </section>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
    (function () {
        "use strict";

        const occupancyType = ${occupancyTypeJson};
        const revenue = ${revenueJson};
        const bookingStatus = ${statusJson};

        const colours = {
            accent: "#a8793d",
            accentSoft: "rgba(168, 121, 61, 0.18)",
            dark: "#2b241d",
            muted: "#6f6458",
            grid: "rgba(200, 187, 169, 0.32)",
            green: "#3f7650",
            rose: "#a24c43",
            blue: "#56738b",
            sand: "#c8bba9"
        };

        Chart.defaults.color = colours.muted;
        Chart.defaults.font.family = "Arial, Helvetica, sans-serif";

        const sharedPlugins = {
            legend: {
                display: false
            },
            tooltip: {
                backgroundColor: colours.dark,
                titleColor: "#ffffff",
                bodyColor: "#eadfce",
                padding: 11,
                cornerRadius: 8
            }
        };

        new Chart(document.getElementById("dashboardChartType"), {
            type: "bar",
            data: {
                labels: occupancyType.labels,
                datasets: [{
                    label: "Occupancy %",
                    data: occupancyType.values,
                    backgroundColor: [colours.accent, colours.blue, colours.dark],
                    borderRadius: 7,
                    borderSkipped: false,
                    maxBarThickness: 44
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    ...sharedPlugins,
                    tooltip: {
                        ...sharedPlugins.tooltip,
                        callbacks: {
                            label: function (context) {
                                return " Occupancy: " + context.parsed.y + "%";
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: {display: false},
                        border: {display: false}
                    },
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: {
                            callback: function (value) {
                                return value + "%";
                            }
                        },
                        grid: {color: colours.grid},
                        border: {display: false}
                    }
                }
            }
        });

        new Chart(document.getElementById("dashboardChartRevenue"), {
            type: "line",
            data: {
                labels: revenue.labels,
                datasets: [{
                    label: "Revenue (RM)",
                    data: revenue.values,
                    borderColor: colours.accent,
                    backgroundColor: colours.accentSoft,
                    borderWidth: 2.5,
                    pointBackgroundColor: colours.accent,
                    pointBorderColor: "#ffffff",
                    pointBorderWidth: 2,
                    pointRadius: 3,
                    pointHoverRadius: 5,
                    fill: true,
                    tension: 0.32
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {mode: "index", intersect: false},
                plugins: {
                    ...sharedPlugins,
                    tooltip: {
                        ...sharedPlugins.tooltip,
                        callbacks: {
                            label: function (context) {
                                return " RM " + Number(context.parsed.y).toFixed(2);
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: {display: false},
                        border: {display: false},
                        ticks: {maxRotation: 0, autoSkip: true, maxTicksLimit: 7}
                    },
                    y: {
                        beginAtZero: true,
                        grid: {color: colours.grid},
                        border: {display: false},
                        ticks: {
                            callback: function (value) {
                                return "RM " + value;
                            }
                        }
                    }
                }
            }
        });

        const centerLabel = {
            id: "dashboardCenterLabel",
            afterDraw: function (chart) {
                const values = chart.data.datasets[0].data;
                const total = values.reduce(function (sum, value) {
                    return sum + Number(value);
                }, 0);
                const area = chart.chartArea;
                const context = chart.ctx;
                const centerX = (area.left + area.right) / 2;
                const centerY = (area.top + area.bottom) / 2;

                context.save();
                context.textAlign = "center";
                context.textBaseline = "middle";
                context.fillStyle = colours.dark;
                context.font = "700 25px Arial";
                context.fillText(String(total), centerX, centerY - 7);
                context.fillStyle = colours.muted;
                context.font = "12px Arial";
                context.fillText("Bookings", centerX, centerY + 15);
                context.restore();
            }
        };

        new Chart(document.getElementById("dashboardChartStatus"), {
            type: "doughnut",
            data: {
                labels: bookingStatus.labels,
                datasets: [{
                    data: bookingStatus.values,
                    backgroundColor: [
                        colours.accent,
                        colours.green,
                        colours.blue,
                        colours.rose,
                        colours.sand,
                        colours.dark
                    ],
                    borderColor: "#ffffff",
                    borderWidth: 3,
                    hoverOffset: 5
                }]
            },
            plugins: [centerLabel],
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: "68%",
                plugins: {
                    legend: {
                        display: true,
                        position: "bottom",
                        labels: {
                            usePointStyle: true,
                            pointStyle: "circle",
                            boxWidth: 8,
                            boxHeight: 8,
                            padding: 14
                        }
                    },
                    tooltip: sharedPlugins.tooltip
                }
            }
        });
    })();
</script>

<style>
    .manager-dashboard {
        display: grid;
        gap: 22px;
    }

    .dashboard-panel-kicker {
        margin: 0 0 5px;
        color: var(--accent-hover);
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 0.1em;
        text-transform: uppercase;
    }

    .dashboard-report-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        flex: 0 0 auto;
        padding: 10px 14px;
        border: 1px solid var(--card-border);
        border-radius: var(--radius-md);
        background: #ffffff;
        color: var(--main-text);
        font-size: 13px;
        font-weight: 700;
        text-decoration: none;
        transition: border-color 0.15s ease, color 0.15s ease, transform 0.15s ease;
    }

    .dashboard-report-link:hover {
        border-color: var(--accent);
        color: var(--accent-hover);
        transform: translateY(-1px);
    }

    .dashboard-overview-grid {
        display: grid;
        grid-template-columns: minmax(0, 2fr) minmax(300px, 0.85fr);
        gap: 18px;
        align-items: stretch;
    }

    .dashboard-panel {
        min-width: 0;
        padding: 20px;
        border: 1px solid var(--card-border);
        border-radius: 14px;
        background: #ffffff;
        box-shadow: 0 8px 24px rgba(43, 36, 29, 0.045);
    }

    .dashboard-panel-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 18px;
        margin-bottom: 18px;
    }

    .dashboard-panel-header h2 {
        margin: 0;
        color: var(--main-text);
        font-family: var(--font-display);
        font-size: 21px;
    }

    .dashboard-panel-header p:not(.dashboard-panel-kicker) {
        margin: 6px 0 0;
        color: var(--muted-text);
        font-size: 13px;
        line-height: 1.45;
    }

    .dashboard-panel-header > a {
        flex: 0 0 auto;
        color: var(--accent-hover);
        font-size: 13px;
        font-weight: 700;
        text-decoration: none;
    }

    .dashboard-panel-header > a:hover {
        text-decoration: underline;
    }

    .availability-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 13px;
    }

    .availability-card {
        min-width: 0;
        padding: 16px;
        border: 1px solid #e5dccf;
        border-radius: 12px;
        background: linear-gradient(145deg, #fff 0%, #fbf8f3 100%);
    }

    .availability-card-top {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
    }

    .availability-room-icon,
    .review-item-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }

    .availability-room-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        background: rgba(168, 121, 61, 0.13);
        color: var(--accent-hover);
    }

    .availability-room-icon svg,
    .review-item-icon svg {
        width: 20px;
        height: 20px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .availability-status {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        color: #477353;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
    }

    .availability-status > span,
    .chart-live-label > span,
    .review-note-dot {
        width: 7px;
        height: 7px;
        border-radius: 50%;
        background: #5c946a;
        box-shadow: 0 0 0 3px rgba(92, 148, 106, 0.14);
    }

    .availability-card h3 {
        margin: 15px 0 5px;
        color: var(--label-text);
        font-size: 13px;
        font-weight: 700;
    }

    .availability-number-row {
        display: flex;
        align-items: baseline;
        gap: 7px;
        margin-bottom: 12px;
    }

    .availability-number-row strong {
        color: var(--main-text);
        font-family: var(--font-display);
        font-size: 31px;
        line-height: 1;
    }

    .availability-number-row span,
    .availability-card > p {
        color: var(--muted-text);
        font-size: 12px;
    }

    .availability-progress {
        display: block;
        width: 100%;
        height: 7px;
        overflow: hidden;
        border: 0;
        border-radius: 999px;
        background: #e9e1d6;
    }

    .availability-progress::-webkit-progress-bar {
        border-radius: 999px;
        background: #e9e1d6;
    }

    .availability-progress::-webkit-progress-value {
        border-radius: 999px;
        background: linear-gradient(90deg, var(--accent-hover), var(--accent));
    }

    .availability-progress::-moz-progress-bar {
        border-radius: 999px;
        background: linear-gradient(90deg, var(--accent-hover), var(--accent));
    }

    .availability-card > p {
        margin: 9px 0 0;
    }

    .review-list {
        display: grid;
        gap: 11px;
    }

    .review-item {
        display: grid;
        grid-template-columns: auto minmax(0, 1fr) auto;
        align-items: center;
        gap: 12px;
        padding: 14px;
        border: 1px solid #e5dccf;
        border-radius: 11px;
        color: var(--main-text);
        text-decoration: none;
        transition: border-color 0.15s ease, background-color 0.15s ease, transform 0.15s ease;
    }

    .review-item:hover {
        border-color: var(--accent);
        background: #fcf8f2;
        transform: translateY(-1px);
    }

    .review-item-icon {
        width: 40px;
        height: 40px;
        border-radius: 11px;
    }

    .review-item-icon-comment {
        background: rgba(86, 115, 139, 0.13);
        color: #49677f;
    }

    .review-item-icon-feedback {
        background: rgba(168, 121, 61, 0.14);
        color: var(--accent-hover);
    }

    .review-item-copy {
        min-width: 0;
        display: flex;
        flex-direction: column;
        gap: 3px;
    }

    .review-item-copy strong {
        font-size: 14px;
    }

    .review-item-copy small {
        overflow: hidden;
        color: var(--muted-text);
        font-size: 11px;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .review-item-count {
        min-width: 38px;
        color: var(--main-text);
        font-family: var(--font-display);
        font-size: 27px;
        font-weight: 700;
        text-align: right;
    }

    .review-note {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-top: 15px;
        padding-top: 14px;
        border-top: 1px solid #eee7dd;
        color: var(--muted-text);
        font-size: 11px;
        line-height: 1.4;
    }

    .review-note-dot {
        flex: 0 0 7px;
    }

    .dashboard-chart-section {
        padding-bottom: 18px;
    }

    .chart-section-header {
        align-items: center;
    }

    .chart-section-actions {
        display: flex;
        align-items: center;
        gap: 10px;
        flex: 0 0 auto;
    }

    .chart-live-label {
        display: inline-flex;
        align-items: center;
        gap: 7px;
        flex: 0 0 auto;
        padding: 7px 10px;
        border-radius: 999px;
        background: #f5f0e8;
        color: var(--label-text);
        font-size: 11px;
        font-weight: 700;
    }

    .dashboard-chart-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 14px;
    }

    .dashboard-chart-card {
        min-width: 0;
        padding: 16px;
        border: 1px solid #e8dfd3;
        border-radius: 12px;
        background: #fdfbf8;
    }

    .dashboard-chart-card-header {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 12px;
    }

    .dashboard-chart-card h3 {
        margin: 0;
        color: var(--main-text);
        font-size: 15px;
    }

    .dashboard-chart-card p {
        margin: 5px 0 0;
        color: var(--muted-text);
        font-size: 11px;
        line-height: 1.4;
    }

    .chart-badge {
        min-width: 30px;
        padding: 5px 7px;
        border-radius: 7px;
        background: rgba(168, 121, 61, 0.12);
        color: var(--accent-hover);
        font-size: 11px;
        font-weight: 700;
        text-align: center;
    }

    .dashboard-chart-frame {
        position: relative;
        height: 250px;
    }

    .dashboard-chart-frame-doughnut {
        height: 270px;
    }

    @media (max-width: 1380px) {
        .dashboard-overview-grid {
            grid-template-columns: 1fr;
        }

        .review-list {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .review-note {
            grid-column: 1 / -1;
        }

        .dashboard-chart-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .dashboard-chart-card:last-child {
            grid-column: 1 / -1;
        }
    }

    @media (max-width: 900px) {
        .dashboard-panel-header {
            align-items: flex-start;
            flex-direction: column;
        }

        .chart-section-actions {
            width: 100%;
            flex-wrap: wrap;
        }

        .availability-grid,
        .review-list,
        .dashboard-chart-grid {
            grid-template-columns: 1fr;
        }

        .dashboard-chart-card:last-child {
            grid-column: auto;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
