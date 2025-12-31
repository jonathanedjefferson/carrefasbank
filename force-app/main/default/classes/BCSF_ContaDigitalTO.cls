public class BCSF_ContaDigitalTO {

    public class ResponseConta {
        public Integer institution;
        public String  institutionName;
        public String  branch;
        public Integer accountNumber;
        public String  customerId;
        public String  companyId;
        public Decimal balance;
        public String  status;
        public String  type;
        public String  blockReason;
        public Boolean allowStatement;
    }

    public class ResponseSaldo {
        public Decimal balance;
        public Decimal unavailableBalance;
        public Datetime lastUpdatedAt;
    }

    public class ResponseExtrato {
        public Statements statements;
    }

    public class Statements {
        public List<StatementItem> items;
        public Integer totalItems;
        public Integer pageSize;
        public Integer page;
        public Integer pageCount;
    }

    public class StatementItem {
        public Datetime statementDate;
        public Decimal balance;
        public List<TransactionItem> transactions;
    }

    public class TransactionItem {
        public String id;
        public String transactionType;
        public String movementDescription;
        public Decimal amount;
        public String movementType;
        public Boolean hasReceipt;
        public String receiptId;
        public String hour;
        public Party payer;
        public Party receiver;
        public Object qrCode;
        public Object med;
        public String productType;
        public String movementTitle;
        public String codEndToEnd;
        public Datetime scheduleDate;
        public Datetime canceledDate;
    }

    public class Party {
        public String cpfCnpj;
        public String name;
        public Integer type;
        public String institution;
        public String customerId;
        public String agencyId;
        public String accountId;
        public String ispb;
        public String pixKey;
    }

    public class ResponseTipoBloqueio {
        public String title;
        public String whoBlocks;
        public String description;
        public Boolean blockCashIn;
        public Boolean blockCashOut;
        public String identifier;
        public Integer blockTypeId;
        public String closingAccount;
        public Boolean blockBalance;
        public Boolean allowChangeStatus;
        public Boolean notifyCustomer;
        public Integer messageDisplayPeriod;
        public String id;
    }
}