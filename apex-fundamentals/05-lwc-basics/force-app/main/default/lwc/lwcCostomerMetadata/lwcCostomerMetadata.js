import { LightningElement, wire } from 'lwc';
import getAppSettings from '@salesforce/apex/CostomerMetadataController.getAppSettings';

export default class AppSettings extends LightningElement {
  
    @wire(getAppSettings, { developerName: 'Default_Settings' })
    settings;
}