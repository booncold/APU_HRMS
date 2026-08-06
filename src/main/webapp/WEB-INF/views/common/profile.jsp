<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Profile" scope="request"/>
<c:set var="activeMenu" value="profile" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<c:if test="${not empty successMessage}">
    <div class="status-message" role="status">
        <c:out value="${successMessage}"/>
    </div>
</c:if>

<c:if test="${not empty errorMessage}">
    <div class="alert-error" role="alert">
        <c:out value="${errorMessage}"/>
    </div>
</c:if>

<section class="form-panel" style="margin-bottom: 28px;">
    <h2 class="list-section-title" style="margin-bottom: 14px;">Personal details</h2>
    <form method="post" action="${ctx}/profile">
        <input type="hidden" name="form" value="profile">
        <div class="form-grid">
            <div class="form-group">
                <label for="name">Name</label>
                <input id="name" name="name" type="text"
                       value="${fn:escapeXml(enteredName)}" required>
                <c:if test="${not empty errors.name}">
                    <div class="field-error"><c:out value="${errors.name}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="gender">Gender</label>
                <select id="gender" name="gender" required>
                    <option value="">Choose</option>
                    <option value="Male" ${enteredGender == 'Male' ? 'selected' : ''}>Male</option>
                    <option value="Female" ${enteredGender == 'Female' ? 'selected' : ''}>Female</option>
                </select>
                <c:if test="${not empty errors.gender}">
                    <div class="field-error"><c:out value="${errors.gender}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="phone">Phone</label>
                <input id="phone" name="phone" type="text"
                       placeholder="+60 1XXXXXXXX"
                       value="${fn:escapeXml(enteredPhone)}" required>
                <c:if test="${not empty errors.phone}">
                    <div class="field-error"><c:out value="${errors.phone}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input id="email" name="email" type="email"
                       value="${fn:escapeXml(enteredEmail)}" required>
                <c:if test="${not empty errors.email}">
                    <div class="field-error"><c:out value="${errors.email}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="ic">IC</label>
                <input id="ic" type="text" value="${fn:escapeXml(enteredIc)}" disabled>
                <p class="field-hint">IC cannot be changed from profile.</p>
            </div>

            <div class="form-group">
                <label>Role</label>
                <input type="text" value="${fn:escapeXml(userRole)}" disabled>
            </div>

            <div class="form-group full-width">
                <label for="address">Address</label>
                <textarea id="address" name="address" rows="3" required><c:out value="${enteredAddress}"/></textarea>
                <c:if test="${not empty errors.address}">
                    <div class="field-error"><c:out value="${errors.address}"/></div>
                </c:if>
            </div>
        </div>
        <div class="form-actions">
            <button class="btn-primary" type="submit">Save profile</button>
        </div>
    </form>
</section>

<section class="form-panel">
    <h2 class="list-section-title" style="margin-bottom: 14px;">Change password</h2>
    <form method="post" action="${ctx}/profile">
        <input type="hidden" name="form" value="password">
        <div class="form-grid">
            <div class="form-group">
                <label for="currentPassword">Current password</label>
                <input id="currentPassword" name="currentPassword" type="password" required>
                <c:if test="${not empty errors.currentPassword}">
                    <div class="field-error"><c:out value="${errors.currentPassword}"/></div>
                </c:if>
            </div>
            <div class="form-group">
                <label for="newPassword">New password</label>
                <input id="newPassword" name="newPassword" type="password" required>
                <p class="field-hint">At least 8 characters, with a letter and a number.</p>
                <c:if test="${not empty errors.newPassword}">
                    <div class="field-error"><c:out value="${errors.newPassword}"/></div>
                </c:if>
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm new password</label>
                <input id="confirmPassword" name="confirmPassword" type="password" required>
                <c:if test="${not empty errors.confirmPassword}">
                    <div class="field-error"><c:out value="${errors.confirmPassword}"/></div>
                </c:if>
            </div>
        </div>
        <div class="form-actions">
            <button class="btn-primary" type="submit">Update password</button>
        </div>
    </form>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
