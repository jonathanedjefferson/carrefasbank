public class ProfileDAO {
    private static final ProfileDAO instance = new ProfileDAO();

    private ProfileDAO() { }

    public static ProfileDAO getInstance() {
		return instance;
    }

    public Profile getProfileById(Id profileId){
        return [
            SELECT 
                Id,
                Name
            FROM 
                Profile 
            WHERE
                Id = :profileId
        ];
    }
}