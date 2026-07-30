<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Manager Dashboard | APU Hotel</title>

    <style>
        body {
            margin: 0;
            min-height: 100vh;

            font-family: Arial, Helvetica, sans-serif;
            color: #2b241d;
            background: #f3efe8;
        }

        .page-header {
            padding: 24px 36px;

            display: flex;
            justify-content: space-between;
            align-items: center;

            background: #2b241d;
            color: #ffffff;
        }

        .brand {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 22px;
            font-weight: 700;
        }

        .manager-name {
            font-size: 14px;
            color: #eadfce;
        }

        .content {
            max-width: 980px;
            margin: 0 auto;
            padding: 36px;
        }

        .page-title {
            margin: 0 0 10px;

            font-family: Georgia, "Times New Roman", serif;
            font-size: 32px;
        }

        .page-summary {
            margin: 0 0 28px;

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

    <div class="manager-name">
        <c:out value="${sessionScope.loggedInUserName}"/>
    </div>
</header>

<main class="content">
    <h1 class="page-title">
        Manager Dashboard
    </h1>

    <p class="page-summary">
        Staff management will be connected from here in the next step.
    </p>

    <section class="action-list"
             aria-label="Manager actions">

        <article class="action-card">
            <h2>
                <a href="${pageContext.request.contextPath}/manager/staff/new">
                    Add Staff
                </a>
            </h2>

            <p>
                Create Manager, Counter Staff, and Housekeeper accounts.
            </p>
        </article>

        <article class="action-card">
            <h2>
                Staff Search
            </h2>

            <p>
                Search, update, and delete staff records after staff CRUD is added.
            </p>
        </article>

        <article class="action-card">
            <h2>
                Room Prices
            </h2>

            <p>
                Room pricing starts after room records are generated.
            </p>
        </article>
    </section>
</main>

</body>
</html>
