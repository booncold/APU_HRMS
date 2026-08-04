package com.apu.hrms.servlet.customer;

import com.apu.hrms.entity.BookingOrder;
import com.apu.hrms.entity.User;
import com.apu.hrms.facade.BookingFacade;
import com.apu.hrms.facade.UserFacade;
import com.apu.hrms.util.SessionUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {
        "/customer/receipts",
        "/customer/receipts/view"
})
public class CustomerReceiptServlet extends HttpServlet {

    private static final String LIST_PAGE =
            "/WEB-INF/views/customer/receipt-list.jsp";
    private static final String VIEW_PAGE =
            "/WEB-INF/views/common/receipt.jsp";

    @EJB
    private BookingFacade bookingFacade;

    @EJB
    private UserFacade userFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        User customer =
                userFacade.findActiveById(
                        SessionUtil.getLoggedInUserId(request)
                );

        String path = request.getServletPath();

        if ("/customer/receipts/view".equals(path)) {
            Long orderId = parseId(request.getParameter("orderId"));
            BookingOrder order =
                    orderId == null ? null : bookingFacade.findDetailed(orderId);

            if (order == null
                    || order.getPayment() == null
                    || order.getCustomer() == null
                    || !order.getCustomer().getId().equals(customer.getId())) {
                response.sendRedirect(
                        request.getContextPath() + "/customer/receipts"
                );
                return;
            }

            request.setAttribute("order", order);
            request.setAttribute("payment", order.getPayment());
            request.setAttribute("roleArea", "customer");
            request.setAttribute("successMessage", request.getParameter("success"));
            request.setAttribute(
                    "backUrl",
                    request.getContextPath() + "/customer/receipts"
            );
            request.getRequestDispatcher(VIEW_PAGE)
                    .forward(request, response);
            return;
        }

        List<BookingOrder> receiptOrders =
                bookingFacade.findByCustomer(customer).stream()
                        .filter(o -> o.getPayment() != null
                                && o.getPayment().getReceiptNo() != null)
                        .collect(Collectors.toList());

        request.setAttribute("receiptOrders", receiptOrders);
        request.getRequestDispatcher(LIST_PAGE)
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
