public class FlowNeoAssistUpdateChamados {
   
    @InvocableMethod(label='Neo Assist update chamados' Category='Neo AssistAPI')
    public static List<Output> UpdatedCalls(List<Input> entrada) {
        String protocolo  = entrada.get(0).protocolo;
        Datetime dataAtual = Datetime.now();
        Datetime dataNovoContato = Datetime.now();
    
        List<BusinessHours> businessHoursList = BusinessHoursDAO.getInstance().getBusinessHoursByName('Carrefour - Varejo');
        String businessHourId = businessHoursList.get(0).Id;
        dataAtual = getNextBusinessDay(businessHourId, dataAtual);
    
        String observacao = 'Operador: Whatsapp <br/>'
        + 'Protocolo em atraso.<br/>'
        + 'Registro de novo contato do cliente em ' + dataNovoContato.format('dd/MM/yyyy') + '<br/>'
        + 'Novo prazo para retorno Data: ' + dataAtual.format('dd/MM/yyyy');
        NeoAssistAPIUpdateChamados.sendRequestAPIUpdateCalls(protocolo, observacao);
    
        List<FlowNeoAssistUpdateChamados.Output> outputList = new List<FlowNeoAssistUpdateChamados.Output>();

        Output output = new Output();
        output.dataMaisProtocolo = + protocolo+' '+ dataNovoContato.format('dd/MM/yyyy');
        outputList.add(output);
    
        System.debug(outputList);
        return outputList;
    }
    
    // Método pega a data atual e adiciona + 24 horas e verifica se essas 24 horas está dentro do BusinessHours
    public static Datetime getNextBusinessDay(String businessHourId, Datetime startDatetime){
        
        Integer days  = 1;
        Datetime resultDateTime = Datetime.newInstance(startDatetime.getTime());
        System.debug(resultDateTime);
        
		if(String.isNotEmpty(businessHourId)){
			for(Integer i = 0; i < days; i++){
				// Verifica se  startDatetime é um dia útil
				if(BusinessHours.isWithin(businessHourId, resultDateTime)){
					// Se for um dia útil, obtém a próxima data
					resultDateTime = resultDateTime.addDays(1); 
                    if(!BusinessHours.isWithin(businessHourId, resultDateTime)){
                       resultDateTime = BusinessHours.nextStartDate(businessHourId, resultDateTime); 
                    }
				}
				else{
					// Se não for um Dia Útil, obtém a data do próximo Dia Útil
					resultDateTime = BusinessHours.nextStartDate(businessHourId, resultDateTime);
				}
			}
			System.debug('return 1 '+ resultDateTime);
			return resultDateTime;
		}
		else{
			System.debug('Return 2'+ resultDateTime.addDays(days));
			return resultDateTime.addDays(days);
		}
	}
    public class Input {
        @InvocableVariable(label='Protocolo' required=true)
        public String protocolo;
    }
    public class Output{
        @InvocableVariable
        public String dataMaisProtocolo;
    }
}