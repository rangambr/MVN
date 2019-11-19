import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import officeInfo from '@salesforce/apex/DeskBookingHelper.getOffices';
import deskInfo from '@salesforce/apex/DeskBookingHelper.getDeskBookingData';

import Reserve_Your_Desk from '@salesforce/label/c.Reserve_Your_Desk';
import Booking_Date from '@salesforce/label/c.Booking_Date';
import Select_Office from '@salesforce/label/c.Select_Office';

/**
 * @description Main component for desk booking functionality. Configured to customise as a lightning tab.
 *              Query Office, Desk and User Desk Booking data.
 */
export default class deskBooking extends LightningElement {
    @track desks;
    @track officeOptions;

    selectedOffice;
    @track bookingDate = this.today;

    label = {
        Reserve_Your_Desk,
        Booking_Date,
        Select_Office
    };

    /**
     *  @description wire service for retrieving office records from the database.
     */
    @wire(officeInfo)
    wiredOfficeInfo(value) {
        if(value.data) {
            let officeRecords = JSON.parse(value.data);
            this.officeOptions = [];
            if(officeRecords) {
                this.selectedOffice = officeRecords[0].Id;
                for(let i = 0; i < officeRecords.length; i++) {
                    let officeOption = {
                        label : officeRecords[i].Name,
                        value : officeRecords[i].Id
                    };
                    
                    this.officeOptions.push(officeOption);
                }
                this.getDesks();
            }
        }
        if(value.error) {
            this.showNotification(null, value.error, 'error');
        }
    }

    /**
     * @description Provides today's date.
     */
    get today() {
        let today = new Date();
        return today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    }

    /**
     * @description Handle event when user selects an office record. Retrieves desks and bookings for
     *              selected office.
     */
    handleOfficeChange(event) {
        this.selectedOffice = event.detail.value;
        this.getDesks();
    }

    /**
     * @description Handle event when user selects a date of booking. Retrieves desks and bookings for
     *              selected date.
     */
    handleDateChange(event) {
        this.bookingDate = event.detail.value;
        this.getDesks();
    }

    /**
     * @description When a new booking is made, retrieve updated data in order to set selected bookings.
     */
    handleGridUpdate() {
        this.getDesks();
    }

    /**
     * @description Get desks and bookings from the database.
     */
    getDesks() {
        if(this.bookingDate && this.selectedOffice) {
            deskInfo({ officeId: this.selectedOffice, bookingDate: this.bookingDate })
                .then(result => {
                    if(result) {
                    this.desks = JSON.parse(result);
                    }
                })
                .catch(error => {
                    this.error = error.body.message;
                    this.showNotification(error.statusText, error.body.message, 'error');
                });
        }
    }

    /**
     * @description Show toast notification.
     */
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}