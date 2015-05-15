// gets FullCalendar and fills it in

$(document).ready(function() {

    // page is now ready, initialize the calendar...

    $('#calendar').fullCalendar({
        // put your options and callbacks here
        events:'/calendar_work_units.json'
    });

});