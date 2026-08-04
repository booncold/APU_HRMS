<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Login | APU Hotel</title>

    <style>
        :root {
            /*
             * Warm hotel-inspired colour palette.
             * No blue is used as the main colour.
             */
            --accent: #a8793d;
            --accent-hover: #865c2c;

            --panel-background: rgba(241, 235, 224, 0.94);
            --input-background: rgba(255, 255, 255, 0.72);

            --main-text: #2b241d;
            --muted-text: #75695d;

            --border-colour: #c8bba9;
            --focus-colour: #a8793d;

            --error-background: rgba(253, 236, 232, 0.96);
            --error-border: #d9a19a;
            --error-text: #8b3028;

            --info-background: rgba(237, 247, 239, 0.96);
            --info-border: #9fc7a7;
            --info-text: #2f6b3a;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html,
        body {
            width: 100%;
            min-height: 100%;
        }

        body {
            min-height: 100vh;

            font-family: Arial, Helvetica, sans-serif;
            color: var(--main-text);

            /*
             * Background image placeholder.
             *
             * Put your background image here:
             * src/main/webapp/assets/images/login-background.jpg
             */
            background-image:
                    linear-gradient(
                            rgba(24, 20, 16, 0.48),
                            rgba(24, 20, 16, 0.48)
                    ),
                    url("${pageContext.request.contextPath}/assets/images/login-background.png");

            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }

        button,
        input {
            font: inherit;
        }

        /*
         * Centres the entire login panel vertically
         * and horizontally.
         */
        .login-page {
            width: 100%;
            min-height: 100vh;

            padding: 32px;

            display: flex;
            justify-content: center;
            align-items: center;
        }

        /*
         * Warm translucent panel that matches
         * the cream, gold and dark tones of the hotel.
         */
        .login-panel {
            width: 100%;
            max-width: 440px;

            padding: 44px 46px;

            border: 1px solid rgba(224, 211, 192, 0.78);
            border-radius: 18px;

            background: var(--panel-background);

            box-shadow:
                    0 24px 65px rgba(14, 11, 8, 0.42);

            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }

        /*
         * Text-only brand.
         * Diamond logo has been completely removed.
         */
        .brand {
            display: block;

            margin-bottom: 34px;

            text-align: center;
            text-decoration: none;

            color: var(--main-text);

            font-family: Georgia, "Times New Roman", serif;
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .brand-accent {
            color: var(--accent);
        }

        .welcome-text {
            margin-bottom: 8px;

            text-align: center;

            color: var(--muted-text);

            font-size: 14px;
        }

        .login-title {
            margin-bottom: 34px;

            text-align: center;

            color: var(--main-text);

            font-family: Georgia, "Times New Roman", serif;
            font-size: 31px;
            line-height: 1.25;
            font-weight: 700;
        }

        .field-error {
            position: relative;

            margin-top: 10px;
            padding: 12px 14px;

            border: 1px solid var(--error-border);
            border-radius: 8px;

            background: var(--error-background);
            color: var(--error-text);

            font-size: 13px;
            line-height: 1.45;
        }

        .field-error::before {
            content: "";

            position: absolute;
            top: -7px;
            left: 22px;

            width: 12px;
            height: 12px;

            border-top: 1px solid var(--error-border);
            border-left: 1px solid var(--error-border);

            background: var(--error-background);

            transform: rotate(45deg);
        }

        .status-message {
            margin-bottom: 20px;
            padding: 12px 14px;

            border: 1px solid var(--info-border);
            border-radius: 8px;

            background: var(--info-background);
            color: var(--info-text);

            font-size: 13px;
            line-height: 1.45;
        }

        .form-group {
            margin-bottom: 21px;
        }

        /*
         * Normal labels above the inputs.
         * There is no floating label and no
         * white text background.
         */
        .form-label {
            display: block;

            margin-bottom: 8px;

            color: #51473d;

            font-size: 13px;
            font-weight: 600;
        }

        .input-wrapper {
            position: relative;
        }

        .form-control {
            width: 100%;
            height: 52px;

            padding: 0 46px 0 15px;

            border: 1px solid var(--border-colour);
            border-radius: 8px;
            outline: none;

            background: var(--input-background);
            color: var(--main-text);

            font-size: 14px;

            transition:
                    border-color 0.2s ease,
                    box-shadow 0.2s ease,
                    background-color 0.2s ease;
        }

        .form-control::placeholder {
            color: #9c948a;
        }

        .form-control:hover {
            border-color: #a99a87;
        }

        .form-control:focus {
            border-color: var(--focus-colour);

            background: rgba(255, 255, 255, 0.88);

            box-shadow:
                    0 0 0 3px rgba(168, 121, 61, 0.16);
        }

        .form-control.is-invalid {
            border-color: var(--error-text);
            background: rgba(255, 248, 247, 0.96);
        }

        .form-control.is-invalid:focus {
            border-color: var(--error-text);

            box-shadow:
                    0 0 0 3px rgba(139, 48, 40, 0.16);
        }

        /*
         * Neutral email icon.
         */
        .field-icon {
            position: absolute;

            top: 50%;
            right: 14px;

            width: 20px;
            height: 20px;

            transform: translateY(-50%);

            display: grid;
            place-items: center;

            color: #8d8377;

            pointer-events: none;
        }

        .field-icon svg {
            width: 17px;
            height: 17px;

            fill: none;
            stroke: currentColor;
            stroke-width: 1.8;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        /*
         * Show/hide password button.
         */
        .password-toggle {
            position: absolute;

            top: 50%;
            right: 9px;

            width: 34px;
            height: 34px;

            transform: translateY(-50%);

            display: grid;
            place-items: center;

            border: none;
            border-radius: 6px;

            background: transparent;
            color: #8d8377;

            cursor: pointer;
        }

        .password-toggle:hover,
        .password-toggle:focus-visible {
            outline: none;

            background: rgba(168, 121, 61, 0.12);
            color: var(--accent);
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

        /*
         * Gold-brown hotel-style button.
         */
        .login-button {
            width: 100%;
            height: 50px;

            margin-top: 5px;

            border: none;
            border-radius: 8px;

            background: var(--accent);
            color: #ffffff;

            font-size: 15px;
            font-weight: 700;
            letter-spacing: 0.2px;

            cursor: pointer;

            transition:
                    background-color 0.2s ease,
                    transform 0.1s ease,
                    box-shadow 0.2s ease;
        }

        .login-button:hover {
            background: var(--accent-hover);

            box-shadow:
                    0 10px 22px rgba(82, 55, 26, 0.28);
        }

        .login-button:active {
            transform: translateY(1px);
        }

        .login-button:focus-visible {
            outline: 3px solid rgba(168, 121, 61, 0.28);
            outline-offset: 2px;
        }

        .forgot-password-row {
            display: flex;
            justify-content: flex-end;

            margin-top: 10px;
        }

        .forgot-password-link {
            color: var(--accent);
            text-decoration: none;

            font-size: 13px;
            font-weight: 600;
        }

        .forgot-password-link:hover {
            color: var(--accent-hover);
            text-decoration: underline;
        }

        .authorised-text {
            margin-top: 22px;

            text-align: center;

            color: var(--muted-text);

            font-size: 12px;
        }

        @media (max-width: 520px) {
            .login-page {
                padding: 18px;
            }

            .login-panel {
                padding: 36px 25px;
                border-radius: 14px;
            }

            .brand {
                font-size: 21px;
            }

            .login-title {
                font-size: 27px;
            }
        }
    </style>
</head>

<body>

<main class="login-page">

    <section class="login-panel">

        <!-- Text-only brand; no diamond logo -->
        <a class="brand"
           href="${pageContext.request.contextPath}/login">

            <span class="brand-accent">APU</span> Hotel
        </a>

        <p class="welcome-text">
            Welcome
        </p>

        <h1 class="login-title">
            Login to APU Hotel
        </h1>

        <c:if test="${not empty infoMessage}">
            <div class="status-message"
                 role="status"
                 aria-live="polite">

                <c:out value="${infoMessage}"/>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login"
              method="post">

            <!-- Email -->
            <div class="form-group">

                <label class="form-label"
                       for="email">
                    E-mail
                </label>

                <div class="input-wrapper">

                    <input class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                           type="text"
                           id="email"
                           name="email"
                           placeholder="example@mail.com"
                           value="${fn:escapeXml(enteredEmail)}"
                           inputmode="email"
                           autocomplete="email"
                           required>

                    <span class="field-icon"
                          aria-hidden="true">

                        <svg viewBox="0 0 24 24">
                            <rect x="3"
                                  y="5"
                                  width="18"
                                  height="14"
                                  rx="2">
                            </rect>

                            <path d="M3 7l9 6 9-6"></path>
                        </svg>
                    </span>
                </div>

                <c:if test="${not empty emailError}">
                    <div class="field-error"
                         role="alert"
                         aria-live="polite">

                        <c:out value="${emailError}"/>
                    </div>
                </c:if>
            </div>

            <!-- Password -->
            <div class="form-group">

                <label class="form-label"
                       for="password">
                    Password
                </label>

                <div class="input-wrapper">

                    <input class="form-control ${not empty passwordError ? 'is-invalid' : ''}"
                           type="password"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           value="${fn:escapeXml(enteredPassword)}"
                           autocomplete="current-password"
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

                <c:if test="${not empty passwordError}">
                    <div class="field-error"
                         role="alert"
                         aria-live="polite">

                        <c:out value="${passwordError}"/>
                    </div>
                </c:if>

                <div class="forgot-password-row">
                    <a class="forgot-password-link"
                       href="${pageContext.request.contextPath}/forgot-password">
                        Forgot Password?
                    </a>
                </div>
            </div>

            <button class="login-button"
                    type="submit">
                Login
            </button>
        </form>

        <p class="authorised-text">
            Authorised users only
        </p>

    </section>

</main>

<script>
    const passwordInput =
        document.getElementById("password");

    const passwordToggle =
        document.getElementById("passwordToggle");

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
</script>

</body>
</html>
