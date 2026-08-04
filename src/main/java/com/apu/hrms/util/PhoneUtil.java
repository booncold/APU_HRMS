package com.apu.hrms.util;

/**
 * Display: +60 1XXXXXXXX
 * Storage: +601XXXXXXXX (no spaces)
 */
public final class PhoneUtil {

    private PhoneUtil() {
    }

    public static String normalize(String rawPhone) {
        if (rawPhone == null) {
            return null;
        }

        String digitsOnly =
                rawPhone.replaceAll("\\D", "");

        if (digitsOnly.startsWith("60")) {
            digitsOnly = digitsOnly.substring(2);
        }

        if (digitsOnly.isEmpty()) {
            return "+60";
        }

        return "+60" + digitsOnly;
    }

    public static String formatForDisplay(String storedPhone) {
        if (storedPhone == null || storedPhone.isBlank()) {
            return "";
        }

        String normalized = normalize(storedPhone);

        if ("+60".equals(normalized) || normalized.length() <= 3) {
            return normalized;
        }

        // +60 + local digits -> +60 <local>
        return "+60 " + normalized.substring(3);
    }

    public static boolean isValidStoredFormat(String storedPhone) {
        if (storedPhone == null) {
            return false;
        }

        // +60 followed by 8-11 local digits (common MY mobile/landline range)
        return storedPhone.matches("^\\+60\\d{8,11}$");
    }
}
