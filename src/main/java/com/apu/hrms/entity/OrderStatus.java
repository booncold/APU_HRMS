package com.apu.hrms.entity;

public enum OrderStatus {
    PENDING_PAYMENT,
    CONFIRMED,
    PARTIAL_CHECKED_IN,
    CHECKED_IN,
    CHECKED_OUT,
    CANCELLED;

    public String getDisplayName() {
        return switch (this) {
            case PENDING_PAYMENT -> "Pending payment";
            case CONFIRMED -> "Confirmed";
            case PARTIAL_CHECKED_IN -> "Partially checked in";
            case CHECKED_IN -> "Checked in";
            case CHECKED_OUT -> "Checked out";
            case CANCELLED -> "Cancelled";
        };
    }
}
