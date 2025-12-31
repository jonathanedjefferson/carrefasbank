public with sharing class FlowGetProtocolTDCA {
    
    @InvocableMethod(label='TDCA: Obter Protocolo Pelo Documento')
    public static List<Output> getProtocolByDocument(List<Input> listInputs) {
        List<Output> listRetorno = new List<Output>();

        Input item = listInputs[0];
        List<ResponseGetCaseTDCA.CaseRecord> caseRecords = TDCAManager.getProtocolByDocument(item.document, item.brand);

        Output output = new Output();
        output.records = new List<DefinedResponseGetCasesTDCA>();

        for (ResponseGetCaseTDCA.CaseRecord record : caseRecords) {
            DefinedResponseGetCasesTDCA converted = new DefinedResponseGetCasesTDCA();
            converted.caseNumber        = record.caseNumber         != null ? record.caseNumber         : null;
            converted.orderNumber       = record.orderNumber        != null ? record.orderNumber        : null;
            converted.modality          = record.modality           != null ? record.modality           : null;
            converted.documentNumber    = record.documentNumber     != null ? record.documentNumber     : null;
            converted.typeorder         = record.typeorder          != null ? record.typeorder          : null;
            converted.category          = record.category           != null ? record.category           : null;
            converted.reason            = record.reason             != null ? record.reason             : null;
            converted.event             = record.event              != null ? record.event              : null;
            converted.status            = record.status             != null ? record.status             : null;
            converted.brand             = record.brand              != null ? record.brand              : null;
            converted.protocolTypeName  = record.protocolTypeName   != null ? record.protocolTypeName   : null;
            converted.dateCreation      = record.dateCreation       != null ? record.dateCreation       : null;
            converted.channel           = record.channel            != null ? record.channel            : null;
            converted.isVoiceSlaOnTime  = record.isVoiceSlaOnTime   != null ? record.isVoiceSlaOnTime   : null;
            converted.consigmentCode    = record.consigmentCode     != null ? record.consigmentCode     : null;

            if (record.attributesJson != null) {
                converted.type = record.attributesJson.type;
                converted.url = record.attributesJson.url;
            }

            output.records.add(converted);
        }

        listRetorno.add(output);
        return listRetorno;
    }

    public class Input {
        @InvocableVariable
        public String document;
        
        @InvocableVariable
        public String brand;
    }

    public class Output {
        @InvocableVariable
        public List<DefinedResponseGetCasesTDCA> records;
    }
}