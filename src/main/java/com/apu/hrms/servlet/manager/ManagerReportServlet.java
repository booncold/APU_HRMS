package com.apu.hrms.servlet.manager;

import com.apu.hrms.facade.ReportFacade;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

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

        request.setAttribute("summary", reportFacade.summaryCards());
        request.setAttribute(
                "occupancyFloorJson",
                JsonLite.toJson(reportFacade.occupancyByFloor())
        );
        request.setAttribute(
                "occupancyTypeJson",
                JsonLite.toJson(reportFacade.occupancyByType())
        );
        request.setAttribute(
                "revenueJson",
                JsonLite.toJson(reportFacade.revenueLastDays(14))
        );
        request.setAttribute(
                "statusJson",
                JsonLite.toJson(reportFacade.bookingStatusDistribution())
        );
        request.setAttribute(
                "hkJson",
                JsonLite.toJson(reportFacade.housekeeperCompletions())
        );
        request.setAttribute(
                "activityJson",
                JsonLite.toJson(reportFacade.feedbackAndCommentCounts())
        );

        request.getRequestDispatcher(PAGE).forward(request, response);
    }

    /** Tiny JSON serializer for report maps/lists. */
    static final class JsonLite {
        private JsonLite() {
        }

        static String toJson(Object value) {
            if (value == null) {
                return "null";
            }
            if (value instanceof String s) {
                return "\"" + escape(s) + "\"";
            }
            if (value instanceof Number || value instanceof Boolean) {
                return String.valueOf(value);
            }
            if (value instanceof java.util.Map<?, ?> map) {
                StringBuilder sb = new StringBuilder("{");
                boolean first = true;
                for (var e : map.entrySet()) {
                    if (!first) {
                        sb.append(',');
                    }
                    first = false;
                    sb.append(toJson(String.valueOf(e.getKey())));
                    sb.append(':');
                    sb.append(toJson(e.getValue()));
                }
                sb.append('}');
                return sb.toString();
            }
            if (value instanceof Iterable<?> it) {
                StringBuilder sb = new StringBuilder("[");
                boolean first = true;
                for (Object o : it) {
                    if (!first) {
                        sb.append(',');
                    }
                    first = false;
                    sb.append(toJson(o));
                }
                sb.append(']');
                return sb.toString();
            }
            return toJson(String.valueOf(value));
        }

        private static String escape(String s) {
            return s.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
        }
    }
}
