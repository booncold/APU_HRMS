<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Comments" scope="request"/>
<c:set var="activeMenu" value="comments" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div class="toolbar" style="margin-bottom: 12px;">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               placeholder="Search customer, order, content, mentions"
               autocomplete="off"
               aria-label="Search comments">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
    <span class="list-section-count">
        <c:out value="${fn:length(commentList)}"/> Item(s)
    </span>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No comments match &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Customer</th>
            <th>Order</th>
            <th>Content</th>
            <th>Mentions</th>
            <th>Submitted at</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty commentList}">
                <tr>
                    <td colspan="5" class="empty-row">No comments yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="cmt" items="${commentList}">
                    <tr class="live-search-row">
                        <td><c:out value="${cmt.customer.name}"/></td>
                        <td><c:out value="${cmt.order.orderNo}"/></td>
                        <td><c:out value="${cmt.content}"/></td>
                        <td><c:out value="${cmt.mentionNames}"/></td>
                        <td><c:out value="${cmt.createdAtDisplay}"/></td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="5">No matching comments.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
