<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Receipts" scope="request"/>
<c:set var="activeMenu" value="receipts" scope="request"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/layout-top.jsp"/>

<p class="page-summary">
    Paid booking receipts. Open a receipt for print-friendly view.
</p>

<div class="toolbar">
    <form class="toolbar-form" action="#" onsubmit="return false;">
        <input class="live-search-input"
               type="search"
               placeholder="Search receipt, order, customer"
               autocomplete="off"
               aria-label="Search receipts">
        <button class="btn-secondary live-search-reset" type="button">Reset</button>
    </form>
</div>

<div data-live-root class="data-table-wrap">
    <table class="data-table">
        <thead>
        <tr>
            <th>Receipt</th>
            <th>Order</th>
            <th>Customer</th>
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
                    <td colspan="7" class="empty-row">No receipts yet.</td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="order" items="${receiptOrders}">
                    <tr class="live-search-row">
                        <td><c:out value="${order.payment.receiptNo}"/></td>
                        <td><c:out value="${order.orderNo}"/></td>
                        <td><c:out value="${order.customer.name}"/></td>
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
                                   href="${ctx}/counter/receipts/view?orderId=${order.id}">
                                    View / Print
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <tr class="live-search-empty empty-row" hidden>
                    <td colspan="7">No matching receipts.</td>
                </tr>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<script src="${ctx}/assets/js/live-search.js"></script>

<jsp:include page="/WEB-INF/views/common/layout-bottom.jsp"/>
