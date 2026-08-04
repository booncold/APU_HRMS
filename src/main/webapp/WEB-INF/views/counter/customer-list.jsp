<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Manage Customers" scope="request"/>
<c:set var="activeMenu" value="customers" scope="request"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Register, search, update, and delete customer accounts.
</p>

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

<div class="toolbar">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               name="q"
               placeholder="Search name, email, IC, phone"
               autocomplete="off"
               aria-label="Search customers">
        <button class="btn-secondary live-search-reset" type="button">
            Reset
        </button>
    </form>

    <a class="btn-primary"
       href="${pageContext.request.contextPath}/counter/customers/new">
        Register Customer
    </a>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No customers found for &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>IC</th>
            <th>Gender</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty customerList}">
                <tr>
                    <td colspan="6" class="empty-row">No customers found.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="customer" items="${customerList}">
                    <tr class="live-search-row">
                        <td><c:out value="${customer.name}"/></td>
                        <td><c:out value="${customer.email}"/></td>
                        <td>
                            <c:set var="p" value="${customer.phone}"/>
                            <c:choose>
                                <c:when test="${fn:startsWith(p, '+60') && fn:length(p) > 3}">
                                    +60 <c:out value="${fn:substring(p, 3, fn:length(p))}"/>
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${p}"/>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><c:out value="${customer.ic}"/></td>
                        <td><c:out value="${customer.gender}"/></td>
                        <td class="actions">
                            <div class="actions-inner">
                                <a class="btn-link"
                                   href="${pageContext.request.contextPath}/counter/customers/edit?id=${customer.id}">
                                    Edit
                                </a>
                                <form method="post"
                                      action="${pageContext.request.contextPath}/counter/customers/delete"
                                      onsubmit="return confirm('Delete this customer account?');">
                                    <input type="hidden" name="id" value="${customer.id}">
                                    <button class="btn-danger" type="submit">Delete</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="6">No matching customers.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<script src="${pageContext.request.contextPath}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
