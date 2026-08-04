<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password | APU Hotel</title>
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/theme.css">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            background:
                    linear-gradient(rgba(24, 20, 16, 0.48), rgba(24, 20, 16, 0.48)),
                    url("${pageContext.request.contextPath}/assets/images/login-background.png")
                    center / cover no-repeat fixed;
        }

        .panel {
            width: 100%;
            max-width: 440px;
            padding: 40px 42px;
            border: 1px solid rgba(224, 211, 192, 0.78);
            border-radius: 18px;
            background: rgba(241, 235, 224, 0.94);
            box-shadow: 0 24px 65px rgba(14, 11, 8, 0.42);
        }

        .brand {
            display: block;
            margin-bottom: 24px;
            text-align: center;
            text-decoration: none;
            color: var(--main-text);
            font-family: var(--font-display);
            font-size: 24px;
            font-weight: 700;
        }

        h1 {
            margin: 0 0 12px;
            text-align: center;
            font-family: var(--font-display);
            font-size: 28px;
        }

        .summary {
            margin: 0 0 24px;
            text-align: center;
            color: var(--muted-text);
            font-size: 14px;
            line-height: 1.5;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: var(--label-text);
            font-size: 13px;
            font-weight: 600;
        }

        input[type="password"] {
            width: 100%;
            height: 48px;
            margin-bottom: 8px;
            padding: 0 14px;
            border: 1px solid var(--border-colour);
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.72);
            font: inherit;
        }

        .actions {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 12px;
        }

        .back-link {
            text-align: center;
            font-size: 13px;
        }

        .back-link a {
            color: var(--accent);
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>
<body>

<section class="panel">
    <a class="brand" href="${pageContext.request.contextPath}/login">
        <span class="brand-accent">APU</span> Hotel
    </a>

    <h1>Reset Password</h1>
    <p class="summary">Choose a new password for your account.</p>

    <c:if test="${not empty errorMessage}">
        <div class="alert-error" role="alert">
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>

    <c:if test="${tokenValid}">
        <form method="post" action="${pageContext.request.contextPath}/reset-password">
            <input type="hidden" name="token" value="${token}">

            <label for="password">New password</label>
            <input id="password" name="password" type="password" required>
            <c:if test="${not empty errors.password}">
                <div class="alert-error" style="margin-bottom:12px;"><c:out value="${errors.password}"/></div>
            </c:if>

            <label for="confirmPassword">Confirm password</label>
            <input id="confirmPassword" name="confirmPassword" type="password" required>
            <c:if test="${not empty errors.confirmPassword}">
                <div class="alert-error" style="margin-bottom:12px;"><c:out value="${errors.confirmPassword}"/></div>
            </c:if>

            <div class="actions">
                <button class="btn-primary" type="submit">Update password</button>
                <div class="back-link">
                    <a href="${pageContext.request.contextPath}/login">Back to login</a>
                </div>
            </div>
        </form>
    </c:if>

    <c:if test="${!tokenValid}">
        <div class="actions">
            <a class="btn-primary" href="${pageContext.request.contextPath}/forgot-password"
               style="text-align:center; text-decoration:none;">
                Request a new link
            </a>
            <div class="back-link">
                <a href="${pageContext.request.contextPath}/login">Back to login</a>
            </div>
        </div>
    </c:if>
</section>

</body>
</html>
