<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Feedbacks" scope="request"/>
<c:set var="activeMenu" value="feedbacks" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    All housekeeper room feedbacks across the hotel.
</p>

<div class="toolbar" style="margin-bottom: 12px;">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               placeholder="Search room, housekeeper, content"
               autocomplete="off"
               aria-label="Search feedbacks">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
    <span class="list-section-count">
        <c:out value="${fn:length(feedbackList)}"/> Item(s)
    </span>
</div>

<div id="live-search-no-results" class="placeholder-note" hidden>
    No feedbacks match &quot;<span id="live-search-keyword"></span>&quot;.
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Room</th>
            <th>Housekeeper</th>
            <th>Content</th>
            <th>Submitted at</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty feedbackList}">
                <tr>
                    <td colspan="4" class="empty-row">No feedbacks yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="f" items="${feedbackList}">
                    <tr class="live-search-row">
                        <td><c:out value="${f.room.roomNumber}"/></td>
                        <td><c:out value="${f.housekeeper.name}"/></td>
                        <td><c:out value="${f.content}"/></td>
                        <td><c:out value="${f.createdAtDisplay}"/></td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="4">No matching feedbacks.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
