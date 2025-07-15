package com.revenuecat.purchases.hybridcommon;

import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

public interface OnResultList {
    void onReceived(@NonNull List<Map<String, ?>> map);
    void onError(@NonNull ErrorContainer errorContainer);
}
