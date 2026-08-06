<%@ page contentType="text/html;charset=UTF-8" language="java" %>
        </main>
    </div>
</div>

<script>
    (function () {
        "use strict";

        var dateTimeElement = document.getElementById("app-current-datetime");
        if (!dateTimeElement) {
            return;
        }

        var months = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];

        function pad(value) {
            return String(value).padStart(2, "0");
        }

        function updateDateTime() {
            var now = new Date();
            var date = pad(now.getDate())
                    + " " + months[now.getMonth()]
                    + " " + now.getFullYear();
            var time = pad(now.getHours())
                    + ":" + pad(now.getMinutes())
                    + ":" + pad(now.getSeconds());

            dateTimeElement.textContent = date + " \u00b7 " + time;
            dateTimeElement.setAttribute("datetime", now.toISOString());
        }

        updateDateTime();
        window.setInterval(updateDateTime, 1000);
    })();
</script>
</body>
</html>
