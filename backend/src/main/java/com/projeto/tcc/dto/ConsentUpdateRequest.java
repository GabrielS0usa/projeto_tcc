package com.projeto.tcc.dto;

public class ConsentUpdateRequest {
 
    private boolean marketingConsent;

    private boolean dataProcessingConsent;

    private boolean termsAccepted;

    public ConsentUpdateRequest() {}

    public ConsentUpdateRequest(boolean marketingConsent, boolean dataProcessingConsent, boolean termsAccepted) {
        this.marketingConsent = marketingConsent;
        this.dataProcessingConsent = dataProcessingConsent;
        this.termsAccepted = termsAccepted;
    }

    public boolean isMarketingConsent() { return marketingConsent; }
    public void setMarketingConsent(boolean marketingConsent) { this.marketingConsent = marketingConsent; }

    public boolean isDataProcessingConsent() { return dataProcessingConsent; }
    public void setDataProcessingConsent(boolean dataProcessingConsent) { this.dataProcessingConsent = dataProcessingConsent; }

    public boolean isTermsAccepted() { return termsAccepted; }
    public void setTermsAccepted(boolean termsAccepted) { this.termsAccepted = termsAccepted; }
}
