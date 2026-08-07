<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | APU Hotel</title>
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

        input[type="email"] {
            width: 100%;
            height: 48px;
            margin-bottom: 18px;
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

        .demo-link {
            margin-top: 14px;
            padding: 12px;
            border: 1px dashed var(--border-colour);
            border-radius: 8px;
            font-size: 13px;
            word-break: break-all;
            background: rgba(255,255,255,0.55);
        }
    </style>
</head>
<body>

<section class="panel">
    <a class="brand" href="${pageContext.request.contextPath}/login">
        <span class="brand-accent">APU</span> Hotel
    </a>

    <h1>Forgot Password</h1>
    <p class="summary">
        Enter your account email.
        <c:choose>
            <c:when test="${smtpConfigured}">
                A reset link will be sent by email when the account exists.
            </c:when>
        </c:choose>
    </p>

    <c:if test="${not empty infoMessage}">
        <div class="status-message" role="status">
            <c:out value="${infoMessage}"/>
        </div>
    </c:if>

    <c:if test="${mailSent}">
        <div class="status-message" role="status">
            Reset email sent. Please check your inbox.
        </div>
    </c:if>

    <c:if test="${not empty demoResetLink}">
        <div class="demo-link">
            <strong>Demo reset link</strong>:
            <br>
            <a href="${demoResetLink}"><c:out value="${demoResetLink}"/></a>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/forgot-password"
          method="post">
        <label for="email">E-mail</label>
        <input id="email"
               name="email"
               type="email"
               placeholder="example@mail.com"
               value="${fn:escapeXml(param.email)}"
               required>

        <div class="actions">
            <button class="btn-primary" type="submit">
                Send reset link
            </button>
            <div class="back-link">
                <a href="${pageContext.request.contextPath}/login">Back to login</a>
            </div>
        </div>
    </form>
</section>

</body>
</html>
