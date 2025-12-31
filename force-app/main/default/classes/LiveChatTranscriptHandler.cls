public class LiveChatTranscriptHandler {

    private Map<Id, LiveChatTranscript> NewMap;
    private Map<Id, LiveChatTranscript> OldMap;
    private List<LiveChatTranscript> NewList;
    private List<LiveChatTranscript> OldList;

    public LiveChatTranscriptHandler(Map<Id, LiveChatTranscript> newMap, Map<Id, LiveChatTranscript> oldMap, List<LiveChatTranscript> newList, List<LiveChatTranscript> oldList){
        this.NewMap = newMap;
        this.NewList = newList;
        this.OldMap = oldMap;
        this.oldList = oldList;
    }

    public void beforeUpdate(){
        verificaCase(this.OldMap, this.NewMap, this.newList);
    }


    public static void verificaCase(Map<Id, LiveChatTranscript> OldMap, Map<Id, LiveChatTranscript> NewMap, List<LiveChatTranscript> newList){
        Set<Id> setCaseId = new Set<Id>();
        
        for (Id item: NewMap.keySet()) {
            LiveChatTranscript liveChatNew = NewMap.get(item);
            LiveChatTranscript liveChatOld = OldMap.get(item);
            
            // VERIFICA SE A ALTERAÇÃO OCORREU, DE FATO, NO CASEID
            if (liveChatNew.CaseId != liveChatOld.CaseId && liveChatNew.CaseId != null) {
                setCaseId.add(liveChatNew.caseId);
            }
        }

        List<LiveChatTranscript> listTranscript = getTranscriptByCaseId(setCaseId);
        if (listTranscript.size() > 0) {
            newList[0].addError('Não é possível vincular o Caso a esta Transcrição!');
            return;
        }
        
        if (setCaseId.size() != 0) {
            List<Case> listCase = getCaseChat(setCaseId, 'BCSF_RT_CAS_CasoChat');
            if (listCase.size() == 0) {
                newList[0].addError('Este Não é um Caso do Chat!');
            }
        }
    }


    private static List<LiveChatTranscript> getTranscriptByCaseId(set<Id> caseId){
        return [
            SELECT
                Id
            FROM
                LiveChatTranscript
            WHERE
                CaseId = :caseId
        ];
    }

    private static List<Case> getCaseChat(set<Id> caseId, String recordType){
        return[
            SELECT
                Id, RecordType.DeveloperName
            FROM
                Case
            WHERE
                Id = :caseId AND
                RecordType.DeveloperName = :recordType
            ];
    }
}