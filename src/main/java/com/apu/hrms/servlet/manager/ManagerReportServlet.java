package com.apu.hrms.servlet.manager;

import com.apu.hrms.facade.ReportFacade;
import com.apu.hrms.util.JsonLite;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Manager reports page. Chart data is embedded as JSON for Chart.js.
 * Uses a tiny hand-rolled JSON encoder (no extra Maven dependency).
 */
@WebServlet("/manager/reports")
public class ManagerReportServlet extends HttpServlet {

    private static final String PAGE = "/WEB-INF/views/manager/reports.jsp";

    @EJB
    private ReportFacade reportFacade;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        String range = normaliseRange(request.getParameter("range"));
        int days = switch (range) {
            case "day" -> 1;
            case "month" -> 30;
            default -> 7;
        };

        LocalDate periodEnd = LocalDate.now();
        LocalDate periodStart = periodEnd.minusDays(days - 1L);
        LocalDate periodEndExclusive = periodEnd.plusDays(1);
        DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern(
                "dd MMM yyyy",
                Locale.ENGLISH
        );

        request.setAttribute("selectedRange", range);
        request.setAttribute("periodDays", days);
        request.setAttribute(
                "periodLabel",
                switch (range) {
                    case "day" -> "Today";
                    case "month" -> "Last 30 days";
                    default -> "Last 7 days";
                }
        );
        request.setAttribute(
                "periodDateDisplay",
                days == 1
                        ? periodEnd.format(dateFormat)
                        : periodStart.format(dateFormat)
                        + " - "
                        + periodEnd.format(dateFormat)
        );

        request.setAttribute(
                "summary",
                reportFacade.summaryCards(periodStart, periodEndExclusive)
        );
        request.setAttribute(
                "occupancyFloorJson",
                JsonLite.toJson(
                        reportFacade.occupancyByFloor(
                                periodStart,
                                periodEndExclusive
                        )
                )
        );
        request.setAttribute(
                "occupancyTypeJson",
                JsonLite.toJson(
                        reportFacade.occupancyByType(
                                periodStart,
                                periodEndExclusive
                        )
                )
        );
        request.setAttribute(
                "revenueJson",
                JsonLite.toJson(
                        reportFacade.revenueByDate(
                                periodStart,
                                periodEndExclusive
                        )
                )
        );
        request.setAttribute(
                "statusJson",
                JsonLite.toJson(
                        reportFacade.bookingStatusDistribution(
                                periodStart,
                                periodEndExclusive
                        )
                )
        );
        request.setAttribute(
                "hkJson",
                JsonLite.toJson(
                        reportFacade.housekeeperCompletions(
                                periodStart,
                                periodEndExclusive
                        )
                )
        );
        request.setAttribute(
                "activityJson",
                JsonLite.toJson(
                        reportFacade.feedbackAndCommentCounts(
                                periodStart,
                                periodEndExclusive
                        )
                )
        );

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    private String normaliseRange(String raw) {
        if (raw == null) {
            return "week";
        }
        return switch (raw.trim().toLowerCase(Locale.ENGLISH)) {
            case "day" -> "day";
            case "month" -> "month";
            default -> "week";
        };
    }

}
