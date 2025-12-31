public with sharing class CashbackMotorController {
    public class ComboboxOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public ComboboxOption(String l, String v) { label = l; value = v; }
    }

    public class LwcOffer {
        @AuraEnabled public String id;
        @AuraEnabled public String rms;
        @AuraEnabled public String bu;
        @AuraEnabled public String canal;
        @AuraEnabled public String inicio;
        @AuraEnabled public String fim; 
        @AuraEnabled public String status;
        @AuraEnabled public String cancelamento;
        @AuraEnabled public Decimal cashback;
        @AuraEnabled public Decimal acelerador;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<ComboboxOption>> getFilterOptions() {
        Map<String, List<ComboboxOption>> res = new Map<String, List<ComboboxOption>>();
        res.put('businessUnit', new List<ComboboxOption>());
        res.put('channelType', new List<ComboboxOption>());

        List<CashbackFiltroOpcao__mdt> rows = [
            SELECT MasterLabel, Grupo__c, ValorAPI__c, Ativo__c, Ordem__c
            FROM CashbackFiltroOpcao__mdt
            WHERE Ativo__c = true
            ORDER BY Grupo__c, Ordem__c, MasterLabel
        ];

        for (CashbackFiltroOpcao__mdt r : rows) {
            if (!res.containsKey(r.Grupo__c)) {
                res.put(r.Grupo__c, new List<ComboboxOption>());
            }
            res.get(r.Grupo__c).add(new ComboboxOption(r.MasterLabel, r.ValorAPI__c));
        }
        return res;
    }

    @AuraEnabled(cacheable=false)
    public static List<LwcOffer> getOffers(String rms, String bu, String canal, String dataCompra) {
        Cashback.ResultadoPromocoesCashback resultado = Cashback.motorCashback(
            rms,
            String.isBlank(canal) ? null : canal,
            'CRF',
            String.isBlank(bu) ? null : bu
        );

        if (resultado == null || !resultado.sucesso || resultado.dados == null) {
            return new List<LwcOffer>();
        }

        Date purchaseDate = parseDateYmd(dataCompra);

        List<LwcOffer> out = new List<LwcOffer>();
        for (CashbackMotorTO dados : resultado.dados) {
            if (dados == null || dados.promotion == null || dados.rule == null) continue;

            if (!matchesPurchaseDate(dados.rule.accumulationStartDate, dados.rule.accumulationEndDate, purchaseDate)) {
                continue;
            }

            LwcOffer o = new LwcOffer();
            o.id  = dados.promotion.id != null ? String.valueOf(dados.promotion.id) : null;
            o.rms = rms;
            o.bu  = dados.promotion.businessUnit;
            o.canal = (dados.promotion.channelType != null && !dados.promotion.channelType.isEmpty())
                ? String.join(dados.promotion.channelType, ', ')
                : '';

            o.inicio       = toBr(dados.rule.accumulationStartDate);
            o.fim          = toBr(dados.rule.accumulationEndDate);
            o.status       = dados.promotion.status;
            o.cancelamento = toBr(dados.rule.realEndDate); 
            o.cashback     = dados.rule.cashbackValue;
            if (dados.acceleration != null && dados.acceleration.cashbackValue != null) {
                o.acelerador = dados.acceleration.cashbackValue;
            }
            out.add(o);
        }
        return out;
    }



    private static Boolean matchesPurchaseDate(Datetime startDt, Datetime endDt, Date purchase) {
        if (purchase == null) return true;
        Date startD = (startDt == null) ? null : Date.newInstance(startDt.year(), startDt.month(), startDt.day());
        Date endD   = (endDt   == null) ? null : Date.newInstance(endDt.year(),   endDt.month(),   endDt.day());
        Boolean geStart = (startD == null) ? true : (purchase >= startD);
        Boolean leEnd   = (endD   == null) ? true : (purchase <= endD);
        return geStart && leEnd;
    }

    private static Date parseDateYmd(String ymd) {
        if (String.isBlank(ymd)) return null;
        try { return Date.valueOf(ymd); } catch (Exception e) { return null; }
    }

    private static String toBr(Datetime dt) {
        if (dt == null) return null;
        return dt.format('dd/MM/yyyy');
    }
}