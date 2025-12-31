public with sharing class AverageSpeedToAnswer {
    public static Double getAverageSpeedToAnswer(String originalQueueId, Datetime startDate, Datetime endDate) {
        AggregateResult avgResult = [
            SELECT AVG(SpeedToAnswer) avgSpeedToAnswer
            FROM AgentWork
            WHERE OriginalQueueId = :originalQueueId
            AND CreatedDate >= :startDate
    		AND CreatedDate <= :endDate
            AND SpeedToAnswer != null
        ];

        Double averageSpeedToAnswer = (Double)avgResult.get('avgSpeedToAnswer');
        return averageSpeedToAnswer;
    }
}