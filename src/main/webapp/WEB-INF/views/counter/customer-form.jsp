<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="isEdit" value="${formMode == 'edit'}"/>
<c:set var="pageTitle" value="${isEdit ? 'Edit Customer' : 'Register Customer'}" scope="request"/>
<c:set var="activeMenu" value="customers" scope="request"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<c:if test="${not empty successMessage}">
    <div class="status-message" role="status">
        <c:out value="${successMessage}"/>
    </div>
</c:if>

<section class="form-panel">
    <form method="post"
          action="${pageContext.request.contextPath}${isEdit ? '/counter/customers/edit' : '/counter/customers/new'}">

        <c:if test="${isEdit}">
            <input type="hidden" name="id" value="${customerId}">
        </c:if>

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
                <label for="email">Email</label>
                <input id="email" name="email" type="email"
                       value="${fn:escapeXml(enteredEmail)}" required>
                <c:if test="${not empty errors.email}">
                    <div class="field-error"><c:out value="${errors.email}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input id="password" name="password" type="password"
                       ${isEdit ? '' : 'required'}>
                <c:if test="${not empty passwordHint}">
                    <div class="field-hint"><c:out value="${passwordHint}"/></div>
                </c:if>
                <c:if test="${not empty errors.password}">
                    <div class="field-error"><c:out value="${errors.password}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="gender">Gender</label>
                <select id="gender" name="gender" required>
                    <option value="">Choose gender</option>
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
                       value="${not empty enteredPhone ? fn:escapeXml(enteredPhone) : '+60 '}"
                       placeholder="+60 123456789"
                       required>
                <c:if test="${not empty errors.phone}">
                    <div class="field-error"><c:out value="${errors.phone}"/></div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="ic">IC</label>
                <input id="ic" name="ic" type="text"
                       value="${fn:escapeXml(enteredIc)}"
                       placeholder="XXXXXX-XX-XXXX"
                       maxlength="14"
                       required>
                <c:if test="${not empty errors.ic}">
                    <div class="field-error"><c:out value="${errors.ic}"/></div>
                </c:if>
            </div>

            <div class="form-group full-width">
                <label for="address">Address</label>
                <textarea id="address" name="address" required>${fn:escapeXml(enteredAddress)}</textarea>
                <c:if test="${not empty errors.address}">
                    <div class="field-error"><c:out value="${errors.address}"/></div>
                </c:if>
            </div>
        </div>

        <div class="form-actions">
            <a class="btn-secondary"
               href="${pageContext.request.contextPath}/counter/customers">
                Back to list
            </a>
            <button class="btn-primary" type="submit">
                <c:out value="${isEdit ? 'Save Changes' : 'Register Customer'}"/>
            </button>
        </div>
    </form>
</section>

<script>
    (function () {
        const phoneInput = document.getElementById("phone");
        const icInput = document.getElementById("ic");

        phoneInput.addEventListener("input", function () {
            const digits = phoneInput.value.replace(/\D/g, "");
            const local = digits.startsWith("60") ? digits.slice(2) : digits;
            phoneInput.value = local.length === 0 ? "+60 " : "+60 " + local;
        });

        icInput.addEventListener("input", function () {
            const digits = icInput.value.replace(/\D/g, "").slice(0, 12);
            let formatted = digits.slice(0, 6);
            if (digits.length > 6) formatted += "-" + digits.slice(6, 8);
            if (digits.length > 8) formatted += "-" + digits.slice(8, 12);
            icInput.value = formatted;
        });
    })();
</script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
