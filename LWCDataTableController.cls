public with sharing class LWCDataTableController {
    public static List<String> searchFieldList=new List<String>();
    //init method to fetch initial records
    @AuraEnabled(cacheable=true)
    public static DataTableWrapper initRecords(String ObjectName,String ListViewName,String recordId, String Orderby, String OrderDir,boolean inlineEdit,boolean enableColAction) {
        system.debug('initrecords'+ObjectName);
        //+'fieldNamesStr'+fieldNamesStr);
        DataTableWrapper dtw = new DataTableWrapper();
        List<LabelDescriptionWrapper> labelList = new List<LabelDescriptionWrapper>();
        List<String> fieldSet = new List<String>();
      //  List<FieldsData> fieldData=new List<FieldsData>();
        // Set<String> fieldNameSet = new Set<String>(fieldNamesStr.split(','));
        if(Schema.getGlobalDescribe().containsKey(ObjectName))
        {
            sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();
            system.debug('sobj'+sobj);
            //get all the labels for Opportunity fields and put them in a map, keyed to the field api name
            //  Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            
            Map<String, Schema.FieldSet> fieldSetMap = DescribeSObjectResultObj.FieldSets.getMap();
            
            //  List<Schema.FieldSet> fieldSetMapping=fieldSetMap.values();
            
            List<Schema.SObjectField> fieldsLst=new List<Schema.SObjectField>();
            List<Schema.DisplayType> fieldType=new  List<Schema.DisplayType>();
            List<String> fieldLabel=new List<String>();
            
            Map<Schema.SObjectField,String> fieldToAPIName = new Map<Schema.SObjectField,String>();
            Map<String, String> apiNameToLabel = new Map<String, String>();
            List<Schema.FieldSetMember> fields=new List<Schema.FieldSetMember>();
            list<Schema.FieldSet> fs=fieldSetMap.values();
            
            for(Schema.FieldSet fss:fs){
                if(fss.getDescription().contains('__LWC')){
                    fields=fss.getFields();
                    system.debug('fields'+fields);
                }
            }
            for(Schema.FieldSetMember mem:fields)
            {
                Schema.SObjectField sField=mem.getSObjectField();
                fieldsLst.add(sField);
                
                system.debug('sField'+sField);
                
                Schema.DisplayType sType=mem.getType();
                fieldType.add(sType);
                
                system.debug('sType'+sType);
                
                fieldLabel.add(mem.getLabel());
                
                /*  system.debug('mem label'+mem.getLabel());
system.debug('mem field'+mem.getSObjectField());
system.debug('mem field'+mem.getType());*/
            }
            
            List<String> sObjectFieldList=new List<String>();
            for(Schema.SObjectField sf:fieldsLst)
            {
                /* if(sf.getDescribe().getlocalname().tolowercase().contains('owner'))
{
system.debug('sf.getDescribe().getlabel().tolowercase()'+sf.getDescribe().getlocalname().tolowercase());
}
system.debug('Schema.SObjectField sf'+sf); */
                sObjectFieldList.add(''+sf);
                
                system.debug('searchFieldList    '+searchFieldList);
            }
            
            List<String> displayTypeList=new List<String>();
            for(Schema.DisplayType dt:fieldType)
            {
                
                system.debug('Schema.DisplayType dt'+dt);
                displayTypeList.add(''+dt);
            }
      //     	fieldData.add(new FieldsData(sObjectFieldList,displayTypeList));
            
         //   system.debug('fieldData.fieldNameList'+fieldData.fieldNameList);
         //   system.debug('fieldData.dataTypeList'+fieldData.dataTypeList);
            
            system.debug('fieldLabel'+fieldLabel);
            
            //  JSON.serialize(fieldschema);
            /*  for(integer i=0;i<sObjectFieldList.size();i++){
system.debug('fieldLabel[i]  '+fieldLabel[i]);   
system.debug('sObjectFieldList[i]  '+sObjectFieldList[i]);
system.debug('displayTypeList[i]  '+displayTypeList[i]);
} */
            for(integer i=0;i<sObjectFieldList.size();i++){
                if(displayTypeList[i]=='REFERENCE'|| displayTypeList[i]=='DATETIME' || displayTypeList[i]=='BOOLEAN' || displayTypeList[i]=='DATE'|| displayTypeList[i]=='CURRENCY')
                {
                    inlineEdit = false;   
                }else{
                    inlineEdit=true;    
                }
                if(sObjectFieldList[i].tolowercase().contains('ownerid') && displayTypeList[i]=='REFERENCE'){
                    sObjectFieldList[i]='Owner.Alias';
                    displayTypeList[i]='STRING';
                    fieldLabel[i]=ObjectName+' '+sObjectFieldList[i].replace('.',' ');
                }
                if(sObjectFieldList[i].tolowercase().contains('id')){
                    system.debug('contains id  '+sObjectFieldList[i]);
                    String fieldName=sObjectFieldList[i].substring(0,sObjectFieldList[i].length()-2);
                    sObjectFieldList[i]=fieldName+'.Name';
                    displayTypeList[i]='STRING'; 
                    fieldLabel[i]=fieldName+' Name';
                    system.debug('sObjectFieldList[i] '+sObjectFieldList[i]);
                    system.debug('displayTypeList[i]'+displayTypeList[i]);
                    system.debug('fieldLabel[i]   '+fieldLabel[i]);
                    system.debug('fieldname '+fieldName);
                    system.debug('fieldName.tolowercase().containsNone owner'+fieldName.tolowercase().containsNone('owner'));
                    if(fieldName.tolowercase().containsNone('account'))
                    {
                        system.debug('fieldNamefieldNamefieldName              ' +fieldName);
                    }
                }
                labelList.add(new LabelDescriptionWrapper(fieldLabel[i],sObjectFieldList[i],displayTypeList[i], true, inlineEdit, null  ));
                system.debug('labelList'+labelList);
                //  String labelTemp, String fieldNameTemp, String typeTemp, boolean sortableTemp, boolean editableTemp,TypeAttributes typeAttributesTemp) {
            }   
            
            if(enableColAction) 
            {
                List<Actions> actionList = new List<Actions>();
                actionList.add(new Actions('Edit','edit'));
                actionList.add(new Actions('View','view'));
                actionList.add(new Actions('Delete','delete'));
                TypeAttributes tAttribute = new TypeAttributes(actionList);
                labelList.add(new LabelDescriptionWrapper('', '', 'action', false, false, tAttribute ));
            }
            //call method to query
            system.debug('ListViewName '+ListViewName);
            system.debug('ObjectName '+ObjectName);
            system.debug('ListViewName.containsNone '+ListViewName.containsNone('NewLastWeek'));
            ListView__mdt acct_data;
             String listQueryCondition;
            if(ListViewName.contains('NewLastWeek') || ListViewName.contains('NewThisWeek')){ 
                listQueryCondition='';
            }else{
                 acct_data=[select Query__c From ListView__mdt where ObjectName__c=:ObjectName and ListViewName__c=:ListViewName];
             	 listQueryCondition=acct_data.Query__c;
            }
            
            
            
            List<sObject> sObjectRecords = getsObjectRecords(ObjectName, sObjectFieldList,listQueryCondition,ListViewName, 50, recordId, Orderby, OrderDir);
            system.debug('sObjectRecords                '+sObjectRecords);
            dtw.ldwList     = labelList;
            dtw.sobList     = sObjectRecords;
            dtw.fieldsList  = fieldSet;
            dtw.totalCount  = Database.countQuery('SELECT count() FROM '+ObjectName);
        }
        
        return dtw;
    }
    /*   @AuraEnabled
public Static String fetFieldNameDetails(String ObjectName){
String fieldNames;
system.debug('ObjectName'+ObjectName);
AccountListView__mdt[] acct_data=[select FieldNames__c From AccountListView__mdt where ObjectName__c=:ObjectName];
for(AccountListView__mdt acl:acct_data){
fieldNames=acl.FieldNames__c;
}
system.debug('fieldnames'+fieldNames);
return fieldNames;
} */
    @AuraEnabled
    public Static List<CustomSelectOptions> getPicklistValues(String sObj) {
        System.debug('sObj'+sObj);
        List<CustomSelectOptions> options = new List<CustomSelectOptions>();
        list<ListView> opp=[SELECT Id, Name, DeveloperName FROM ListView where sObjectType=:sObj order by Name];
        for(ListView oppt:opp){
            options.add(new CustomSelectOptions(oppt.name,oppt.developername));
        }
        system.debug('options'+options);    
        return options;
    }
    
    
    /*   @AuraEnabled
public Static List<CustomSelectOptions> fetListViewDetails(String ObjectName){
system.debug('ObjectName'+ObjectName);
list<string> abc=new list<string>();
String listViewNames;
string brack='}';
list<string> a;
AccountListView__mdt[] acct_data=[select ListView__C From AccountListView__mdt where ObjectName__c=:ObjectName];
for(AccountListView__mdt acl:acct_data){
/*  listViewNames=acl.ListView__C;
List<String> ab=acl.ListView__C.split('}'); 
for(integer i=0;i<ab.size();i++)
{ 
//   a = acl.ListView__C.split(',,');
/*string removetrail=ab[i]+brack;
string aftertrail=removetrail.replace(',{','{');
abc.add(aftertrail);
system.debug('abc'+abc[i]);
//}

}
for(integer i=0;i<a.size();i++){
system.debug('a'+a[i]); 
}

// system.debug('listViewNames'+listViewNames);
return a;
} */
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getsObjectRecords(String ObjectName, List<String> fieldNameSet,String listViewCondition,String listName,Integer LimitSize, String recId, String Orderby, String OrderDir) {
        OrderDir = String.isBlank(OrderDir) ? 'asc' : OrderDir;
        System.debug('fieldNameSet'+fieldNameSet);
        String USerId=UserInfo.getUserId();
        String query;
        System.debug('listViewCondition in getSobjectRecords'+listViewCondition);
        if(listName.contains('NewLastWeek')){
             query = 'SELECT '+String.join(fieldNameSet, ',')+' FROM '+ObjectName+' WHERE CreatedDate = LAST_WEEK ORDER BY CreatedDate DESC';
        }else if(listName.contains('NewThisWeek')){
             query = 'SELECT '+String.join(fieldNameSet, ',')+' FROM '+ObjectName+' WHERE CreatedDate = THIS_WEEK ORDER BY CreatedDate ASC';
        }else{
         query = 'SELECT '+String.join(fieldNameSet, ',')+' FROM '+ObjectName+' WHERE '+listViewCondition;
        }
        System.debug('intial query'+query);
        if(String.isNotBlank(recId)) {
            recId = String.valueOf(recId);
            query += ' WHERE ID >: recId AND '+listViewCondition;
        }
      /*  if(listViewCondition.containsNone('ORDER BY')){
        query += ' ORDER BY '+Orderby+' '+OrderDir+' NULLS LAST';
        } */
        system.debug('query order by order dir'+query);
        if(LimitSize != null && Integer.valueOf(LimitSize) > 0 && listViewCondition.containsNone('LIMIT')) {
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit '+LimitSize;
        }
        System.debug('final query'+query);
        
        System.debug('Database.query(query)'+Database.query(query));
        return Database.query(query);
        
    }
    
    //metho if we want to delete records
    @AuraEnabled
    public static sObject deleteSObject(sObject sob) {
        System.debug('Sob'+sob);
        delete sob;
        return sob;
    }
    
    //Method to save records in inline edit
    @AuraEnabled
    public static void updateRecords(List<sObject> sobList, String updateObjStr, String objectName) {
        schema.SObjectType sobjType = Schema.getGlobalDescribe().get(ObjectName);
        System.debug('sobjType'+sobjType);
        Map<String, Schema.sObjectField> sObjectFields = sobjType.getDescribe().fields.getMap();
        System.debug('sObjectFields'+sObjectFields);
        List<sObject> updateList = new List<sObject>();
        System.debug('updateList'+updateList);
        List<Object> obList = (List<object>)json.deserializeUntyped(updateObjStr);
        System.debug('obList'+obList);
        for(object ob : obList) {
            Map<String, object> obmap = (Map<String, object>)ob;
            System.debug('obmap'+obmap);
            String rowKey = (String)obmap.get('id');
            System.debug('rowKey'+rowKey);
            Integer rowKeyInt = Integer.ValueOf(rowKey.removeStart('row-'));
            System.debug('rowKeyInt'+rowKeyInt);
            sobject sObj = sobList[rowKeyInt];
            System.debug('sObj'+sObj);
            for(string fieldName : obmap.keySet())
            {
                System.debug('fieldName'+fieldName);
                if(fieldName != 'id') 
                {
                    Object value = obmap.get(fieldName);
                    System.debug('value'+value);
                    Schema.DisplayType valueType = sObjectFields.get(fieldName).getDescribe().getType();
                    System.debug('valueType'+valueType);
                    if (value instanceof String && valueType != Schema.DisplayType.String)
                    {
                        String svalue = (String)value;
                        System.debug('svalue'+svalue);
                        if (valueType == Schema.DisplayType.Date)
                            sObj.put(fieldName, Date.valueOf(svalue));
                        else if(valueType == Schema.DisplayType.DateTime) {
                            try{
                                System.debug( (DateTime)value);
                            }catch(exception ex) {
                                system.debug(ex.getmessage());
                            }
                            String d1 = svalue;
                            list<String> d2 = d1.split('-');
                            list<integer> timeComponent = new list<integer>();
                            timeComponent.add(Integer.valueOf(d2[0]));
                            timeComponent.add(Integer.valueOf(d2[1]));
                            timeComponent.add(Integer.valueOf(d2[2].left(2)));
                            
                            String t = d2[2].substringBetween('T','.');
                            
                            list<String> time1 = t.split(':');
                            timeComponent.add(Integer.valueOf(time1[0]));
                            timeComponent.add(Integer.valueOf(time1[1]));
                            timeComponent.add(Integer.valueOf(time1[2]));
                            
                            Datetime dt = Datetime.newInstance(timeComponent[0],timeComponent[1],timeComponent[2],timeComponent[3],timeComponent[4],timeComponent[5]);
                            sObj.put(fieldName, dt);
                        }
                        //
                        else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency)
                            sObj.put(fieldName, svalue == '' ? null : Decimal.valueOf(svalue));
                        else if (valueType == Schema.DisplayType.Double)
                            sObj.put(fieldName, svalue == '' ? null : Double.valueOf(svalue));
                        else if (valueType == Schema.DisplayType.Integer)
                            sObj.put(fieldName, Integer.valueOf(svalue));
                        else if (valueType == Schema.DisplayType.Base64)
                            sObj.put(fieldName, Blob.valueOf(svalue));
                        else
                            sObj.put(fieldName, svalue);
                    }
                    else
                        sObj.put(fieldName, value);
                }
            }
            updateList.add(sObj);
        }
        
        update updateList;
    }
    @AuraEnabled
    public static String updateMultipleFields(List<sObject> updateObj,String fieldName,String ObjectName,String updValue){
        /*schema.SObjectType sobjType = Schema.getGlobalDescribe().get(ObjectName);
System.debug('sobjType'+sobjType);
Map<String, Schema.sObjectField> sObjectFields = sobjType.getDescribe().fields.getMap();
System.debug('sObjectFields'+sObjectFields);*/
        List<sobject> sobju=new List<sobject>();
        List<string> str=fieldName.split(',');
        for(integer i=0;i<updateObj.size();i++) 
        {
            sobject sObj=updateObj[i];
            System.debug('sObj'+sObj);
            System.debug('str[0]'+str[0]);
            sobj.put(str[0],updValue);
            sobju.add(sobj);  
            System.debug('sObj after'+sObj);
        }
        try{
            update sobju;
            System.debug('Success');
            return 'success';
        }
        catch(exception e){
            system.debug('error'+e.getMessage());
            return 'error';
        }
        /* Sobject sobj=
List<String> modifiedIds=new List<String>();
List<Sobject> updSobj=new List<Sobject>();
for(String str:updateIds){
String val='\''+str+'\'';
modifiedIds.add(val);
}
string query='Select id,'+fieldName+' From '+objectName+ ' Where id IN '+modifiedIds;
System.debug('query'+query);
List<Sobject> sObj=database.query(query);
for(Sobject s:sObj){
s.id=s.id;
s.value ? fieldName : null =updValue;
updSobj.add(s);
}
update updSobj; */ 
        
    }
    @AuraEnabled
  //  public static List<String> getFieldNames(String ObjectName){
         public static List<Sobject> searchSObject(String searchKeyword,String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Map<String, Schema.FieldSet> fieldSetMap = DescribeSObjectResultObj.FieldSets.getMap();
        List<Schema.FieldSetMember> fields=new List<Schema.FieldSetMember>();
        List<Schema.FieldSet> fs=fieldSetMap.values();
        for(Schema.FieldSet fss:fs){
            if(fss.getDescription().contains('__LWC')){
                fields=fss.getFields();
             //   system.debug('fields'+fields);
            }
        }
        List<Schema.SObjectField> fieldsLst=new List<Schema.SObjectField>();
        List<Schema.DisplayType> fieldType=new List<Schema.DisplayType>();
        for(Schema.FieldSetMember mem:fields)
        {
            Schema.SObjectField sField=mem.getSObjectField();
            fieldsLst.add(sField);
            
            Schema.DisplayType sType=mem.getType();
            fieldType.add(sType);
        }
        List<String> displayTypeList=new List<String>();
        for(Schema.DisplayType dt:fieldType)
        {
            
          //  system.debug('Schema.DisplayType dt'+dt);
            displayTypeList.add(''+dt);
        }
        List<String> sObjectFieldList=new List<String>();
        List<String> finalFieldVals=new List<String>();
        for(Schema.SObjectField sf:fieldsLst)
        {
            sObjectFieldList.add(''+sf);
        }
            for(integer i=0;i<displayTypeList.size();i++)
            {
                if(displayTypeList[i]!='DATETIME' && displayTypeList[i]!='BOOLEAN' && displayTypeList[i]!='DATE' && displayTypeList[i]!='CURRENCY' && displayTypeList[i]!='PICKLIST')
                {
                    system.debug('displayTypeList      '+displayTypeList[i]);
                    finalFieldVals.add(sObjectFieldList[i]);
                }
            }
        for(integer i=0;i<finalFieldVals.size();i++){
            /* system.debug('sObjectFieldList     '+sObjectFieldList[i]);
system.debug('displayTypeList        '+displayTypeList[i]);
if(displayTypeList[i]!='DATETIME' || displayTypeList[i]!='BOOLEAN' || displayTypeList[i]!='DATE'|| displayTypeList[i]!='CURRENCY' || displayTypeList[i]!='PICKLIST')
{ */
            if(finalFieldVals[i].tolowercase().contains('id')){
                system.debug('contains id  '+finalFieldVals[i]);
                String fieldName=finalFieldVals[i].substring(0,finalFieldVals[i].length()-2);
                finalFieldVals[i]=fieldName+'.Name';
                system.debug('finalFieldVals[i] '+finalFieldVals[i]);
                //  system.debug('displayTypeList[i]'+displayTypeList[i]);
                // system.debug('fieldLabel[i]   '+fieldLabel[i]);
                system.debug('fieldname '+fieldName);
                system.debug('fieldName.tolowercase().containsNone owner'+fieldName.tolowercase().containsNone('owner'));
                if(fieldName.tolowercase().containsNone('account'))
                {
                    system.debug('fieldNamefieldNamefieldName              ' +fieldName);
                }
            }
        }
        // }
        //       }
       // return finalFieldVals;
  //  }
    
   
    //    List<String> fieldVals= LWCDataTableController.getFieldNames(ObjectName);
      //  List<String> fieldname=fds.fieldNameList;
      //  system.debug('fds.fieldNameList'+fds.fieldNameList);
           // fieldData.dataTypeList
        //  List<String> str=fieldNameSet.split(',');
        system.debug('searchKeyword'+searchKeyword);
        List<Sobject> sObj=new List<Sobject>();
        system.debug('sObjectFieldList'+sObjectFieldList);
        
      //  system.debug('sObjectFieldList'+fieldVals);
        string query='Select id';
        for(integer i=0;i<sObjectFieldList.size();i++)
        {
            query=query+','+sObjectFieldList[i];
            System.debug('querylopp'+query);
        }
        query=query+' From '+ObjectName+' Where ';
        System.debug('query'+query);
        for(integer i=1;i<finalFieldVals.size();i++)
        {
            string searchWord='%'+searchKeyword.toLowerCase()+'%';
            searchword='\''+ searchword +'\'';
            System.debug('searchword'+searchword);
            String val=query+finalFieldVals[i]+' like '+searchword;
            system.debug('val'+val);
            //List<sObject> obj=;
            for(sObject sob:database.Query(val))
            {
                sObj.add(sob);
            }
            system.debug('sobj'+sObj);
        } 
        return sObj;
    }
    //wrapper class for data table
    public class DataTableWrapper {
        @AuraEnabled
        public List<LabelDescriptionWrapper> ldwList;
        @AuraEnabled
        public List<sObject> sobList;
        @AuraEnabled
        public List<String> fieldsList;
        @AuraEnabled
        public Integer totalCount;
    }
    
    //Wrapper class to store Field details
    public class LabelDescriptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public boolean sortable;
        @AuraEnabled
        public boolean editable;
        @AuraEnabled
        public TypeAttributes typeAttributes;
        
        public LabelDescriptionWrapper(String labelTemp, String fieldNameTemp, String typeTemp, boolean sortableTemp, boolean editableTemp,TypeAttributes typeAttributesTemp) {
            
            label       = labelTemp;
            fieldName = fieldNameTemp;
            type       = typeTemp;
            sortable  = true;//sortableTemp;
            editable = editableTemp;
            typeAttributes = typeAttributesTemp;
        }
    }
    
    //Wrapper class to bind dropdown action with data row
    public class TypeAttributes  {
        @AuraEnabled
        public List<Actions> rowActions;
        
        public typeAttributes(List<Actions> rowActionsTemp) {
            rowActions       = rowActionsTemp;
        }
    }
    
    //Wrapper class  to store dropdown action
    public class Actions {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        
        public Actions(String labelTemp, String nameTemp) {
            label           = labelTemp;
            name         = nameTemp;
        }
    }
  /*  public class FieldsData{
        
        @AuraEnabled
        public List<String> fieldNameList;
        
        @AuraEnabled
        public List<String> dataTypeList;
        
        public FieldsData(List<String> fieldnames,List<String> datatypes){
            fieldNameList=fieldnames;
            dataTypeList=datatypes;
        }
    } */
}