<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Housekeeper Dashboard | APU Hotel</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;

            font-family: Arial, Helvetica, sans-serif;
            color: #2b241d;
            background: #f2efe9;
        }

        .page-header {
            padding: 22px 34px;

            display: flex;
            justify-content: space-between;
            align-items: center;

            background: #3a2f28;
            color: #ffffff;
        }

        .brand {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 22px;
            font-weight: 700;
        }

        .user-name {
            color: #eadfce;
            font-size: 14px;
        }

        .content {
            max-width: 980px;
            margin: 0 auto;
            padding: 34px;
        }

        .page-title {
            margin: 0 0 10px;

            font-family: Georgia, "Times New Roman", serif;
            font-size: 32px;
        }

        .page-summary {
            margin: 0 0 26px;

            color: #6f6458;
            line-height: 1.5;
        }

        .action-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
        }

        .action-card {
            min-height: 110px;
            padding: 20px;

            border: 1px solid #d8cdbc;
            border-radius: 8px;

            background: #ffffff;
        }

        .action-card h2 {
            margin: 0 0 8px;

            font-size: 18px;
        }

        .action-card p {
            margin: 0;

            color: #6f6458;
            font-size: 14px;
            line-height: 1.45;
        }
    </style>
</head>
<body>

<header class="page-header">
    <div class="brand">
        APU Hotel
    </div>

    <div class="user-name">
        <c:out value="${sessionScope.loggedInUserName}"/>
    </div>
</header>

<main class="content">
    <h1 class="page-title">
        Housekeeper Dashboard
    </h1>

    <p class="page-summary">
        Assigned cleaning tasks, completion updates, and feedback features will be connected here.
    </p>

    <section class="action-list"
             aria-label="Housekeeper actions">

        <article class="action-card">
            <h2>Cleaning Tasks</h2>
            <p>View assigned room cleaning tasks after task assignment is ready.</p>
        </article>

        <article class="action-card">
            <h2>Task Status</h2>
            <p>Update assigned tasks to Completed after housekeeping workflow is ready.</p>
        </article>

        <article class="action-card">
            <h2>Feedback</h2>
            <p>Write feedback that can be viewed by the appropriate users.</p>
        </article>
    </section>
</main>

</body>
</html>
