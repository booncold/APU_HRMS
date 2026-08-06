<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Reports" scope="request"/>
<c:set var="activeMenu" value="reports" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<section class="report-period-toolbar" aria-label="Report period selector">
    <div class="report-period-current">
        <span class="report-period-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24">
                <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                <path d="M16 3v4M8 3v4M3 10h18"></path>
            </svg>
        </span>
        <div>
            <span>Report period</span>
            <strong><c:out value="${periodLabel}"/></strong>
            <small><c:out value="${periodDateDisplay}"/></small>
        </div>
    </div>

    <nav class="report-period-options" aria-label="Select report period">
        <a class="report-period-option ${selectedRange == 'day' ? 'is-active' : ''}"
           href="${ctx}/manager/reports?range=day">Day</a>
        <a class="report-period-option ${selectedRange == 'week' ? 'is-active' : ''}"
           href="${ctx}/manager/reports?range=week">Week</a>
        <a class="report-period-option ${selectedRange == 'month' ? 'is-active' : ''}"
           href="${ctx}/manager/reports?range=month">Month</a>
    </nav>
</section>

<section class="report-summary" aria-label="Summary cards">
    <article class="report-card">
        <strong>New customers</strong>
        <span><c:out value="${summary.newCustomers}"/></span>
        <small><c:out value="${periodLabel}"/></small>
    </article>
    <article class="report-card">
        <strong>New bookings</strong>
        <span><c:out value="${summary.orders}"/></span>
        <small><c:out value="${periodLabel}"/></small>
    </article>
    <article class="report-card">
        <strong>Occupied room nights</strong>
        <span><c:out value="${summary.roomNights}"/></span>
        <small><c:out value="${periodLabel}"/></small>
    </article>
    <article class="report-card">
        <strong>Cleaning completed</strong>
        <span><c:out value="${summary.completedTasks}"/></span>
        <small><c:out value="${periodLabel}"/></small>
    </article>
    <article class="report-card">
        <strong>Paid revenue</strong>
        <span>
            RM
            <fmt:formatNumber value="${summary.paidRevenue}"
                              minFractionDigits="2"
                              maxFractionDigits="2"/>
        </span>
        <small><c:out value="${periodLabel}"/></small>
    </article>
</section>

<section class="report-grid">
    <article class="report-panel">
        <header class="report-panel-heading">
            <h2>1. Occupancy by floor</h2>
            <span><c:out value="${periodLabel}"/></span>
        </header>
        <canvas id="chartFloor" height="220"></canvas>
    </article>
    <article class="report-panel">
        <header class="report-panel-heading">
            <h2>2. Occupancy by room type</h2>
            <span><c:out value="${periodLabel}"/></span>
        </header>
        <canvas id="chartType" height="220"></canvas>
    </article>
    <article class="report-panel">
        <header class="report-panel-heading">
            <h2>3. Paid revenue</h2>
            <span><c:out value="${periodLabel}"/></span>
        </header>
        <canvas id="chartRevenue" height="220"></canvas>
    </article>
    <article class="report-panel">
        <header class="report-panel-heading">
            <h2>4. Booking status distribution</h2>
            <span><c:out value="${periodLabel}"/></span>
        </header>
        <canvas id="chartStatus" height="220"></canvas>
    </article>
    <article class="report-panel">
        <header class="report-panel-heading">
            <h2>5. Housekeeper completions</h2>
            <span><c:out value="${periodLabel}"/></span>
        </header>
        <canvas id="chartHk" height="220"></canvas>
    </article>
    <article class="report-panel">
        <header class="report-panel-heading">
            <h2>6. Customer engagement</h2>
            <span><c:out value="${periodLabel}"/></span>
        </header>
        <canvas id="chartActivity" height="220"></canvas>
    </article>
</section>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
    const COLORS = {
        accent: '#a8793d',
        dark: '#2b241d',
        muted: '#6f6458',
        soft: '#c8bba9',
        green: '#2f6b3a',
        rose: '#8b3028',
        cream: '#eadfce'
    };

    const palette = [
        COLORS.accent, COLORS.dark, COLORS.muted, COLORS.green,
        COLORS.rose, '#865c2c', '#b8a994', '#51473d'
    ];

    function baseOptions(title) {
        return {
            responsive: true,
            plugins: {
                legend: { labels: { color: COLORS.dark } },
                title: { display: false, text: title }
            },
            scales: {
                x: {
                    ticks: { color: COLORS.muted },
                    grid: { color: 'rgba(200,187,169,0.35)' }
                },
                y: {
                    beginAtZero: true,
                    ticks: { color: COLORS.muted },
                    grid: { color: 'rgba(200,187,169,0.35)' }
                }
            }
        };
    }

    function barChart(el, data, label, maximum) {
        const options = baseOptions(data.title);
        if (maximum) {
            options.scales.y.max = maximum;
            options.scales.y.ticks.callback = function (value) {
                return value + '%';
            };
        }
        return new Chart(el, {
            type: 'bar',
            data: {
                labels: data.labels,
                datasets: [{
                    label: label,
                    data: data.values,
                    backgroundColor: COLORS.accent,
                    borderRadius: 6
                }]
            },
            options: options
        });
    }

    function lineChart(el, data, label) {
        return new Chart(el, {
            type: 'line',
            data: {
                labels: data.labels,
                datasets: [{
                    label: label,
                    data: data.values,
                    borderColor: COLORS.accent,
                    backgroundColor: 'rgba(168,121,61,0.18)',
                    fill: true,
                    tension: 0.25
                }]
            },
            options: baseOptions(data.title)
        });
    }

    function pieChart(el, data) {
        return new Chart(el, {
            type: 'pie',
            data: {
                labels: data.labels,
                datasets: [{
                    data: data.values,
                    backgroundColor: palette
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom', labels: { color: COLORS.dark } }
                }
            }
        });
    }

    const floor = ${occupancyFloorJson};
    const type = ${occupancyTypeJson};
    const revenue = ${revenueJson};
    const status = ${statusJson};
    const hk = ${hkJson};
    const activity = ${activityJson};

    barChart(document.getElementById('chartFloor'), floor, 'Occupancy %', 100);
    barChart(document.getElementById('chartType'), type, 'Occupancy %', 100);
    lineChart(document.getElementById('chartRevenue'), revenue, 'RM');
    pieChart(document.getElementById('chartStatus'), status);
    barChart(document.getElementById('chartHk'), hk, 'Completed tasks');
    pieChart(document.getElementById('chartActivity'), activity);
</script>

<style>
    .report-period-toolbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        margin-bottom: 18px;
        padding: 16px 18px;
        border: 1px solid var(--card-border);
        border-radius: 12px;
        background: #ffffff;
        box-shadow: 0 6px 18px rgba(43, 36, 29, 0.045);
    }

    .report-period-current {
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 0;
    }

    .report-period-icon {
        width: 42px;
        height: 42px;
        flex: 0 0 42px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        background: #f3eadf;
        color: var(--accent-hover);
    }

    .report-period-icon svg {
        width: 20px;
        height: 20px;
        fill: none;
        stroke: currentColor;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    .report-period-current div > span,
    .report-period-current strong,
    .report-period-current small {
        display: block;
    }

    .report-period-current div > span {
        margin-bottom: 2px;
        color: var(--muted-text);
        font-size: 10px;
        font-weight: 800;
        letter-spacing: 0.07em;
        text-transform: uppercase;
    }

    .report-period-current strong {
        color: var(--main-text);
        font-size: 16px;
    }

    .report-period-current small {
        margin-top: 3px;
        color: var(--muted-text);
        font-size: 11px;
        font-variant-numeric: tabular-nums;
    }

    .report-period-options {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px;
        border: 1px solid #e2d8cb;
        border-radius: 10px;
        background: #f7f3ed;
    }

    .report-period-option {
        min-width: 84px;
        padding: 9px 14px;
        border-radius: 7px;
        color: var(--label-text);
        font-size: 12px;
        font-weight: 750;
        text-align: center;
        text-decoration: none;
        transition: background-color 0.15s ease, color 0.15s ease, box-shadow 0.15s ease;
    }

    .report-period-option:hover {
        color: var(--accent-hover);
        background: #ffffff;
    }

    .report-period-option.is-active {
        background: var(--accent);
        color: #ffffff;
        box-shadow: 0 4px 10px rgba(134, 92, 44, 0.22);
    }

    .report-summary {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
        gap: 12px;
        margin-bottom: 22px;
    }

    .report-card {
        min-height: 112px;
        padding: 16px 18px;
        border: 1px solid var(--card-border);
        border-radius: 12px;
        background: #fff;
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    .report-card strong {
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: var(--label-text);
    }

    .report-card span {
        font-size: 22px;
        font-weight: 800;
        color: var(--main-text);
    }

    .report-card small {
        margin-top: auto;
        color: var(--muted-text);
        font-size: 10px;
        font-weight: 650;
    }

    .report-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 18px;
    }

    .report-panel {
        min-width: 0;
        min-height: 330px;
        padding: 18px;
        border: 1px solid var(--card-border);
        border-radius: 12px;
        background: #fff;
        box-shadow: 0 6px 18px rgba(43, 36, 29, 0.035);
    }

    .report-panel-heading {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 14px;
    }

    .report-panel h2 {
        margin: 0;
        font-size: 16px;
        font-family: var(--font-display);
        color: var(--main-text);
    }

    .report-panel-heading span {
        flex: 0 0 auto;
        padding: 5px 8px;
        border-radius: 999px;
        background: #f3eadf;
        color: var(--accent-hover);
        font-size: 9px;
        font-weight: 800;
        text-transform: uppercase;
    }

    .report-panel canvas {
        max-height: 265px;
    }

    @media (max-width: 1400px) {
        .report-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }
    }

    @media (max-width: 800px) {
        .report-period-toolbar {
            align-items: stretch;
            flex-direction: column;
        }

        .report-period-options {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        .report-period-option {
            min-width: 0;
        }

        .report-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
