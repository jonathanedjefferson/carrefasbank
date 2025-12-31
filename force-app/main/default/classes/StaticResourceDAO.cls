public class StaticResourceDAO {
    private final static StaticResourceDAO instance = new StaticResourceDAO();

    private StaticResourceDAO() { }

    public static StaticResourceDAO getInstance(){
        return instance;
    }

    public StaticResource getByName(String strName){
        List<StaticResource> lstStaticResource = getByname(new List<String> { strName });

        return lstStaticResource.size() > 0 ? lstStaticResource[0] : null;
    }

    public List<StaticResource> getByName(List<String> lstStrName){
        return [
            SELECT
                Body,
                Name,
                NamespacePrefix,
                SystemModStamp
            FROM
                StaticResource
            WHERE
                Name = :lstStrName
        ];
    }
}