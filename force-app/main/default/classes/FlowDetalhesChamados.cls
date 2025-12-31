public class FlowDetalhesChamados {
    @InvocableMethod(label='Detalhes Chamado')
    public static List<List<FlowResponseProtocolo>> chamarDetalhesChamados(List<Input> lstEntrada) {
		Id businessHoursId = [SELECT Id, Name FROM BusinessHours WHERE Name = 'Carrefour - Varejo' LIMIT 1].Id;    
        String CPF = lstEntrada[0].CPF;
        String email = lstEntrada[0].email;
    
        List<FlowResponseProtocolo> outputList = new List<FlowResponseProtocolo>(); // Lista de output
        List<List<FlowResponseProtocolo>> outputListAdd = new List<List<FlowResponseProtocolo>>(); // Lista de output
    
        if (CPF != null || email != null) {
            List<BuscarDetalhesChamadosTO.ResponseWrapper> result = BuscarDetalhesChamados.getDetalhesChamadoPorProtocolo(lstEntrada[0].CPF, lstEntrada[0].email, lstEntrada[0].period, lstEntrada[0].startPeriod, lstEntrada[0].endPeriod);
    
            for (BuscarDetalhesChamadosTO.ResponseWrapper data : result) {
                for (BuscarDetalhesChamadosTO.Data detalhe : data.data) {
                    FlowResponseProtocolo output = new FlowResponseProtocolo();
                    output.protocolo = detalhe.Protocolo;
                    output.status = detalhe.Status;
                    output.date_Z = DateTime.valueOf(detalhe.Date_Z);
                    output.dateUpdate = detalhe.DateUpdate;
                    output.resolution = detalhe.Resolution;
                    output.protocoloResolutionDate = detalhe.ProtocoloResolutionDate;
                    output.expertFullName = detalhe.ExpertFullName;
                    output.workFlowStatus = detalhe.WorkFlowStatus;
                    output.categoryID = detalhe.CategoryID;
                    output.ProtocoloFieldA = detalhe.ProtocoloFieldA;
                    output.bodyProtocolo = detalhe.bodyProtocolo;
                    if(detalhe.CategoryID != null && detalhe.Date_Z != null){
                        String categoria = detalhe.CategoryID;
                        String dateZ = detalhe.Date_Z;
                        
                        List<SLA_Protocolo__mdt> mdList = [SELECT Id, CategoryID__c, SLA__c FROM SLA_Protocolo__mdt WHERE CategoryID__c = :categoria LIMIT 1];
    
                        if (!mdList.isEmpty()) {
                            SLA_Protocolo__mdt md = mdList[0];
                            Integer limiteDias = Integer.valueOf(md.SLA__c);
                            Datetime dtComTime = DateTime.valueOf(dateZ);
                            Date dt = dtComTime.date();
                            
    
                            // Calcula a data de vencimento considerando apenas dias úteis
                            Datetime dataVencimento = dtComTime;
                            Integer diasUteis = 0;
                            Integer diasContados = 0;
                            
                            while (diasUteis < limiteDias) {
                                
                                dataVencimento = dataVencimento.addDays(1);
                                
                                if (BusinessHours.isWithin(businessHoursId, dataVencimento)) {
                                	diasUteis++;
                                }
                                diasContados++;
                                
                                // Limita o número de iterações para evitar loops infinitos
                                if (diasContados > limiteDias * 3) {
                                    break;
                                }
                            }
                            
                            // Verifica se a data atual está antes da data de vencimento
                            if (System.today() <= dataVencimento) {
                                output.statusPrazo = 'Dentro do Prazo';
                            } else {
                                output.statusPrazo = 'Fora do prazo';
                            }

                            if(dataVencimento != null){
                                    if(dataVencimento.day() < 10 && dataVencimento.month() > 10){
                                      output.dataVencimento = '0'+dataVencimento.day()+'/'+dataVencimento.month()+'/'+dataVencimento.year();
                                    } else if(dataVencimento.day() < 10 && dataVencimento.month() < 10){
                                      output.dataVencimento = '0'+dataVencimento.day()+'/'+'0'+dataVencimento.month()+'/'+dataVencimento.year();
                                    } else {
                                      output.dataVencimento = dataVencimento.day()+'/'+dataVencimento.month()+'/'+dataVencimento.year();
                                    }
                            }
                         } else {
                             output.statusPrazo = 'Sem categoria cadastrada, impossível calcular SLA';
                         }

                    }
    
                    outputList.add(output); // Adicionar objeto Output à lista de output
                }
            }
        }
        
        outputListAdd.add(outputList);
        return outputListAdd;
    }
    

    public class Input {
        @InvocableVariable(required=false)
        public String CPF;
        @InvocableVariable(required=false)
        public String email;
        @InvocableVariable(required=false)
        public String period;
        @InvocableVariable(required=false)
        public Date startPeriod;
        @InvocableVariable(required=false)
        public Date endPeriod;
    }
}


/*
-----------------Para Utilizar no Teste em Anonymous-----------------------
String CPF = '35330227810';
FlowDetalhesChamados.Input input = new FlowDetalhesChamados.Input();
input.CPF = CPF;
List<FlowDetalhesChamados.Input> entrada = new List<FlowDetalhesChamados.Input>();
entrada.add(input);
FlowDetalhesChamados.chamarDetalhesChamados(entrada);
*/