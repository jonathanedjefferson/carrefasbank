@isTest
private class AverageSpeedToAnswerTest {
    @isTest
    static void testGetAverageSpeedToAnswer() {
        Double averageSpeedToAnswer = AverageSpeedToAnswer.getAverageSpeedToAnswer('QueueIdTest', Datetime.now().addHours(-1), Datetime.now());
    }

    @isTest
    static void testeFlowAverageSpeed() {
        List<FlowAverageSpeedToAnswer.Input> lstInputs = new List<FlowAverageSpeedToAnswer.Input>();

        FlowAverageSpeedToAnswer.Input newInput = new FlowAverageSpeedToAnswer.Input();
        newInput.queueId = 'QueueIdTest';
        newInput.startDate = Datetime.now().addHours(-1);
        newInput.endDate = Datetime.now();

        lstInputs.add(newInput);
        FlowAverageSpeedToAnswer.chamarAPI(lstInputs);
    }
}