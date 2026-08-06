<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Profile" scope="request"/>
<c:set var="activeMenu" value="profile" scope="request"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div class="placeholder-note" role="status">
    <strong>Coming soon:</strong>
    edit personal details and change password while logged in.
    Use the sidebar Logout button to end your session.
</div>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
