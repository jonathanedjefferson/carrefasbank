public  class BusinessHoursDAO{
    
    private static final BusinessHoursDAO instance = new BusinessHoursDAO ();
    
    public static BusinessHoursDAO getInstance(){
        return instance;
    }

   public List<BusinessHours> getBusinessHoursByName(String nameBh)
   {
        return [SELECT 	
                ID,
                Name, 
        				IsActive,
	                    MondayStartTime, 
					    MondayEndTime, 
						TuesdayStartTime, 
					    TuesdayEndTime, 
						WednesdayStartTime,
					    WednesdayEndTime,
						ThursdayStartTime, 
					    ThursdayEndTime, 
					   	FridayStartTime, 
					    FridayEndTime,
						SaturdayStartTime, 
					    SaturdayEndTime, 
					    SundayStartTime, 
					    SundayEndTime,
                		TimeZoneSidKey
                FROM 
                    	BusinessHours 
                WHERE 
                    	Name =: nameBh];
   } 
}