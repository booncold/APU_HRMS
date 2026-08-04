<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="pageTitle" value="Write Comment" scope="request"/>
<c:set var="activeMenu" value="comments" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Comment on one of your bookings. Optionally mention the counter staff on the booking
    and housekeepers who cleaned related rooms.
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

<section class="form-panel" style="margin-bottom: 28px;">
    <form method="get" action="${ctx}/customer/comments" class="toolbar-form" style="margin-bottom: 16px;">
        <label for="orderPick" class="field-hint" style="margin:0;">Choose booking first</label>
        <select id="orderPick" name="orderId"
                onchange="this.form.submit()"
                style="min-width: 280px; height: 44px; padding: 0 12px; border: 1px solid var(--border-colour); border-radius: var(--radius-md); background:#fff;">
            <option value="">Select booking</option>
            <c:forEach var="o" items="${bookings}">
                <option value="${o.id}" ${preselectOrderId == o.id ? 'selected' : ''}>
                    <c:out value="${o.orderNo}"/>
                    · <c:out value="${o.checkInDate}"/>
                    · <c:out value="${o.status}"/>
                </option>
            </c:forEach>
        </select>
    </form>

    <c:choose>
        <c:when test="${empty preselectOrderId}">
            <p class="field-hint">Select a booking to write a comment and load mentionable staff.</p>
        </c:when>
        <c:otherwise>
            <form method="post" action="${ctx}/customer/comments">
                <input type="hidden" name="orderId" value="${preselectOrderId}">

                <div class="form-grid">
                    <div class="form-group full-width">
                        <label for="content">Comment</label>
                        <textarea id="content" name="content" rows="5" maxlength="2000" required
                                  placeholder="Share your experience..."></textarea>
                    </div>

                    <div class="form-group full-width">
                        <label>Mention staff (optional)</label>
                        <c:choose>
                            <c:when test="${empty mentionableStaff}">
                                <p class="field-hint">
                                    No related counter staff or completed housekeeper tasks for this booking yet.
                                    You can still submit a comment without mentions.
                                </p>
                            </c:when>
                            <c:otherwise>
                                <div style="display:flex; flex-wrap:wrap; gap:12px 18px;">
                                    <c:forEach var="s" items="${mentionableStaff}">
                                        <label style="display:inline-flex; align-items:center; gap:8px; font-weight:500;">
                                            <input type="checkbox" name="staffIds" value="${s.id}">
                                            <c:out value="${s.name}"/>
                                            <span class="field-hint">(<c:out value="${s.role}"/>)</span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="form-actions">
                    <button class="btn-primary" type="submit">Submit comment</button>
                </div>
            </form>
        </c:otherwise>
    </c:choose>
</section>

<section class="list-section">
    <div class="list-section-header">
        <h2 class="list-section-title">My comments</h2>
        <span class="list-section-count">
            <c:out value="${fn:length(myComments)}"/> Item(s)
        </span>
    </div>
    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
            <tr>
                <th>Order</th>
                <th>Content</th>
                <th>Mentions</th>
                <th>Submitted at</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty myComments}">
                    <tr><td colspan="4" class="empty-row">No comments yet.</td></tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="cmt" items="${myComments}">
                        <tr>
                            <td><c:out value="${cmt.order.orderNo}"/></td>
                            <td><c:out value="${cmt.content}"/></td>
                            <td><c:out value="${cmt.mentionNames}"/></td>
                            <td><c:out value="${cmt.createdAtDisplay}"/></td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
