import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
import initRecords from '@salesforce/apex/LWCDataTableController.initRecords';
import updateRecords from '@salesforce/apex/LWCDataTableController.updateRecords';
import deleteSObject from '@salesforce/apex/LWCDataTableController.deleteSObject';
import searchSobject from '@salesforce/apex/LWCDataTableController.searchSObject';
import updateMultipleFields from '@salesforce/apex/LWCDataTableController.updateMultipleFields';
//import fetFieldNameDetails from '@salesforce/apex/LWCDataTableController.fetFieldNameDetails';
import getPicklistValues from '@salesforce/apex/LWCDataTableController.getPicklistValues';
//import setObjName from '@salesforce/apex/fieldsPickList.setObjName';

import {
    NavigationMixin
} from 'lightning/navigation';
import {
    refreshApex
} from '@salesforce/apex';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class LwcDataTable extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api fieldNamesStr;
    @api inlineEdit = false;
    @api colAction = false;
    @track data;
    @track totalNumberOfRowscolumns;
    @track loadMoreStatus;
    @api totalNumberOfRows;

    searchVal;
    textChangeValue;
    noofRecordstoUpdate;
    updCheckbox = false;
    currentData;
    recordIds = [];
    recordIdsObj = {};
    updateCardFlag = false;
    updateRecordList = [];
    checkBoxShow = false;
    countVal;
    wiredsObjectData;
    options = [];
    value = '';
    listViewitems = [];
    changedListView;

    connectedCallback() {
        this.firstCallMethod();
    }

    handleChange(event) {
        this.changedListView = event.detail.value;
        console.log('cahnge', this.changedListView);
        this.callingClass();
    }

    callingClass() {
        //        ListViewName: '$changedListView',
        console.log('this.changedListView', this.changedListView)
        initRecords({
            ObjectName: this.objectApiName,
            ListViewName: this.changedListView,
            recordId: '',
            Orderby: 'Id',
            OrderDir: 'ASC',
            inlineEdit: true,
            enableColAction: true
        }).then(result => {
            this.wiredsObjectData = result;
            console.log('result', result)
            if (result) {
                console.log('result.data.sobList{0}', result.sobList[0]);
                // for (var i = 0; i < result.data.sobList.length; i++) {
                // var fieldN = result.data.sobList[0].Account.Name;
                // result.data.sobList[0].AccountId = JSON.stringify(fieldN).toString;
                /* console.log('result.data.sobList[0].AccountId', result.data.sobList[0].AccountId);
                 console.log('fieldN', JSON.stringify(result.data.sobList[0].Account.Name));
                 console.log('fieldN', result.data.sobList[0].Name);
                 console.log('fieldN', result.data.sobList[0].StageName);
                 console.log('fieldN', result.data.sobList[0].Amount);
                 console.log('fieldN', JSON.stringify(result.data.sobList[0].Owner.Alias));*/
                //}
                this.data = result.sobList;
                console.log('this.data', JSON.stringify(this.data))
                this.columns = result.ldwList;
                console.log('this.columns', this.columns)
                this.totalNumberOfRows = result.totalCount;
                console.log('this.totalNumberOfRows', this.totalNumberOfRows)
            }
        }).catch(error => {
            this.data = null;
            this.totalNumberOfRows = null;
        })
    }

    firstCallMethod() {
        /*   fetFieldNameDetails({
               ObjectName: this.objectApiName
           }).then(response => {
               console.log('response fetFieldNameDetails', response);
               this.fieldNamesStr = response;
               console.log('this.fieldNamesStr', this.fieldNamesStr);

           }).catch(error => {
               console.log('error fetFieldNameDetails', JSON.stringify(error));
           }); */

        getPicklistValues({
            sObj: this.objectApiName
        }).then(response => {
            console.log('response', response);
            this.listViewitems = response;
            this.value = response[0].value;
            this.changedListView = response[0].value;
            this.callingClass();
            console.log('this.changedListView', this.changedListView);
            console.log('this.listviewitems', this.listViewitems);
        })
    }

    get roleoptions() {
        return this.listViewitems;
    }


    /* get roleoptions() {
         return this.listViewVals;
     } +*/
    /*  initfunc() {
          initRecords({
              ObjectName: this.objectApiName,
              fieldNamesStr: 'Name,Site,BillingState,Phone,Type,Owner.Name',
              listViewType: '',
              recordId: '',
              Orderby: 'Id',
              OrderDir: 'ASC',
              inlineEdit: true,
              enableColAction: true
          }).then(result => {
              console.log('result', result)
              this.wiredsObjectData = result;
              if (result.data) {
                  this.data = result.data.sobList;
                  console.log('this.data', this.data)
                  this.columns = result.data.ldwList;
                  console.log('this.columns', this.columns)
                  this.totalNumberOfRows = result.data.totalCount;
                  console.log('this.totalNumberOfRows', this.totalNumberOfRows)
              }
          })
      }*/

    handleKeyUp(event) {
        this.currentData = null;
        this.searchVal = event.target.value;
        this.currentData = this.data;
        console.log('this.currentData before searchSobject', JSON.stringify(this.currentData))
        //   var val = [];
        //  val = this.fieldNamesStr;
        searchSobject({
            searchKeyword: this.searchVal,
            ObjectName: this.objectApiName,
            fieldNameSet: ''
        }).then(response => {
            var newData = [];
            newData = response;
            //Appends new data to the end of the table
            if (this.searchVal != null) {
                this.data = [];
                console.log('ain assign before data=newdata', JSON.stringify(this.data))
                this.data = newData;
                console.log('ain assign after data=newdata', JSON.stringify(this.data))
            } else {
                this.data = [];
                console.log(' else before this.data = this.currentData', JSON.stringify(this.data))
                this.data = this.currentData;
                console.log('else after this.data = this.currentData', JSON.stringify(this.data))
                console.log('else this.currentData', JSON.stringify(this.currentData))
            }
        }).catch(error => {
            console.log('-------error-----' + error);
            console.log(error);
        });
    }

    getSelectedName(event) {
        var selectedRows = event.detail.selectedRows;
        var recordIds = [];
        if (selectedRows.length > 0) {
            for (var i = 0; i < selectedRows.length; i++) {
                recordIds.push(selectedRows[i].Id);
            }

            const selectedEvent = new CustomEvent('selected', {
                detail: {
                    recordIds
                },
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }

    }

    loadMoreData(event) {
        //Display a spinner to signal that data is being loaded
        //Display "Loading" when more data is being loaded
        this.loadMoreStatus = 'Loading';
        const currentRecord = this.data;
        const lastRecId = currentRecord[currentRecord.length - 1].Id;
        initRecords({
                ObjectName: this.objectApiName,
                ListViewName: this.changedListView,
                recordId: lastRecId,
                Orderby: 'Id',
                OrderDir: 'ASC',
                inlineEdit: this.inlineEdit,
                enableColAction: this.enableColAction
            })
            .then(result => {
                const currentData = result.sobList;
                //Appends new data to the end of the table
                const newData = currentRecord.concat(currentData);
                this.data = newData;
                if (this.data.length >= this.totalNumberOfRows) {
                    this.loadMoreStatus = 'No more data to load';
                } else {
                    this.loadMoreStatus = '';
                }
            })
            .catch(error => {
                console.log('-------error-------------', JSON.stringify(error));
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.editRecord(row);
                break;
            case 'view':
                this.viewRecord(row);
                break;
            case 'delete':
                this.deleteRecord(row);
                break;
            default:
                this.viewRecord(row);
                break;
        }
    }
    /************************************  Multiple Rows Update Function-Start **********************************/
    textChangeHandler(event) {
        this.textChangeValue = event.target.value;

    }

    enableCardtoUpdate() {
        this.updateCardFlag = true;

        //  console.log('this.updateCardFlag)', this.updateCardFlag)
        // var firstField = this.fieldNamesStr[0];
        var ChangeValue = [];
        // console.log('tfirstField', firstField, 'fnsdfnsdfd', this.fieldNamesStr[0])
        this.countVal = this.recordIdsObj.length;
        console.log('this.countVal', this.countVal)
        if (this.countVal > 1) {
            this.checkBoxShow = true;
            this.noofRecordstoUpdate = 'update' + this.countVal + 'Records';
            console.log('this.checkboxshow', this.checkBoxShow)
        }
        //  console.log('this.noofRecordstoUpdate', this.noofRecordstoUpdate)
        for (var i = 0; i < this.recordIdsObj.length; i++) {
            this.updateRecordList.push(this.recordIdsObj[i]);
            console.log('this.updateRecordList', this.updateRecordList)
            if (i === 0) {
                console.log('this.textChangeValue', this.textChangeValue)
                ChangeValue = this.recordIdsObj[i];
                console.log('ChangeValue.toString();', ChangeValue.Name);

                /*console.log('changevalue', ChangeValue);
                console.log('changevalue', ChangeValue.Name); */
            }
        }
    }

    getSelectedName(event) {
        var selectedRows = event.detail.selectedRows;
        console.log('this.selectedRows', JSON.stringify(event.detail.selectedRows));
        var localids = [];
        if (selectedRows.length > 0) {
            for (var i = 0; i < selectedRows.length; i++) {
                localids.push(selectedRows[i].Id);
                this.recordIdsObj = selectedRows;
            }
            this.recordIds = localids;
            console.log('this.recordId' + JSON.stringify(this.recordIds))
            console.log('this.recordIdsObj' + JSON.stringify(this.recordIdsObj))
            const selectedEvent = new CustomEvent('selected', {
                detail: {
                    localids
                },
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }

    }
    onUpdateCancel() {
        //  if (this.updCheckbox) {

    }

    onUpdateSave() {
        var val = [];
        val.push(this.updateRecordList[0]);
        console.log('in update save')
        console.log('this.updCheckbox', this.updCheckbox)
        console.log('this.updCheckbox', this.updCheckbox)
        console.log('this.countVal', this.countVal)
        console.log('this.updateRecordList[0]', this.updateRecordList[0])
        console.log('this.textChangeValue', this.textChangeValue)
        if (this.updCheckbox) {
            updateMultipleFields({
                updateObj: this.updateRecordList,
                fieldName: this.fieldNamesStr,
                ObjectName: this.objectApiName,
                updValue: this.textChangeValue
            }).then(response => {
                console.log(response)
            }).catch(error => {
                console.error(response);
            })
        } else if (this.countVal == 1) {
            console.log('this.countval in loop', this.countVal)
            console.log('this.countval in loop', this.fieldNamesStr)
            updateMultipleFields({
                updateObj: val,
                fieldName: this.fieldNamesStr,
                ObjectName: this.objectApiName,
                updValue: this.textChangeValue
            }).then(response => {
                console.log(response)
            }).catch(error => {
                console.error(error);
            })
        }
    }

    checkBoxChangeHandler(event) {
        this.updCheckbox = event.target.checked;
        console.log('this.updCheckbox', this.updCheckbox)
    }

    deleteRecord(row) {
        console.log('row', row);
        deleteSObject({
                sob: row
            }).then(response => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Deleted',
                        variant: 'success'
                    })
                );

            })
            .catch(error => {
                console.error('error');
            })
        refreshApex(this.wiredsObjectData);
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }


    editRecord(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                actionName: 'edit',
            },
        });
    }

    viewRecord(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                actionName: 'view',
            },
        });
    }

    //When save method get called from inlineEdit
    handleSave(event) {
        var draftValuesStr = JSON.stringify(event.detail.draftValues);
        console.log('draftValuesStr', draftValuesStr)
        updateRecords({
                sobList: this.data,
                updateObjStr: draftValuesStr,
                objectName: this.objectApiName
            })
            .then(result => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated',
                        variant: 'success'
                    })
                );
                // Clear all draft values
                this.draftValues = [];
                return refreshApex(this.wiredsObjectData);
            })
            .catch(error => {
                console.log('-------error-------------' + error);
                console.log(error);
            });

    }

    // The method will be called on sort click
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
    }
}