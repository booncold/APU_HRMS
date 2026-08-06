<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Reports" scope="request"/>
<c:set var="activeMenu" value="reports" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<section class="report-summary" aria-label="Summary cards">
    <article class="report-card">
        <strong>Users</strong>
        <span><c:out value="${summary.users}"/></span>
    </article>
    <article class="report-card">
        <strong>Rooms</strong>
        <span><c:out value="${summary.rooms}"/></span>
    </article>
    <article class="report-card">
        <strong>Orders</strong>
        <span><c:out value="${summary.orders}"/></span>
    </article>
    <article class="report-card">
        <strong>In-house stays</strong>
        <span><c:out value="${summary.activeStays}"/></span>
    </article>
    <article class="report-card">
        <strong>Paid revenue</strong>
        <span>
            RM
            <fmt:formatNumber value="${summary.paidRevenue}"
                              minFractionDigits="2"
                              maxFractionDigits="2"/>
        </span>
    </article>
</section>

<section class="report-grid">
    <article class="report-panel">
        <h2>1. Occupancy by floor</h2>
        <canvas id="chartFloor" height="220"></canvas>
    </article>
    <article class="report-panel">
        <h2>2. Occupancy by room type</h2>
        <canvas id="chartType" height="220"></canvas>
    </article>
    <article class="report-panel">
        <h2>3. Revenue (14 days)</h2>
        <canvas id="chartRevenue" height="220"></canvas>
    </article>
    <article class="report-panel">
        <h2>4. Booking status distribution</h2>
        <canvas id="chartStatus" height="220"></canvas>
    </article>
    <article class="report-panel">
        <h2>5. Housekeeper completions</h2>
        <canvas id="chartHk" height="220"></canvas>
    </article>
    <article class="report-panel">
        <h2>6. Feedback / comments / customers</h2>
        <canvas id="chartActivity" height="220"></canvas>
        <p class="field-hint" style="margin-top:8px;">
            Extra chart for engagement volume (supports the feedback &amp; comment reports).
        </p>
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

    function barChart(el, data, label) {
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
            options: baseOptions(data.title)
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

    barChart(document.getElementById('chartFloor'), floor, 'Occupancy %');
    barChart(document.getElementById('chartType'), type, 'Occupancy %');
    lineChart(document.getElementById('chartRevenue'), revenue, 'RM');
    pieChart(document.getElementById('chartStatus'), status);
    barChart(document.getElementById('chartHk'), hk, 'Completed tasks');
    pieChart(document.getElementById('chartActivity'), activity);
</script>

<style>
    .report-summary {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
        gap: 12px;
        margin-bottom: 22px;
    }

    .report-card {
        padding: 14px 16px;
        border: 1px solid var(--card-border);
        border-radius: var(--radius-md);
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
        font-size: 20px;
        font-weight: 700;
        color: var(--main-text);
    }

    .report-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
        gap: 18px;
    }

    .report-panel {
        padding: 18px;
        border: 1px solid var(--card-border);
        border-radius: var(--radius-md);
        background: #fff;
    }

    .report-panel h2 {
        margin: 0 0 12px;
        font-size: 16px;
        font-family: var(--font-display);
        color: var(--main-text);
    }
</style>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
