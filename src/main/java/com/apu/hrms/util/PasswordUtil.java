package com.apu.hrms.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public final class PasswordUtil {

    private PasswordUtil() {
    }

    public static String hashPassword(String password) {
        try {
            MessageDigest messageDigest =
                    MessageDigest.getInstance("SHA-256");

            byte[] hashedBytes =
                    messageDigest.digest(
                            password.getBytes(StandardCharsets.UTF_8)
                    );

            return toHex(hashedBytes);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException(
                    "SHA-256 hashing is not available.",
                    exception
            );
        }
    }

    private static String toHex(byte[] bytes) {
        StringBuilder builder =
                new StringBuilder(bytes.length * 2);

        for (byte currentByte : bytes) {
            builder.append(String.format("%02x", currentByte));
        }

        return builder.toString();
    }
}
