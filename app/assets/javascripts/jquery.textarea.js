$(function() {
    var txt = $('#work_unit_notes'),
        hiddenDiv = $(document.createElement('div')),
        content = null;

    hiddenDiv.addClass('hiddendiv');

    $('#timeclock').append(hiddenDiv);

    txt.on('keyup', function () {

        content = $(this).val();

        content = content.replace(/\n/g, '<br>');
        hiddenDiv.html('<br>' + content + '<br>');

        $(this).css('height', hiddenDiv.height());

    })
});