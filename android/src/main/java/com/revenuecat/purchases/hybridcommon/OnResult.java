package com.revenuecat.purchases.hybridcommon;

import java.util.Map;

public interface OnResult {
    void onReceived(Map<String, ?> map);
    void onError(ErrorContainer errorContainer);
}
