package com.apu.hrms.servlet.counter;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.facade.BookingFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {
        "/counter/receipts",
        "/counter/receipts/view"
})
public class CounterReceiptServlet extends HttpServlet {

    private static final String LIST_PAGE =
            "/WEB-INF/views/counter/receipt-list.jsp";
    private static final String VIEW_PAGE =
            "/WEB-INF/views/common/receipt.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/counter/receipts/view".equals(path)) {
            showReceipt(request, response, "counter");
            return;
        }

        var paidOrders = bookingFacade.findAllDetailed().stream()
                .filter(o -> o.getPayment() != null
                        && o.getPayment().getReceiptNo() != null)
                .collect(Collectors.toList());

        request.setAttribute("receiptOrders", paidOrders);
        request.getRequestDispatcher(LIST_PAGE)
                .forward(request, response);
    }

    private void showReceipt(
            HttpServletRequest request,
            HttpServletResponse response,
            String roleArea
    ) throws ServletException, IOException {

        Long orderId = parseId(request.getParameter("orderId"));
        BookingOrder order =
                orderId == null ? null : bookingFacade.findDetailed(orderId);

        if (order == null || order.getPayment() == null) {
            response.sendRedirect(
                    request.getContextPath() + "/counter/receipts"
            );
            return;
        }

        request.setAttribute("order", order);
        request.setAttribute("payment", order.getPayment());
        request.setAttribute("roleArea", roleArea);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("backUrl", request.getContextPath() + "/counter/receipts");

        request.getRequestDispatcher(VIEW_PAGE)
                .forward(request, response);
    }

    private Long parseId(String raw) {
        try {
            return Long.valueOf(raw);
        } catch (Exception exception) {
            return null;
        }
    }
}
