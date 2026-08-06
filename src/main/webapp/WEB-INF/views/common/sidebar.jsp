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
               data-icon="&#8962;" title="Dashboard"
               href="${ctx}/manager/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'staff-new' ? 'is-active' : ''}"
               data-icon="&#43;" title="Add Staff"
               href="${ctx}/manager/staff/new">Add Staff</a>

            <a class="sidebar-link ${active == 'staff' ? 'is-active' : ''}"
               data-icon="&#9817;" title="Manage Staff"
               href="${ctx}/manager/staff">Manage Staff</a>

            <a class="sidebar-link ${active == 'rooms' ? 'is-active' : ''}"
               data-icon="&#9638;" title="Rooms &amp; Pricing"
               href="${ctx}/manager/rooms">Rooms &amp; Pricing</a>

            <a class="sidebar-link ${active == 'feedbacks' ? 'is-active' : ''}"
               data-icon="&#9671;" title="Feedbacks"
               href="${ctx}/manager/feedbacks">Feedbacks</a>

            <a class="sidebar-link ${active == 'comments' ? 'is-active' : ''}"
               data-icon="&#9998;" title="Comments"
               href="${ctx}/manager/comments">Comments</a>

            <a class="sidebar-link ${active == 'reports' ? 'is-active' : ''}"
               data-icon="&#8599;" title="Reports"
               href="${ctx}/manager/reports">Reports</a>
        </c:if>

        <c:if test="${role == 'COUNTER_STAFF'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               data-icon="&#8962;" title="Dashboard"
               href="${ctx}/counter/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'customers' ? 'is-active' : ''}"
               data-icon="&#9678;" title="Customers"
               href="${ctx}/counter/customers">Customers</a>

            <a class="sidebar-link ${active == 'bookings' ? 'is-active' : ''}"
               data-icon="&#9635;" title="Bookings"
               href="${ctx}/counter/bookings">Bookings</a>

            <a class="sidebar-link ${active == 'check-in' ? 'is-active' : ''}"
               data-icon="&#8594;" title="Check-in (Today)"
               href="${ctx}/counter/check-in">Check-in (Today)</a>

            <a class="sidebar-link ${active == 'check-out' ? 'is-active' : ''}"
               data-icon="&#8592;" title="Check-out"
               href="${ctx}/counter/check-out">Check-out</a>

            <a class="sidebar-link ${active == 'tasks' ? 'is-active' : ''}"
               data-icon="&#10003;" title="Assign Cleaning"
               href="${ctx}/counter/assign-cleaning">Assign Cleaning</a>

            <a class="sidebar-link ${active == 'receipts' ? 'is-active' : ''}"
               data-icon="&#9636;" title="Receipts"
               href="${ctx}/counter/receipts">Receipts</a>
        </c:if>

        <c:if test="${role == 'HOUSEKEEPER'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               data-icon="&#8962;" title="Dashboard"
               href="${ctx}/housekeeper/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'tasks' ? 'is-active' : ''}"
               data-icon="&#10003;" title="My Tasks"
               href="${ctx}/housekeeper/tasks">My Tasks</a>

            <a class="sidebar-link ${active == 'feedback' ? 'is-active' : ''}"
               data-icon="&#9998;" title="Write Feedback"
               href="${ctx}/housekeeper/feedback">Write Feedback</a>
        </c:if>

        <c:if test="${role == 'CUSTOMER'}">
            <div class="sidebar-section-label">Menu</div>

            <a class="sidebar-link ${active == 'dashboard' ? 'is-active' : ''}"
               data-icon="&#8962;" title="Dashboard"
               href="${ctx}/customer/dashboard">Dashboard</a>

            <a class="sidebar-link ${active == 'book' ? 'is-active' : ''}"
               data-icon="&#43;" title="Book a Room"
               href="${ctx}/customer/book">Book a Room</a>

            <a class="sidebar-link ${active == 'bookings' ? 'is-active' : ''}"
               data-icon="&#9635;" title="My Bookings"
               href="${ctx}/customer/bookings">My Bookings</a>

            <a class="sidebar-link ${active == 'payments' ? 'is-active' : ''}"
               data-icon="&#9636;" title="Payments &amp; Receipts"
               href="${ctx}/customer/receipts">Payments &amp; Receipts</a>

            <a class="sidebar-link ${active == 'comments' ? 'is-active' : ''}"
               data-icon="&#9998;" title="Write Comment"
               href="${ctx}/customer/comments">Write Comment</a>
        </c:if>

        <%-- Account actions follow the feature links instead of being pinned to the page bottom. --%>
        <div class="sidebar-account">
            <div class="sidebar-section-label">Account</div>

            <a class="sidebar-link ${active == 'profile' ? 'is-active' : ''}"
               data-icon="&#9678;" title="Profile"
               href="${ctx}/profile">Profile</a>

            <a class="sidebar-link sidebar-logout"
               data-icon="&#8618;" title="Logout"
               href="${ctx}/logout">Logout</a>
        </div>
    </nav>

</aside>
