import { LightningElement, api, track } from 'lwc';
/**
 * @description Transforms desk records into a format where desk layout can be displayed for each
 *              office floor.
 */
export default class deskLayout extends LightningElement {
    @track floorDesks;

    @api bookingDate;

    @api get desks() {
        return this.floorDesks;
    }

    set desks(value) {
        let groupDesks = this.groupDesks(value);
        let floorRecs = [];
        if(groupDesks) {
            for (let prop in groupDesks) {
                if (groupDesks.hasOwnProperty(prop)) {
                    let floorVal = {floor : prop, desks : groupDesks[prop]};
                    floorRecs.push(floorVal);
                }
            }
        }
        this.floorDesks = floorRecs;
        this.setAttribute('desks', this.floorDesks);
    }

    /**
     * @description Groups desks by the floor.
     */
    groupDesks(deskValues) {
        if(deskValues) {
            let groupedDesks = {};
            for(let i = 0; i < deskValues.length; i++) {
                let desk =  deskValues[i];
                let floor = desk.Floor__c;

                if(floor in groupedDesks) {
                    groupedDesks[floor].push(desk);
                } else {
                    groupedDesks[floor] = [desk];
                }
            }
            return groupedDesks;
        }
        return null;
    }

    /**
     * @description When a new booking is made or existing booking is cancelled, fire this event
     *              so that updated data is retrived from the database.
     */
    selectDesk() {
        const gridupdateEvent = new CustomEvent('gridupdate',{bubbles: true});
        this.dispatchEvent(gridupdateEvent);
    }
}