<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Payments & Receipts" scope="request"/>
<c:set var="activeMenu" value="payments" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Receipt</th>
            <th>Order</th>
            <th>Amount</th>
            <th>Method</th>
            <th>Paid at</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty receiptOrders}">
                <tr>
                    <td colspan="6" class="empty-row">No payments yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="order" items="${receiptOrders}">
                    <tr class="live-search-row">
                        <td><c:out value="${order.payment.receiptNo}"/></td>
                        <td><c:out value="${order.orderNo}"/></td>
                        <td>
                            RM
                            <fmt:formatNumber value="${order.payment.amount}"
                                              minFractionDigits="2"
                                              maxFractionDigits="2"/>
                        </td>
                        <td><c:out value="${order.payment.method}"/></td>
                        <td><c:out value="${order.payment.paidAtDisplay}"/></td>
                        <td class="actions">
                            <div class="actions-inner">
                                <a class="btn-link"
                                   href="${ctx}/customer/receipts/view?orderId=${order.id}">
                                    View / Print
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
