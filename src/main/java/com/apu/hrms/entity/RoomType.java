package com.apu.hrms.entity;

import java.math.BigDecimal;

public enum RoomType {
    STANDARD(new BigDecimal("250.00")),
    VIP(new BigDecimal("350.00")),
    PRESIDENTIAL(new BigDecimal("500.00"));

    private final BigDecimal defaultPrice;

    RoomType(BigDecimal defaultPrice) {
        this.defaultPrice = defaultPrice;
    }

    public BigDecimal getDefaultPrice() {
        return defaultPrice;
    }
}
