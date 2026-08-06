<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="role" value="${sessionScope.loggedInUserRole}"/>
<c:set var="active" value="${activeMenu}"/>

<aside class="sidebar" aria-label="Main navigation">

    <div class="sidebar-brand">
        <a href="${ctx}/login">
            <span class="brand-accent">APU</span> Hotel
        </a>
    </div>

    <div class="sidebar-user">
        <div class="sidebar-user-name">
            <c:out value="${sessionScope.loggedInUserName}"/>
        </div>
        <div class="sidebar-user-role">
            <c:choose>
                <c:when test="${role == 'MANAGER'}">Manager</c:when>
                <c:when test="${role == 'COUNTER_STAFF'}">Counter Staff</c:when>
                <c:when test="${role == 'HOUSEKEEPER'}">Housekeeper</c:when>
                <c:when test="${role == 'CUSTOMER'}">Customer</c:when>
                <c:otherwise>
                    <c:out value="${role}"/>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <nav class="sidebar-nav" aria-label="Feature navigation">

        <c:if test="${role == 'MANAGER'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               href="${ctx}/manager/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'staff-new' ? 'is-active' : ''}"
               href="${ctx}/manager/staff/new">Add Staff</a>

            <a class="sidebar-link ${active == 'staff' ? 'is-active' : ''}"
               href="${ctx}/manager/staff">Manage Staff</a>

            <a class="sidebar-link ${active == 'rooms' ? 'is-active' : ''}"
               href="${ctx}/manager/rooms">Rooms &amp; Pricing</a>

            <a class="sidebar-link ${active == 'feedbacks' ? 'is-active' : ''}"
               href="${ctx}/manager/feedbacks">Feedbacks</a>

            <a class="sidebar-link ${active == 'comments' ? 'is-active' : ''}"
               href="${ctx}/manager/comments">Comments</a>

            <a class="sidebar-link ${active == 'reports' ? 'is-active' : ''}"
               href="${ctx}/manager/reports">Reports</a>
        </c:if>

        <c:if test="${role == 'COUNTER_STAFF'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               href="${ctx}/counter/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'customers' ? 'is-active' : ''}"
               href="${ctx}/counter/customers">Customers</a>

            <a class="sidebar-link ${active == 'bookings' ? 'is-active' : ''}"
               href="${ctx}/counter/bookings">Bookings</a>

            <a class="sidebar-link ${active == 'check-in' ? 'is-active' : ''}"
               href="${ctx}/counter/check-in">Check-in (Today)</a>

            <a class="sidebar-link ${active == 'check-out' ? 'is-active' : ''}"
               href="${ctx}/counter/check-out">Check-out</a>

            <a class="sidebar-link ${active == 'tasks' ? 'is-active' : ''}"
               href="${ctx}/counter/assign-cleaning">Assign Cleaning</a>

            <a class="sidebar-link ${active == 'receipts' ? 'is-active' : ''}"
               href="${ctx}/counter/receipts">Receipts</a>
        </c:if>

        <c:if test="${role == 'HOUSEKEEPER'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               href="${ctx}/housekeeper/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'tasks' ? 'is-active' : ''}"
               href="${ctx}/housekeeper/tasks">My Tasks</a>
        </c:if>

        <c:if test="${role == 'CUSTOMER'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               href="${ctx}/customer/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'book' ? 'is-active' : ''}"
               href="${ctx}/customer/book">Book a Room</a>

            <a class="sidebar-link ${active == 'bookings' ? 'is-active' : ''}"
               href="${ctx}/customer/bookings">My Bookings</a>

            <a class="sidebar-link ${active == 'payments' ? 'is-active' : ''}"
               href="${ctx}/customer/receipts">Payments &amp; Receipts</a>

            <a class="sidebar-link ${active == 'comments' ? 'is-active' : ''}"
               href="${ctx}/customer/comments">Write Comment</a>
        </c:if>

    </nav>

    <%-- Bottom area: profile placeholder + logout separated from feature links --%>
    <div class="sidebar-footer">
        <a class="sidebar-link sidebar-link-profile ${active == 'profile' ? 'is-active' : ''}"
           href="${ctx}/profile">
            Profile
        </a>

        <a class="sidebar-logout"
           href="${ctx}/logout">
            Logout
        </a>
    </div>

</aside>
