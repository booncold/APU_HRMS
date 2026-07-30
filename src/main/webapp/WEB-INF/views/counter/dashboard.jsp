<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Counter Staff Dashboard | APU Hotel</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;

            font-family: Arial, Helvetica, sans-serif;
            color: #2b241d;
            background: #eef2ef;
        }

        .page-header {
            padding: 22px 34px;

            display: flex;
            justify-content: space-between;
            align-items: center;

            background: #24332a;
            color: #ffffff;
        }

        .brand {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 22px;
            font-weight: 700;
        }

        .user-name {
            color: #dfe9e2;
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

            color: #5d695f;
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

            border: 1px solid #cbd8cf;
            border-radius: 8px;

            background: #ffffff;
        }

        .action-card h2 {
            margin: 0 0 8px;

            font-size: 18px;
        }

        .action-card p {
            margin: 0;

            color: #5d695f;
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
        Counter Staff Dashboard
    </h1>

    <p class="page-summary">
        Customer registration, booking, check-in, check-out, receipt, and payment features will be connected here.
    </p>

    <section class="action-list"
             aria-label="Counter staff actions">

        <article class="action-card">
            <h2>Customers</h2>
            <p>Register, search, update, and delete customer records.</p>
        </article>

        <article class="action-card">
            <h2>Bookings</h2>
            <p>Assist customers with bookings for the next five days.</p>
        </article>

        <article class="action-card">
            <h2>Payments</h2>
            <p>Record payments and generate receipts after booking is ready.</p>
        </article>
    </section>
</main>

</body>
</html>
