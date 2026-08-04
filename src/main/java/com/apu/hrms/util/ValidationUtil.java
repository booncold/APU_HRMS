package com.apu.hrms.util;

import java.util.HashMap;
import java.util.Map;

public final class ValidationUtil {

    private ValidationUtil() {
    }

    public static String trim(String value) {
        if (value == null) {
            return null;
        }
        return value.trim();
    }

    public static void requireText(
            Map<String, String> errors,
            String field,
            String value,
            String message
    ) {
        if (value == null || value.isBlank()) {
            errors.put(field, message);
        }
    }

    public static void validateEmail(
            Map<String, String> errors,
            String email
    ) {
        if (email == null || email.isBlank()) {
            errors.put("email", "Email is required.");
            return;
        }

        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            errors.put("email", "Invalid email address.");
        }
    }

    public static void validateIc(
            Map<String, String> errors,
            String ic
    ) {
        if (ic == null || ic.isBlank()) {
            errors.put("ic", "IC is required.");
            return;
        }

        if (!ic.matches("^\\d{6}-\\d{2}-\\d{4}$")) {
            errors.put("ic", "IC format must be XXXXXX-XX-XXXX.");
        }
    }

    public static void validatePhone(
            Map<String, String> errors,
            String storedPhone
    ) {
        if (storedPhone == null || storedPhone.isBlank() || "+60".equals(storedPhone)) {
            errors.put("phone", "Phone is required.");
            return;
        }

        if (!PhoneUtil.isValidStoredFormat(storedPhone)) {
            errors.put(
                    "phone",
                    "Phone must be a valid Malaysian number (+60 followed by 8-11 digits)."
            );
        }
    }

    public static void validatePassword(
            Map<String, String> errors,
            String password,
            boolean required
    ) {
        if (password == null || password.isBlank()) {
            if (required) {
                errors.put("password", "Password is required.");
            }
            return;
        }

        if (password.length() < 8) {
            errors.put("password", "Password must be at least 8 characters.");
            return;
        }

        boolean hasLetter = password.matches(".*[A-Za-z].*");
        boolean hasDigit = password.matches(".*\\d.*");

        if (!hasLetter || !hasDigit) {
            errors.put(
                    "password",
                    "Password must contain at least one letter and one number."
            );
        }
    }

    public static void validateGender(
            Map<String, String> errors,
            String gender
    ) {
        if (gender == null || gender.isBlank()) {
            errors.put("gender", "Gender is required.");
            return;
        }

        if (!"Male".equals(gender) && !"Female".equals(gender)) {
            errors.put("gender", "Choose a valid gender.");
        }
    }

    public static Map<String, String> newErrorMap() {
        return new HashMap<>();
    }
}
