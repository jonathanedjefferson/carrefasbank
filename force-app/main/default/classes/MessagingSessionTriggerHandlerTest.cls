/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - MessaginSessionTrigger                           100%             *
*    - MessagingSessionTriggerHandler                   90%              *
**************************************************************************/
@isTest
public class MessagingSessionTriggerHandlerTest {
    @testSetup
    static void  makeData(){

        // MessagingChannel 
        MessagingChannel msgChannel = new MessagingChannel();
        msgChannel.MasterLabel = 'Test Channel';
        msgChannel.DeveloperName = 'Test_Channel';
        msgChannel.IsActive = true;
        msgChannel.MessageType = 'Text'; 
        msgChannel.MessagingPlatformKey = '279492398577777';
        insert msgChannel;

    }

    @isTest
    public static void validarUpdate(){
        MessagingChannel msgChannel = [SELECT Id FROM MessagingChannel LIMIT 1];

        MessagingEndUser user = new MessagingEndUser();
        user.Name = 'Messaging User';
        user.MessagingChannelId = msgChannel.Id;
        user.MessageType = 'EmbeddedMessaging';
        user.MessagingPlatformKey = '279492398577777';
        insert user;

        MessagingSession  msgSession = new MessagingSession();
        msgSession.StartTime = Datetime.newInstance(Long.valueOf('1721227418000'));
        msgSession.EndTime = Datetime.newInstance(Long.valueOf('1721256539000'));
        msgSession.Status = 'Ended';
        msgSession.MessagingChannelId = msgChannel.Id;
        msgSession.MessagingEndUserId = user.Id; 
        insert msgSession;

        Test.startTest();
        update msgSession;
        Test.stopTest();
    }
}