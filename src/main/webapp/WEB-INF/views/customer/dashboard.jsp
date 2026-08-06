<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Customer Dashboard" scope="request"/>
<c:set var="activeMenu" value="dashboard" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<section class="action-list" aria-label="Customer actions">
    <article class="action-card">
        <h2><a href="${ctx}/customer/book">Book a Room</a></h2>
        <p>Choose dates, nights, and specific rooms, then complete payment.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/customer/bookings">My Bookings</a></h2>
        <p>View history and cancel reserved bookings before check-in.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/customer/receipts">Payments &amp; Receipts</a></h2>
        <p>Access payment history and printable receipts.</p>
    </article>

    <article class="action-card">
        <h2><a href="${ctx}/customer/comments">Write Comment</a></h2>
        <p>Comment on a booking and optionally mention related staff.</p>
    </article>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
