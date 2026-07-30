<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Register Staff | APU Hotel</title>

    <style>
        body {
            margin: 0;
            min-height: 100vh;

            font-family: Arial, Helvetica, sans-serif;
            color: #2b241d;
            background: #f3efe8;
        }

        * {
            box-sizing: border-box;
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

        .header-link {
            color: #eadfce;
            text-decoration: none;
            font-size: 14px;
        }

        .content {
            max-width: 900px;
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

        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(260px, 1fr));
            column-gap: 26px;
            row-gap: 34px;
        }

        .form-group {
            position: relative;

            display: flex;
            flex-direction: column;
            gap: 7px;

            max-width: 410px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
            max-width: none;
        }

        label {
            font-size: 13px;
            font-weight: 700;
            color: #51473d;
        }

        input,
        select,
        textarea {
            width: 100%;
            min-height: 42px;
            padding: 9px 12px;

            border: 1px solid #c8bba9;
            border-radius: 8px;

            font: inherit;
            color: #2b241d;
            background: #ffffff;
        }

        .password-wrapper {
            position: relative;
        }

        .password-wrapper input {
            padding-right: 44px;
        }

        .password-toggle {
            position: absolute;
            top: 50%;
            right: 8px;

            width: 32px;
            height: 32px;

            transform: translateY(-50%);

            display: grid;
            place-items: center;

            border: none;
            border-radius: 6px;

            color: #8d8377;
            background: transparent;

            cursor: pointer;
        }

        .password-toggle:hover,
        .password-toggle:focus-visible {
            outline: none;
            background: rgba(168, 121, 61, 0.12);
            color: #a8793d;
        }

        .password-toggle svg {
            width: 18px;
            height: 18px;

            fill: none;
            stroke: currentColor;
            stroke-width: 1.8;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        textarea {
            min-height: 84px;
            resize: vertical;
        }

        .field-error {
            position: absolute;
            top: calc(100% + 6px);
            left: 12px;
            z-index: 2;

            max-width: calc(100% - 24px);
            padding: 9px 11px;

            border: 1px solid #d9a19a;
            border-radius: 8px;

            color: #8b3028;
            background: #fdece8;

            font-size: 13px;
            line-height: 1.4;
        }

        .field-error::before {
            content: "";

            position: absolute;
            top: -6px;
            left: 18px;

            width: 10px;
            height: 10px;

            border-top: 1px solid #d9a19a;
            border-left: 1px solid #d9a19a;

            background: #fdece8;

            transform: rotate(45deg);
        }

        .success-message {
            margin-bottom: 20px;
            padding: 12px 14px;

            border: 1px solid #9fc7a7;
            border-radius: 8px;

            color: #2f6b3a;
            background: #edf7ef;

            font-size: 14px;
        }

        .form-actions {
            margin-top: 22px;

            display: flex;
            justify-content: flex-end;
        }

        .submit-button {
            min-width: 160px;
            min-height: 46px;

            border: none;
            border-radius: 8px;

            color: #ffffff;
            background: #a8793d;

            font-weight: 700;
            cursor: pointer;
        }

        @media (max-width: 680px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .content {
                padding: 24px;
            }
        }
    </style>
</head>
<body>

<header class="page-header">
    <div class="brand">
        APU Hotel
    </div>

    <a class="header-link"
       href="${pageContext.request.contextPath}/manager/dashboard">
        Back to dashboard
    </a>
</header>

<main class="content">
    <h1 class="page-title">
        Register New Staff
    </h1>

    <p class="page-summary">
        Create staff accounts for Manager, Counter Staff, and Housekeeper roles.
    </p>

    <c:if test="${not empty successMessage}">
        <div class="success-message"
             role="status">
            <c:out value="${successMessage}"/>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/manager/staff/new"
          method="post">

        <div class="form-grid">
            <div class="form-group">
                <label for="name">Name</label>
                <input id="name"
                       name="name"
                       type="text"
                       value="${fn:escapeXml(enteredName)}"
                       required>
                <c:if test="${not empty errors.name}">
                    <div class="field-error">
                        <c:out value="${errors.name}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="role">Staff Role</label>
                <select id="role"
                        name="role"
                        required>
                    <option value="">Choose role</option>
                    <option value="MANAGER"
                            ${enteredRole == 'MANAGER' ? 'selected' : ''}>
                        Manager
                    </option>
                    <option value="COUNTER_STAFF"
                            ${enteredRole == 'COUNTER_STAFF' ? 'selected' : ''}>
                        Counter Staff
                    </option>
                    <option value="HOUSEKEEPER"
                            ${enteredRole == 'HOUSEKEEPER' ? 'selected' : ''}>
                        Housekeeper
                    </option>
                </select>
                <c:if test="${not empty errors.role}">
                    <div class="field-error">
                        <c:out value="${errors.role}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input id="email"
                       name="email"
                       type="email"
                       value="${fn:escapeXml(enteredEmail)}"
                       pattern="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                       required>
                <c:if test="${not empty errors.email}">
                    <div class="field-error">
                        <c:out value="${errors.email}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <div class="password-wrapper">
                    <input id="password"
                           name="password"
                           type="password"
                           required>

                    <button class="password-toggle"
                            type="button"
                            id="passwordToggle"
                            aria-label="Show password"
                            aria-pressed="false">

                        <svg viewBox="0 0 24 24"
                             aria-hidden="true">
                            <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6S2 12 2 12z">
                            </path>
                            <circle cx="12"
                                    cy="12"
                                    r="2.5">
                            </circle>
                        </svg>
                    </button>
                </div>
                <c:if test="${not empty errors.password}">
                    <div class="field-error">
                        <c:out value="${errors.password}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="gender">Gender</label>
                <select id="gender"
                        name="gender"
                        required>
                    <option value="">Choose gender</option>
                    <option value="Male"
                            ${enteredGender == 'Male' ? 'selected' : ''}>
                        Male
                    </option>
                    <option value="Female"
                            ${enteredGender == 'Female' ? 'selected' : ''}>
                        Female
                    </option>
                </select>
                <c:if test="${not empty errors.gender}">
                    <div class="field-error">
                        <c:out value="${errors.gender}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="phone">Phone</label>
                <input id="phone"
                       name="phone"
                       type="text"
                       value="${not empty enteredPhone ? fn:escapeXml(enteredPhone) : '+60'}"
                       inputmode="numeric"
                       pattern="^\+60[0-9]+$"
                       required>
                <c:if test="${not empty errors.phone}">
                    <div class="field-error">
                        <c:out value="${errors.phone}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group">
                <label for="ic">IC</label>
                <input id="ic"
                       name="ic"
                       type="text"
                       value="${fn:escapeXml(enteredIc)}"
                       inputmode="numeric"
                       pattern="^[0-9]{6}-[0-9]{2}-[0-9]{4}$"
                       placeholder="XXXXXX-XX-XXXX"
                       maxlength="14"
                       required>
                <c:if test="${not empty errors.ic}">
                    <div class="field-error">
                        <c:out value="${errors.ic}"/>
                    </div>
                </c:if>
            </div>

            <div class="form-group full-width">
                <label for="address">Address</label>
                <textarea id="address"
                          name="address"
                          required>${fn:escapeXml(enteredAddress)}</textarea>
                <c:if test="${not empty errors.address}">
                    <div class="field-error">
                        <c:out value="${errors.address}"/>
                    </div>
                </c:if>
            </div>
        </div>

        <div class="form-actions">
            <button class="submit-button"
                    type="submit">
                Register Staff
            </button>
        </div>
    </form>
</main>

<script>
    const passwordInput =
        document.getElementById("password");

    const passwordToggle =
        document.getElementById("passwordToggle");

    const phoneInput =
        document.getElementById("phone");

    const icInput =
        document.getElementById("ic");

    passwordToggle.addEventListener("click", function () {
        const isHidden =
            passwordInput.type === "password";

        passwordInput.type =
            isHidden ? "text" : "password";

        passwordToggle.setAttribute(
            "aria-pressed",
            String(isHidden)
        );

        passwordToggle.setAttribute(
            "aria-label",
            isHidden
                ? "Hide password"
                : "Show password"
        );
    });

    phoneInput.addEventListener("input", function () {
        const digits =
            phoneInput.value.replace(/\D/g, "");

        const localDigits =
            digits.startsWith("60")
                ? digits.slice(2)
                : digits;

        phoneInput.value =
            "+60" + localDigits;
    });

    icInput.addEventListener("input", function () {
        const digits =
            icInput.value.replace(/\D/g, "").slice(0, 12);

        let formattedIc =
            digits.slice(0, 6);

        if (digits.length > 6) {
            formattedIc += "-" + digits.slice(6, 8);
        }

        if (digits.length > 8) {
            formattedIc += "-" + digits.slice(8, 12);
        }

        icInput.value =
            formattedIc;
    });
</script>

</body>
</html>
