package com.revenuecat.apitests.java.mappers;

import com.revenuecat.purchases.hybridcommon.mappers.TransactionMapperKt;
import com.revenuecat.purchases.models.Transaction;

import java.util.Map;

@SuppressWarnings("unused")
class TransactionMapperApiTests {
    private void checkMap(Transaction transaction) {
        Map<String, Object> map = TransactionMapperKt.map(transaction);
    }
}
