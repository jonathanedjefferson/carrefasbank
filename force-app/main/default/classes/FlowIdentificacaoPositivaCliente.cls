public class FlowIdentificacaoPositivaCliente {
    @InvocableMethod(label='Identificação positiva cliente')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> outputList = new List<Output>();

        for(Input item: lstEntrada) {
            Output novoOutput = new Output();

            IdentificacaoPositivaClienteTO.Retorno resultado = IdentificacaoPositivaCliente.makeAPIRequest(item.CPF);
            novoOutput.email = resultado.email;
            novoOutput.firstName = resultado.firstName;
            novoOutput.lastName = resultado.lastName;
            novoOutput.homePhone = resultado.homePhone;
            novoOutput.birthDate = resultado.birthDate;
            novoOutput.atLeast90PercentEqual = areStrings90PercentCompatible(item.name, resultado.firstName + ' ' + resultado.lastName);
            outputList.add(novoOutput);
        }
        return outputList;
    }
    
    public class Input {
        @InvocableVariable(label='CPF' required=true)
        public String CPF;
        @InvocableVariable(label='Name' required=true)
        public String name;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public String email;
        @AuraEnabled @InvocableVariable
        public String firstName;
        @AuraEnabled @InvocableVariable
        public String lastName;
        @AuraEnabled @InvocableVariable
        public String homePhone;
        @AuraEnabled @InvocableVariable
        public String birthDate;
        @AuraEnabled @InvocableVariable
        public Boolean atLeast90PercentEqual;
    }

     // Function to calculate Levenshtein Distance between two strings
     public static Integer calculateDistance(String s1, String s2) {
        Integer len1 = s1.length();
        Integer len2 = s2.length();
        
        // Create a matrix to store the distance values
        List<List<Integer>> dp = new List<List<Integer>>();
        
        // Initialize the matrix with 0s
        for(Integer i = 0; i <= len1; i++) {
            dp.add(new List<Integer>());
            for(Integer j = 0; j <= len2; j++) {
                dp[i].add(0);
            }
        }
        
        // Initialize the first row and column of the matrix
        for (Integer i = 0; i <= len1; i++) {
            dp[i][0] = i;
        }
        for (Integer j = 0; j <= len2; j++) {
            dp[0][j] = j;
        }
        
        // Fill in the matrix using dynamic programming
        for (Integer i = 1; i <= len1; i++) {
            for (Integer j = 1; j <= len2; j++) {
                Integer cost = (s1.charAt(i - 1) == s2.charAt(j - 1)) ? 0 : 1;
                dp[i][j] = Math.min(Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1), dp[i - 1][j - 1] + cost);
            }
        }
        
        // The Levenshtein Distance is the value at the bottom-right of the matrix
        return dp[len1][len2];
    }
    
    // Function to compare two strings and check if they are at least 90% compatible
    public static Boolean areStrings90PercentCompatible(String s1, String s2) {
        Integer distance = calculateDistance(s1, s2);
        Integer maxLength = Math.max(s1.length(), s2.length());
        Double similarity = 1 - (distance / (maxLength * 1.0));
        return similarity >= 0.9; // Return true if similarity is at least 90%
    }
}