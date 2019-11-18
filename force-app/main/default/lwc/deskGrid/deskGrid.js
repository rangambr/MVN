import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import createDeskBooking from '@salesforce/apex/DeskBookingHelper.createDeskBooking';
import deleteDeskBooking from '@salesforce/apex/DeskBookingHelper.deleteDeskBooking';

import userId from '@salesforce/user/Id';

import Desk_Booking_Success from '@salesforce/label/c.Desk_Booking_Success';
import Desk_Cancellation_Success from '@salesforce/label/c.Desk_Cancellation_Success';

/**
 * @description Display desks in a grid where users are able to see existing bookings
 *              and also able to make new bookings.
 */
export default class deskGrid extends LightningElement {

    @track deskRows;
    @track numberOfColumns;
    
    @api floor;
    @api bookingDate;

    @api get desks() {
        return this.deskRows;
    }

    set desks(value) {
        this.deskRows = this.getDeskRows(value);
        this.numberOfColumns = this.getNumberOfColumns();
        this.setAttribute('desks', this.deskRows);
    }

    /**
     * @description Calculates the number of columns to be displayed on the desk grid.
     */
    getNumberOfColumns() {
        let cols = 1;
        if(this.desks) {
            let rowNo = this.desks[0].desk.Office__r.Number_of_Columns__c;
            if(rowNo && rowNo !== 0) {
                cols = 12 / rowNo;
            }
        }
        return cols;
    }

    /**
     * @description Transform desk data with added attributes for selecting desks
     *              and displaying bookings.
     */
    getDeskRows(deskValues) {
        if(deskValues) {
            let deskRecs = [];
            for(let i = 0; i < deskValues.length; i++) {
                let desk = deskValues[i];
                let booking;
                let available = true;
                let selected = false;
                if(desk.Desk_Bookings__r) {
                    booking = desk.Desk_Bookings__r.records[0];
                    if(desk.Desk_Bookings__r.records[0].User__c === userId) {
                        selected = true;
                    } else {
                        available = false;
                    }
                }
                let deskRec = {
                    desk : desk,
                    booking : booking,
                    selected : selected,
                    available : available,
                    popover : false
                };
                deskRecs.push(deskRec);
            }
            return deskRecs;
        }
        return null;
    }

    /**
     * @description On selecting a desk, if it was already selected, delete the booking
     *              if not create a new booking for the current user.
     */
    handleClickGrid(event) {
        let deskId = event.target.dataset.id;
        let selected = event.target.dataset.selected;
        selected = selected === 'true' ? true : false;

        if(!selected) {
            this.createBooking(deskId);
        } else {
            this.deleteBooking(deskId);
        }
    }

    /**
     * @description Calls apex method to create a new booking for the selected desk, selected date and current user.
     */
    createBooking(deskId) {
        createDeskBooking({ deskId: deskId, bookingDate: this.bookingDate})
            .then(result => {
                if(result) {
                    this.fireGridClickEvent();
                    this.showNotification('', Desk_Booking_Success, 'success');
                }
            })
            .catch(error => {
                this.error = error.body.message;
                this.showNotification(error.statusText, error.body.message, 'error');
            });
    }

    /**
     * @description Calls apex method to delete deselected booking.
     */
    deleteBooking(deskId) {
        deleteDeskBooking({ deskId: deskId, bookingDate: this.bookingDate})
            .then(() => {
                this.fireGridClickEvent();
                this.showNotification('', Desk_Cancellation_Success, 'success');
                
            })
            .catch(error => {
                this.error = error.body.message;
                this.showNotification(error.statusText, error.body.message, 'error');
            });
    }

    /**
     * @description Fires custom event so that grid is updated with latest information from the parent component.
     */
    fireGridClickEvent() {
        const selectEvent = new CustomEvent('gridclick',{ bubbles: true });
        this.dispatchEvent(selectEvent);
    }

    /**
     * @description On hover over of the name of the existing booking slot, display the name of the user in a popover.
     */
    showUserDetails(event) {
        let deskId = event.target.dataset.id;
        this.setPopover(deskId, true);
    }

    /**
     * @description When mouse is leaving from the booking slot, hide the popover.
     */
    hideUserDetails(event) {
        let deskId = event.target.dataset.id;
        this.setPopover(deskId, false);
    }

    /**
     * @description Show/hide booking user detail popover.
     */
    setPopover(deskId, show) {
        for(let i = 0; i < this.deskRows.length; i++) {
            let deskRow = this.deskRows[i];
            if(deskRow.desk.Id === deskId) {
                deskRow.popover = show;
            }
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