
var firstName = $('#firstName');
var lastName = $('#lastName');
var confirmationNumber = $('#confirmationNumber');

function convertDateToUTC(date) { return new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(),
    date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds());
}

function submitData() {
    var picker = $('#datetimepicker').data('datetimepicker');
    var data = {firstName:firstName.val(), lastName:lastName.val(),
        confirmationNumber:confirmationNumber.val(), startTime:convertDateToUTC(picker.getDate())}
    $.post("/job", JSON.stringify(data))
    .done(function (data) {
  	  	$.globalMessenger().post({
		  	message:  "Your request has been received, your locator is " + data,
		  	type: 'success',
		  	showCloseButton: true
		});
    })
    .fail(function (data) {
    	$.globalMessenger().post({
		  	message:  "Your request was invalid please double check all fields for correctness",
		  	type: 'error',
		  	showCloseButton: true
		});	
    })
}
