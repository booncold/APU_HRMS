<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Counter Staff Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Manage customers, bookings, arrivals, departures, cleaning assignment, and receipts.
</p>

<section class="action-list" aria-label="Counter staff actions">
    <article class="action-card">
        <h2>
            <a href="${ctx}/counter/customers">Customers</a>
        </h2>
        <p>Register, search, update, and delete customer records.</p>
    </article>

    <article class="action-card">
        <h2>
            <a href="${ctx}/counter/bookings">Bookings</a>
        </h2>
        <p>Assist customers with bookings for the next five days.</p>
    </article>

    <article class="action-card">
        <h2>
            <a href="${ctx}/counter/check-in">Check-in (Today)</a>
        </h2>
        <p>Process today&apos;s arrivals and set rooms to occupied.</p>
    </article>

    <article class="action-card">
        <h2>
            <a href="${ctx}/counter/check-out">Check-out</a>
        </h2>
        <p>Depart guests and mark rooms as needing cleaning.</p>
    </article>

    <article class="action-card">
        <h2>
            <a href="${ctx}/counter/assign-cleaning">Assign Cleaning</a>
        </h2>
        <p>Assign dirty rooms to free housekeepers.</p>
    </article>

    <article class="action-card">
        <h2>
            <a href="${ctx}/counter/receipts">Receipts</a>
        </h2>
        <p>View and print receipts after full prepayment.</p>
    </article>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
