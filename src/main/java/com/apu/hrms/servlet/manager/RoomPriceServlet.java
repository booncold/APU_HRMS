package com.apu.hrms.servlet.manager;

import com.apu.hrms.entity.RoomType;
import com.apu.hrms.facade.RoomFacade;
import com.apu.hrms.util.ValidationUtil;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/manager/rooms/price")
public class RoomPriceServlet extends HttpServlet {

    @EJB
    private RoomFacade roomFacade;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String mode = ValidationUtil.trim(request.getParameter("mode"));
        String redirect;

        try {
            if ("type".equalsIgnoreCase(mode)) {
                RoomType type =
                        RoomType.valueOf(
                                ValidationUtil.trim(request.getParameter("roomType"))
                        );
                BigDecimal price = parsePrice(request.getParameter("price"));
                int updated = roomFacade.updatePriceByType(type, price);
                redirect = success(
                        "Updated price for " + updated + " "
                                + type.name() + " room(s)."
                );
            } else {
                Long roomId = parseId(request.getParameter("roomId"));
                BigDecimal price = parsePrice(request.getParameter("price"));
                var room = roomFacade.updateCurrentPrice(roomId, price);
                redirect = success(
                        "Updated price for room "
                                + room.getRoomNumber() + "."
                );
            }
        } catch (Exception exception) {
            redirect = error(
                    exception.getMessage() == null
                            ? "Unable to update price."
                            : exception.getMessage()
            );
        }

        response.sendRedirect(request.getContextPath() + redirect);
    }

    private Long parseId(String raw) {
        try {
            return Long.valueOf(ValidationUtil.trim(raw));
        } catch (Exception exception) {
            throw new IllegalArgumentException("Invalid room id.");
        }
    }

    private BigDecimal parsePrice(String raw) {
        String value = ValidationUtil.trim(raw);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Price is required.");
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("Price must be a valid number.");
        }
    }

    private String success(String message) {
        return "/manager/rooms?success="
                + URLEncoder.encode(message, StandardCharsets.UTF_8);
    }

    private String error(String message) {
        return "/manager/rooms?error="
                + URLEncoder.encode(message, StandardCharsets.UTF_8);
    }
}
