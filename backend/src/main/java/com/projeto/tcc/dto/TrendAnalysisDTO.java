package com.projeto.tcc.dto;

import java.util.List;

public class TrendAnalysisDTO {
    private String period; 
    private List<ActivityTrendDTO> trends;
    private Double trendSlope; 
    private String trendDirection; 

    public TrendAnalysisDTO() {}

    public TrendAnalysisDTO(String period, List<ActivityTrendDTO> trends, Double trendSlope, String trendDirection) {
        this.period = period;
        this.trends = trends;
        this.trendSlope = trendSlope;
        this.trendDirection = trendDirection;
    }

    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public List<ActivityTrendDTO> getTrends() { return trends; }
    public void setTrends(List<ActivityTrendDTO> getTrends) { this.trends = getTrends; }
    public Double getTrendSlope() { return trendSlope; }
    public void setTrendSlope(Double trendSlope) { this.trendSlope = trendSlope; }
    public String getTrendDirection() { return trendDirection; }
    public void setTrendDirection(String trendDirection) { this.trendDirection = trendDirection; }
}
