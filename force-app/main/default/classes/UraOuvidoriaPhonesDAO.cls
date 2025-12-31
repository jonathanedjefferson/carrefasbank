public with sharing class UraOuvidoriaPhonesDAO {

    private static final UraOuvidoriaPhonesDAO instance =
        new UraOuvidoriaPhonesDAO();
    public static UraOuvidoriaPhonesDAO getInstance() {
        return instance;
    }
    public String getUraOuvidoriaPhones() {
        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = 'UraOuvidoriaPhones'
            LIMIT 1
        ];
        return sr.Body.toString();
    }
}