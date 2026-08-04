<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Receipt" scope="request"/>
<c:set var="activeMenu" value="receipts" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<style>
    @media print {
        .sidebar,
        .app-topbar,
        .no-print {
            display: none !important;
        }
        .app-content {
            max-width: none;
            padding: 0;
        }
        .receipt-card {
            border: none;
            box-shadow: none;
        }
    }

    .receipt-card {
        max-width: 720px;
        margin: 0 auto;
        padding: 28px;
        border: 1px solid var(--card-border);
        border-radius: var(--radius-md);
        background: #ffffff;
    }

    .receipt-card h1 {
        margin: 0 0 6px;
        font-family: var(--font-display);
        font-size: 28px;
    }

    .receipt-meta {
        color: var(--muted-text);
        margin-bottom: 20px;
        line-height: 1.5;
    }

    .receipt-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px 24px;
        margin-bottom: 20px;
    }

    .receipt-grid strong {
        display: block;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
        color: var(--label-text);
        margin-bottom: 4px;
    }
</style>

<c:if test="${not empty successMessage}">
    <div class="status-message no-print" role="status">
        <c:out value="${successMessage}"/>
    </div>
</c:if>

<div class="toolbar no-print">
    <div></div>
    <div style="display:flex; gap:10px;">
        <a class="btn-secondary" href="${backUrl}">Back</a>
        <button class="btn-primary" type="button" onclick="window.print()">Print</button>
    </div>
</div>

<section class="receipt-card" aria-label="Payment receipt">
    <h1><span class="brand-accent">APU</span> Hotel</h1>
    <div class="receipt-meta">
        Official payment receipt<br>
        Receipt No: <strong><c:out value="${payment.receiptNo}"/></strong>
    </div>

    <div class="receipt-grid">
        <div>
            <strong>Order</strong>
            <c:out value="${order.orderNo}"/>
        </div>
        <div>
            <strong>Status</strong>
            <c:out value="${order.status}"/>
        </div>
        <div>
            <strong>Customer</strong>
            <c:out value="${order.customer.name}"/><br>
            <c:out value="${order.customer.email}"/>
        </div>
        <div>
            <strong>Stay</strong>
            <c:out value="${order.checkInDate}"/>
            →
            <c:out value="${order.checkOutDate}"/>
            (<c:out value="${order.nights}"/> night(s))
        </div>
        <div>
            <strong>Payment method</strong>
            <c:out value="${payment.method}"/>
        </div>
        <div>
            <strong>Paid at</strong>
            <c:out value="${payment.paidAtDisplay}"/>
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Room</th>
                <th>Type</th>
                <th>Price / night</th>
                <th>Nights</th>
                <th>Line total</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="br" items="${order.rooms}">
                <tr>
                    <td><c:out value="${br.roomNumberSnapshot}"/></td>
                    <td><c:out value="${br.roomTypeSnapshot}"/></td>
                    <td>
                        RM
                        <fmt:formatNumber value="${br.pricePerNightSnapshot}"
                                          minFractionDigits="2"
                                          maxFractionDigits="2"/>
                    </td>
                    <td><c:out value="${br.nights}"/></td>
                    <td>
                        RM
                        <fmt:formatNumber value="${br.lineTotal}"
                                          minFractionDigits="2"
                                          maxFractionDigits="2"/>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>

    <p style="margin-top: 18px; font-size: 20px; font-weight: 700;">
        Amount paid:
        RM
        <fmt:formatNumber value="${payment.amount}"
                          minFractionDigits="2"
                          maxFractionDigits="2"/>
    </p>

    <p class="field-hint" style="margin-top: 12px;">
        This is a demonstration receipt for APU-HRMS. No real payment gateway is used.
    </p>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
