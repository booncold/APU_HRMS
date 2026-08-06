<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Write Feedback" scope="request"/>
<c:set var="activeMenu" value="feedback" scope="request"/>
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
    <form method="post" action="${ctx}/housekeeper/feedback">
        <div class="form-grid">
            <div class="form-group">
                <label for="roomId">Room</label>
                <select id="roomId" name="roomId" required>
                    <option value="">Select room</option>
                    <c:forEach var="r" items="${rooms}">
                        <option value="${r.id}"
                            ${preselectRoomId == r.id ? 'selected' : ''}>
                            <c:out value="${r.roomNumber}"/>
                            — Floor <c:out value="${r.floor}"/>
                            · <c:out value="${r.roomType}"/>
                            · <c:out value="${r.status}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group full-width">
                <label for="content">Feedback</label>
                <textarea id="content"
                          name="content"
                          rows="5"
                          maxlength="2000"
                          required
                          placeholder="Describe room condition, supplies needed, or issues found..."></textarea>
            </div>
        </div>

        <div class="form-actions">
            <button class="btn-primary" type="submit">Submit feedback</button>
        </div>
    </form>
</section>

<section class="list-section">
    <div class="list-section-header">
        <h2 class="list-section-title">My recent feedback</h2>
        <span class="list-section-count">
            <c:out value="${fn:length(myFeedbacks)}"/> Item(s)
        </span>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Room</th>
                <th>Content</th>
                <th>Submitted at</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty myFeedbacks}">
                    <tr>
                        <td colspan="3" class="empty-row">No feedback submitted yet.</td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="f" items="${myFeedbacks}">
                        <tr>
                            <td><c:out value="${f.room.roomNumber}"/></td>
                            <td><c:out value="${f.content}"/></td>
                            <td><c:out value="${f.createdAtDisplay}"/></td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
