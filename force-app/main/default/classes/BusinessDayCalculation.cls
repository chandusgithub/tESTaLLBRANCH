public class BusinessDayCalculation  
{  
    public static Integer calculateWorkingDays(Date startDate, Date endDate)  
    {          
         
      
        Set<Date> holidaysSet = new Set<Date>();  
         
        for(Holiday currHoliday : [Select ActivityDate from Holiday])  
        {  
            holidaysSet.add(currHoliday.ActivityDate);  
        }  
         
        Integer workingDays = 0;  
         
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)))  
                {  
                    workingDays = workingDays + 1;  
                }     
               
        }  
              
        System.debug('--Working days'+workingDays);  
        return workingDays;  
    }  
}