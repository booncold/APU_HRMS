package com.apu.hrms.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Optional Gmail SMTP helper.
 * <p>
 * Configure via environment variables (preferred) or system properties:
 * <ul>
 *   <li>{@code APU_SMTP_USER} / {@code apu.smtp.user}</li>
 *   <li>{@code APU_SMTP_PASSWORD} / {@code apu.smtp.password} (Gmail App Password)</li>
 *   <li>{@code APU_SMTP_FROM} / {@code apu.smtp.from} (optional, defaults to user)</li>
 *   <li>{@code APU_SMTP_HOST} / {@code apu.smtp.host} (default smtp.gmail.com)</li>
 *   <li>{@code APU_SMTP_PORT} / {@code apu.smtp.port} (default 587)</li>
 * </ul>
 * When not configured, {@link #send} returns false and callers may show a local demo link.
 */
public final class MailUtil {

    private static final Logger LOGGER = Logger.getLogger(MailUtil.class.getName());

    private MailUtil() {
    }

    public static boolean isConfigured() {
        String user = config("APU_SMTP_USER", "apu.smtp.user");
        String pass = config("APU_SMTP_PASSWORD", "apu.smtp.password");
        return user != null && !user.isBlank()
                && pass != null && !pass.isBlank();
    }

    public static boolean send(String to, String subject, String body) {
        if (to == null || to.isBlank() || !isConfigured()) {
            return false;
        }

        String user = config("APU_SMTP_USER", "apu.smtp.user");
        String pass = config("APU_SMTP_PASSWORD", "apu.smtp.password");
        String from = config("APU_SMTP_FROM", "apu.smtp.from");
        if (from == null || from.isBlank()) {
            from = user;
        }
        String host = config("APU_SMTP_HOST", "apu.smtp.host");
        if (host == null || host.isBlank()) {
            host = "smtp.gmail.com";
        }
        String port = config("APU_SMTP_PORT", "apu.smtp.port");
        if (port == null || port.isBlank()) {
            port = "587";
        }

        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", host);
            props.put("mail.smtp.port", port);

            final String smtpUser = user;
            final String smtpPass = pass;
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(smtpUser, smtpPass);
                }
            });

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(to)
            );
            message.setSubject(subject);
            message.setText(body);
            Transport.send(message);
            return true;
        } catch (Exception exception) {
            LOGGER.log(Level.WARNING, "Failed to send email to " + to, exception);
            return false;
        }
    }

    private static String config(String envKey, String propKey) {
        String env = System.getenv(envKey);
        if (env != null && !env.isBlank()) {
            return env.trim();
        }
        String prop = System.getProperty(propKey);
        return prop == null ? null : prop.trim();
    }
}
