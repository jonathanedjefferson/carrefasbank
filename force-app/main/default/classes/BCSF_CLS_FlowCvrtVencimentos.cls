public with sharing class BCSF_CLS_FlowCvrtVencimentos {

    @InvocableMethod(label='Extrair JSON Vencimentos Wrapper')
    public static List<Response> getVencimentos(List<String> aLstJsonVencimentos) {
        Response response = new Response();

        ConjuntoVencimentos conjunto = convertVencimentos(aLstJsonVencimentos[0]);
        Integer counter = 1;

        for (Vencimento vencimento : conjunto.vencimentos){ 
            Date dt1 = Date.valueOf(vencimento.data);

            response.addField('mes' + counter, vencimento.data + '|' + vencimento.idFatura); counter++; 
        }

        return new List<Response>{response};
    }
    
    private static ConjuntoVencimentos convertVencimentos(String aJsonVencimentos){
        return (ConjuntoVencimentos) JSON.deserialize(aJsonVencimentos, ConjuntoVencimentos.class); 
    }

    public class Vencimento{
        @InvocableVariable public String idFatura;
        @InvocableVariable public String data;
    }

    public class ConjuntoVencimentos{
        @InvocableVariable public List<Vencimento> vencimentos;
    }

    public class Response {
        @InvocableVariable public String mes1;
        @InvocableVariable public String mes2;
        @InvocableVariable public String mes3;
        @InvocableVariable public String mes4;
        @InvocableVariable public String mes5;
        @InvocableVariable public String mes6;
        @InvocableVariable public String mes7;
        @InvocableVariable public String mes8;
        @InvocableVariable public String mes9;
        @InvocableVariable public String mes10;
        @InvocableVariable public String mes11;
        @InvocableVariable public String mes12;

        public void addField(String aField, String aValue)
        {
            switch on aField
            {
                when 'mes1' { this.mes1 = aValue; }
                when 'mes2' { this.mes2 = aValue; }
                when 'mes3' { this.mes3 = aValue; }
                when 'mes4' { this.mes4 = aValue; }
                when 'mes5' { this.mes5 = aValue; }
                when 'mes6' { this.mes6 = aValue; }
                when 'mes7' { this.mes7 = aValue; }
                when 'mes8' { this.mes8 = aValue; }
                when 'mes9' { this.mes9 = aValue; }
                when 'mes10' { this.mes10 = aValue; }
                when 'mes11' { this.mes11 = aValue; }
                when 'mes12' { this.mes12 = aValue; }    
            }
        }
    }
    
    
}